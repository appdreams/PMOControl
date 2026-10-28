import { createClient } from "npm:@supabase/supabase-js@2";

type JsonObject = Record<string, unknown>;

const json = (body: JsonObject, status = 200) => new Response(JSON.stringify(body), {
  status,
  headers: { "Content-Type": "application/json; charset=utf-8", "Cache-Control": "no-store", "Referrer-Policy": "no-referrer" },
});

function isUuid(value: unknown): value is string {
  return typeof value === "string" && /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(value);
}

function toHex(bytes: Uint8Array): string {
  return `\\x${Array.from(bytes, (byte) => byte.toString(16).padStart(2, "0")).join("")}`;
}

Deno.serve(async (request) => {
  if (request.method !== "POST") return json({ error: "METHOD_NOT_ALLOWED" }, 405);
  const authorization = request.headers.get("Authorization");
  if (!authorization?.startsWith("Bearer ")) return json({ error: "UNAUTHENTICATED" }, 401);

  let body: unknown;
  try { body = await request.json(); } catch { return json({ error: "INVALID_REQUEST" }, 400); }
  if (!body || typeof body !== "object" || Array.isArray(body)) return json({ error: "INVALID_REQUEST" }, 400);
  const input = body as Record<string, unknown>;
  const purgeRequest = input.action === "purge";
  if ((input.action !== undefined && !purgeRequest) || !isUuid(input.tenantId) ||
      !isUuid(input.idempotencyKey) || typeof input.reason !== "string" ||
      input.reason !== input.reason.trim() || input.reason.length < 1 || input.reason.length > 1000 ||
      (purgeRequest
        ? (!isUuid(input.exportId) || !Number.isSafeInteger(input.expectedTenantVersion) ||
          (input.expectedTenantVersion as number) < 1)
        : (!Number.isSafeInteger(input.expectedTenantVersion) ||
          (input.expectedTenantVersion as number) < 1 || !isUuid(input.contactUserId)))) {
    return json({ error: "INVALID_REQUEST" }, 422);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !anonKey || !serviceRoleKey) return json({ error: "SERVICE_UNAVAILABLE" }, 503);

  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authorization } },
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  try {
    const { data: userData, error: userError } = await userClient.auth.getUser();
    if (userError || !userData.user) return json({ error: "UNAUTHENTICATED" }, 401);

    if (purgeRequest) {
      const tenantId = input.tenantId as string;
      const exportId = input.exportId as string;
      const { data: started, error: startError } = await userClient.rpc("begin_tenant_export_purge", {
        p_tenant_id: tenantId,
        p_export_id: exportId,
        p_expected_tenant_version: input.expectedTenantVersion,
        p_reason: input.reason,
        p_idempotency_key: input.idempotencyKey,
      });
      if (startError) {
        if (startError.code === "42501") return json({ error: "FORBIDDEN" }, 403);
        if (startError.code === "40001") return json({ error: "VERSION_CONFLICT" }, 409);
        if (startError.code === "23505") return json({ error: "CONFLICT" }, 409);
        if (startError.code === "22023") return json({ error: "PURGE_BLOCKED" }, 422);
        return json({ error: "PURGE_UNAVAILABLE" }, 503);
      }
      if (!started || typeof started !== "object" || (started as JsonObject).tenantId !== tenantId ||
          (started as JsonObject).exportId !== exportId) return json({ error: "PURGE_UNAVAILABLE" }, 503);

      let progress = started as JsonObject;
      for (let step = 0; step < 12 && progress.status === "in_progress"; step += 1) {
        const { data: advanced, error: advanceError } = await userClient.rpc("advance_tenant_export_purge", {
          p_tenant_id: tenantId,
          p_batch_size: 500,
        });
        if (advanceError || !advanced || typeof advanced !== "object") return json({ error: "PURGE_UNAVAILABLE" }, 503);
        progress = advanced as JsonObject;
        if (progress.status === "blocked" || progress.status === "completed") break;
        if (progress.needsArtifactRemoval === true) {
          const { data: artifact, error: artifactError } = await userClient.rpc("get_tenant_export_purge_artifact", {
            p_tenant_id: tenantId,
          });
          if (artifactError || !artifact || typeof artifact !== "object") return json({ error: "PURGE_UNAVAILABLE" }, 503);
          const object = artifact as JsonObject;
          const expectedPath = `${tenantId}/${exportId}.json`;
          if (object.tenantId !== tenantId || object.exportId !== exportId ||
              object.artifactBucket !== "tenant-exports" || object.artifactPath !== expectedPath) {
            return json({ error: "PURGE_UNAVAILABLE" }, 503);
          }
          const { error: removeError } = await adminClient.storage.from("tenant-exports").remove([expectedPath]);
          if (removeError) return json({ error: "PURGE_UNAVAILABLE" }, 503);
          const { data: confirmed, error: confirmError } = await adminClient.rpc("confirm_tenant_export_artifact_purged", {
            p_actor_id: userData.user.id,
            p_tenant_id: tenantId,
            p_export_id: exportId,
          });
          if (confirmError || !confirmed || typeof confirmed !== "object") return json({ error: "PURGE_UNAVAILABLE" }, 503);
          progress = confirmed as JsonObject;
        }
      }
      return json({ purge: progress });
    }

    const { data: reservation, error: reservationError } = await userClient.rpc("request_tenant_export", {
      p_tenant_id: input.tenantId,
      p_expected_tenant_version: input.expectedTenantVersion,
      p_contact_user_id: input.contactUserId,
      p_reason: input.reason,
      p_idempotency_key: input.idempotencyKey,
    });
    if (reservationError) {
      if (reservationError.code === "42501") return json({ error: "FORBIDDEN" }, 403);
      if (reservationError.code === "40001") return json({ error: "VERSION_CONFLICT" }, 409);
      if (reservationError.code === "23505") return json({ error: "CONFLICT" }, 409);
      if (reservationError.code === "22023") return json({ error: "INVALID_TRANSITION" }, 422);
      return json({ error: "EXPORT_UNAVAILABLE" }, 503);
    }
    if (!reservation || typeof reservation !== "object" || !isUuid((reservation as JsonObject).exportId) ||
        (reservation as JsonObject).tenantId !== input.tenantId) return json({ error: "EXPORT_UNAVAILABLE" }, 503);
    const reserved = reservation as JsonObject;
    if (reserved.status === "available") {
      return json({ tenantId: reserved.tenantId, exportId: reserved.exportId, status: "available", idempotentReplay: true });
    }
    if (reserved.status !== "generating" || typeof reserved.objectPath !== "string" ||
        !reserved.objectPath.startsWith(`${input.tenantId}/${reserved.exportId}.json`)) return json({ error: "EXPORT_UNAVAILABLE" }, 503);

    const { data: snapshot, error: snapshotError } = await userClient.rpc("get_tenant_export_bundle", {
      p_export_id: reserved.exportId,
    });
    if (snapshotError || !snapshot || typeof snapshot !== "object") return json({ error: "EXPORT_UNAVAILABLE" }, 503);
    const snapshotObject = snapshot as JsonObject;
    if (!snapshotObject.bundle || typeof snapshotObject.bundle !== "object" ||
        !snapshotObject.manifest || typeof snapshotObject.manifest !== "object") return json({ error: "EXPORT_UNAVAILABLE" }, 503);

    const artifact = new TextEncoder().encode(JSON.stringify({
      format: "pmo-tenant-export-v1",
      manifest: snapshotObject.manifest,
      data: snapshotObject.bundle,
    }));
    const digest = new Uint8Array(await crypto.subtle.digest("SHA-256", artifact));
    const checksum = toHex(digest);
    const { error: uploadError } = await adminClient.storage.from("tenant-exports").upload(
      reserved.objectPath,
      artifact,
      { contentType: "application/json", cacheControl: "0", upsert: true },
    );
    if (uploadError) return json({ error: "EXPORT_UNAVAILABLE" }, 503);

    const { data: finalized, error: finalizeError } = await adminClient.rpc("finalize_tenant_export", {
      p_actor_id: userData.user.id,
      p_export_id: reserved.exportId,
      p_artifact_sha256: checksum,
      p_artifact_bytes: artifact.byteLength,
      p_manifest: snapshotObject.manifest,
    });
    if (finalizeError || !finalized || typeof finalized !== "object") return json({ error: "EXPORT_UNAVAILABLE" }, 503);
    const final = finalized as JsonObject;
    if (final.tenantId !== input.tenantId || final.exportId !== reserved.exportId || final.status !== "available" ||
        typeof final.availableAt !== "string" || typeof final.purgeAfter !== "string") return json({ error: "EXPORT_UNAVAILABLE" }, 503);

    return json({
      tenantId: final.tenantId,
      exportId: final.exportId,
      status: final.status,
      availableAt: final.availableAt,
      purgeAfter: final.purgeAfter,
      artifactBytes: artifact.byteLength,
      sha256: checksum.slice(2),
    });
  } catch {
    // Keep payloads, tokens and provider errors out of logs and responses.
    return json({ error: "EXPORT_UNAVAILABLE" }, 503);
  }
});

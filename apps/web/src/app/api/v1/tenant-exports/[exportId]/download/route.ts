import { createApiErrorResponse, createRequestId, logApiFailure } from "@/server/infrastructure/http/api-response";
import { isTrustedSameOriginRequest } from "@/server/infrastructure/http/same-origin";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";
import { isUuid } from "@/modules/identity/application/versioned-reason-request";

const NO_STORE = { "Cache-Control": "private, no-store", "Referrer-Policy": "no-referrer" };
function errorResponse(status: number, code: string, message: string, requestId: string) {
  return createApiErrorResponse(status, code, message, requestId, NO_STORE);
}

export async function POST(request: Request, context: RouteContext<"/api/v1/tenant-exports/[exportId]/download">) {
  const requestId = createRequestId();
  if (!isTrustedSameOriginRequest(request)) return errorResponse(403, "ORIGIN_NOT_ALLOWED", "Request origin is not allowed.", requestId);
  const { exportId } = await context.params;
  if (!isUuid(exportId)) return errorResponse(404, "NOT_FOUND", "Export indisponível.", requestId);

  try {
    const supabase = await createSupabaseServerClient();
    const { data: auth, error: authError } = await supabase.auth.getClaims();
    if (authError || typeof auth?.claims?.sub !== "string") return errorResponse(401, "UNAUTHENTICATED", "Entre na sua conta para continuar.", requestId);
    const { data: metadata, error: metadataError } = await supabase.rpc("get_my_tenant_export", { p_export_id: exportId.toLowerCase() });
    if (metadataError || !metadata || typeof metadata !== "object" || Array.isArray(metadata)) {
      return errorResponse(404, "NOT_FOUND", "Export indisponível.", requestId);
    }
    const record = metadata as Record<string, unknown>;
    if (typeof record.artifactPath !== "string" || record.artifactBucket !== "tenant-exports" ||
        record.exportId !== exportId.toLowerCase() || typeof record.artifactSha256 !== "string" ||
        !/^[a-f0-9]{64}$/.test(record.artifactSha256) || !Number.isSafeInteger(record.artifactBytes) ||
        (record.artifactBytes as number) < 1 || record.artifactPath !== `${record.tenantId}/${record.exportId}.json`) {
      return errorResponse(503, "EXPORT_UNAVAILABLE", "Não foi possível validar o arquivo do export.", requestId);
    }

    const { data: artifact, error: downloadError } = await supabase.storage.from("tenant-exports").download(record.artifactPath);
    if (downloadError || !artifact) return errorResponse(503, "EXPORT_UNAVAILABLE", "O arquivo do export está temporariamente indisponível.", requestId);
    const bytes = new Uint8Array(await artifact.arrayBuffer());
    const digest = new Uint8Array(await crypto.subtle.digest("SHA-256", bytes));
    const checksum = Array.from(digest, (byte) => byte.toString(16).padStart(2, "0")).join("");
    if (bytes.byteLength !== record.artifactBytes || checksum !== record.artifactSha256) {
      return errorResponse(503, "EXPORT_UNAVAILABLE", "A integridade do arquivo do export não foi confirmada.", requestId);
    }

    const { error: auditError } = await supabase.rpc("record_my_tenant_export_download", { p_export_id: exportId.toLowerCase() });
    if (auditError) {
      logApiFailure({ requestId, operation: "api.v1/tenant-exports/[exportId]/download", error: auditError, dependencyCode: auditError.code });
      return errorResponse(503, "EXPORT_UNAVAILABLE", "Não foi possível registrar o download.", requestId);
    }
    return new Response(bytes, {
      status: 200,
      headers: {
        ...NO_STORE,
        "Content-Type": "application/json",
        "Content-Length": String(bytes.byteLength),
        "Content-Disposition": `attachment; filename="tenant-export-${exportId.toLowerCase()}.json"`,
        "X-Request-Id": requestId,
      },
    });
  } catch (error) {
    logApiFailure({ requestId, operation: "api.v1/tenant-exports/[exportId]/download", error });
    return errorResponse(503, "EXPORT_UNAVAILABLE", "Não foi possível baixar o export agora.", requestId);
  }
}

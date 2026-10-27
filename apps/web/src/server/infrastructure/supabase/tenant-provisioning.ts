import "server-only";

import { logApiFailure } from "@/server/infrastructure/http/api-response";
import { createSupabaseServerClient } from "./server";
import { getSupabasePublicConfig } from "./config";

export type TenantProvisioningInput = Readonly<{
  slug: string;
  displayName: string;
  reason: string;
  idempotencyKey: string;
}>;

export type TenantProvisioningResult =
  | { ok: true; tenantId: string; correlationId: string }
  | { ok: false; reason: "unauthenticated" | "forbidden" | "conflict" | "invalid" | "unavailable" };

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/** The database RPC re-derives auth.uid(), checks the live platform grant, and commits Tenant, presets and audit atomically. */
export async function provisionTenant(input: TenantProvisioningInput, requestId: string): Promise<TenantProvisioningResult> {
  if (!getSupabasePublicConfig()) return { ok: false, reason: "unavailable" };

  try {
    const supabase = await createSupabaseServerClient();
    const { data: claims, error: authError } = await supabase.auth.getClaims();
    if (authError) {
      if (authError.status === 401 || authError.status === 403) return { ok: false, reason: "unauthenticated" };
      logApiFailure({ requestId, operation: "api.v1/tenants/auth", error: authError, dependencyCode: authError.code });
      return { ok: false, reason: "unavailable" };
    }
    if (typeof claims?.claims?.sub !== "string") return { ok: false, reason: "unauthenticated" };

    const { data, error } = await supabase.rpc("provision_tenant", {
      p_slug: input.slug,
      p_display_name: input.displayName,
      p_reason: input.reason,
      p_idempotency_key: input.idempotencyKey,
    });

    if (error) {
      if (error.code === "42501" || error.message.toLowerCase().includes("permission denied")) {
        return { ok: false, reason: "forbidden" };
      }
      if (error.code === "23505") return { ok: false, reason: "conflict" };
      if (error.code === "22023") return { ok: false, reason: "invalid" };
      logApiFailure({ requestId, operation: "api.v1/tenants/provision", error, dependencyCode: error.code });
      return { ok: false, reason: "unavailable" };
    }

    if (!isRecord(data) || typeof data.tenantId !== "string" || typeof data.correlationId !== "string") {
      logApiFailure({ requestId, operation: "api.v1/tenants/provision_response", error: new Error("Invalid RPC response") });
      return { ok: false, reason: "unavailable" };
    }
    return { ok: true, tenantId: data.tenantId, correlationId: data.correlationId };
  } catch (error) {
    logApiFailure({ requestId, operation: "api.v1/tenants/provision", error });
    return { ok: false, reason: "unavailable" };
  }
}

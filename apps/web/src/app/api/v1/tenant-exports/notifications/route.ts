import { createApiErrorResponse, createRequestId, logApiFailure } from "@/server/infrastructure/http/api-response";
import { isTrustedSameOriginRequest } from "@/server/infrastructure/http/same-origin";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";
import { isUuid } from "@/modules/identity/application/versioned-reason-request";

const NO_STORE = { "Cache-Control": "private, no-store", "Referrer-Policy": "no-referrer" };
function errorResponse(status: number, code: string, message: string, requestId: string) {
  return createApiErrorResponse(status, code, message, requestId, NO_STORE);
}

type AvailableExport = {
  tenantId: string;
  tenantName: string;
  exportId: string;
  status: "available" | "purge_eligible";
  availableAt: string;
  purgeAfter: string;
  artifactBytes: number;
  firstDownloadedAt: string | null;
  notifiedAt: string;
};

function isAvailableExport(value: unknown): value is AvailableExport {
  if (!value || typeof value !== "object" || Array.isArray(value)) return false;
  const record = value as Record<string, unknown>;
  return isUuid(record.tenantId) && typeof record.tenantName === "string" &&
    isUuid(record.exportId) && (record.status === "available" || record.status === "purge_eligible") &&
    typeof record.availableAt === "string" && typeof record.purgeAfter === "string" &&
    Number.isSafeInteger(record.artifactBytes) &&
    (record.firstDownloadedAt === null || typeof record.firstDownloadedAt === "string") &&
    typeof record.notifiedAt === "string";
}

export async function POST(request: Request) {
  const requestId = createRequestId();
  if (!isTrustedSameOriginRequest(request)) return errorResponse(403, "ORIGIN_NOT_ALLOWED", "Request origin is not allowed.", requestId);
  try {
    const supabase = await createSupabaseServerClient();
    const { data: auth, error: authError } = await supabase.auth.getClaims();
    if (authError || typeof auth?.claims?.sub !== "string") return errorResponse(401, "UNAUTHENTICATED", "Entre na sua conta para continuar.", requestId);
    const { data, error } = await supabase.rpc("list_and_acknowledge_my_tenant_exports");
    if (error) {
      logApiFailure({ requestId, operation: "api.v1/tenant-exports/notifications", error, dependencyCode: error.code });
      return errorResponse(503, "NOTIFICATIONS_UNAVAILABLE", "Não foi possível carregar as notificações agora.", requestId);
    }
    if (!Array.isArray(data) || !data.every(isAvailableExport)) {
      return errorResponse(503, "NOTIFICATIONS_UNAVAILABLE", "Não foi possível validar as notificações.", requestId);
    }
    return Response.json({ exports: data, requestId }, { headers: NO_STORE });
  } catch (error) {
    logApiFailure({ requestId, operation: "api.v1/tenant-exports/notifications", error });
    return errorResponse(503, "NOTIFICATIONS_UNAVAILABLE", "Não foi possível carregar as notificações agora.", requestId);
  }
}

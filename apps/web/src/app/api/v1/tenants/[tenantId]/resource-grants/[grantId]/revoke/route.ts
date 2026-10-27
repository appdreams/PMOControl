import { createApiErrorResponse, createRequestId, logApiFailure } from "@/server/infrastructure/http/api-response";
import { isTrustedSameOriginRequest } from "@/server/infrastructure/http/same-origin";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";
import { isUuid, parseVersionedReasonRequest } from "@/modules/identity/application/versioned-reason-request";

const NO_STORE = { "Cache-Control": "private, no-store", "Referrer-Policy": "no-referrer" };

function errorResponse(status: number, code: string, message: string, requestId: string) {
  return createApiErrorResponse(status, code, message, requestId, NO_STORE);
}

export async function POST(
  request: Request,
  context: RouteContext<"/api/v1/tenants/[tenantId]/resource-grants/[grantId]/revoke">,
) {
  const requestId = createRequestId();
  if (!isTrustedSameOriginRequest(request)) return errorResponse(403, "ORIGIN_NOT_ALLOWED", "Request origin is not allowed.", requestId);
  if (request.headers.get("content-type")?.split(";")[0]?.trim().toLowerCase() !== "application/json") {
    return errorResponse(400, "INVALID_REQUEST", "A JSON body is required.", requestId);
  }

  const { tenantId, grantId } = await context.params;
  if (!isUuid(tenantId) || !isUuid(grantId)) return errorResponse(404, "NOT_FOUND", "Acesso indisponível.", requestId);
  let value: unknown;
  try { value = await request.json(); }
  catch { return errorResponse(400, "INVALID_REQUEST", "The request body must be valid JSON.", requestId); }
  const body = parseVersionedReasonRequest(value);
  if (!body) return errorResponse(422, "INVALID_REQUEST", "Informe a versão atual, o motivo e uma chave de operação válida.", requestId);

  try {
    const supabase = await createSupabaseServerClient();
    const { data: auth, error: authError } = await supabase.auth.getClaims();
    if (authError || typeof auth?.claims?.sub !== "string") {
      return errorResponse(401, "UNAUTHENTICATED", "Entre na sua conta para continuar.", requestId);
    }

    const { data, error } = await supabase.rpc("revoke_resource_role_grant", {
      p_tenant_id: tenantId.toLowerCase(),
      p_grant_id: grantId.toLowerCase(),
      p_expected_version: body.expectedVersion,
      p_reason: body.reason,
      p_idempotency_key: body.idempotencyKey,
    });
    if (error) {
      if (error.code === "42501") return errorResponse(403, "FORBIDDEN", "Você não pode revogar este acesso.", requestId);
      if (error.code === "40001") return errorResponse(409, "VERSION_CONFLICT", "O acesso foi alterado. Atualize a lista e tente novamente.", requestId);
      if (error.code === "22023") return errorResponse(422, "INVALID_REVOCATION", "Este acesso não pode ser revogado por esta operação.", requestId);
      if (error.code === "23505") return errorResponse(409, "CONFLICT", "A chave da operação já foi utilizada com outros dados.", requestId);
      logApiFailure({ requestId, operation: "api.v1/tenants/[tenantId]/resource-grants/[grantId]/revoke", error, dependencyCode: error.code });
      return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível revogar o acesso agora.", requestId);
    }

    if (typeof data !== "object" || data === null || Array.isArray(data)) {
      return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível validar a revogação.", requestId);
    }
    const result = data as Record<string, unknown>;
    if (result.grantId !== grantId.toLowerCase() || result.tenantId !== tenantId.toLowerCase() ||
        typeof result.subjectId !== "string" || !isUuid(result.subjectId) ||
        typeof result.roleKey !== "string" || !["pmo_admin", "pmo", "contributor", "executive", "viewer"].includes(result.roleKey) ||
        (result.scopeType !== "portfolio" && result.scopeType !== "project") ||
        typeof result.scopeId !== "string" || !isUuid(result.scopeId) ||
        !Number.isSafeInteger(result.version) || (result.version as number) < 2 ||
        typeof result.correlationId !== "string" || !isUuid(result.correlationId) ||
        typeof result.idempotentReplay !== "boolean") {
      return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível validar a revogação.", requestId);
    }
    return Response.json({ grant: result, requestId }, { headers: NO_STORE });
  } catch (error) {
    logApiFailure({ requestId, operation: "api.v1/tenants/[tenantId]/resource-grants/[grantId]/revoke", error });
    return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível revogar o acesso agora.", requestId);
  }
}

import { createApiErrorResponse, createRequestId, logApiFailure } from "@/server/infrastructure/http/api-response";
import { isTrustedSameOriginRequest } from "@/server/infrastructure/http/same-origin";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";
import { parseResourceMutationRequest } from "@/modules/identity/application/resource-mutation-request";

const NO_STORE = { "Cache-Control": "private, no-store", "Referrer-Policy": "no-referrer" };
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
type Resource = "portfolio" | "project";
type Action = "update" | "archive";
function fail(status: number, code: string, message: string, requestId: string) {
  return createApiErrorResponse(status, code, message, requestId, NO_STORE);
}

export async function mutateTenantResource(request: Request, tenantId: string, resourceId: string, resource: Resource, action: Action) {
  const requestId = createRequestId();
  if (!isTrustedSameOriginRequest(request)) return fail(403, "ORIGIN_NOT_ALLOWED", "Request origin is not allowed.", requestId);
  if (request.headers.get("content-type")?.split(";")[0]?.trim().toLowerCase() !== "application/json") return fail(400, "INVALID_REQUEST", "A JSON body is required.", requestId);
  if (!UUID.test(tenantId) || !UUID.test(resourceId)) return fail(404, "NOT_FOUND", "Recurso indisponível.", requestId);
  let value: unknown;
  try { value = await request.json(); } catch { return fail(400, "INVALID_REQUEST", "The request body must be valid JSON.", requestId); }
  const parsed = parseResourceMutationRequest(value, resource, action);
  if (!parsed) return fail(422, "INVALID_REQUEST", "Confira os campos, a versão esperada, o motivo e a chave da operação.", requestId);
  try {
    const supabase = await createSupabaseServerClient();
    const { data: auth, error: authError } = await supabase.auth.getClaims();
    if (authError || typeof auth?.claims?.sub !== "string") return fail(401, "UNAUTHENTICATED", "Entre na sua conta.", requestId);
    const rpc = resource === "portfolio" ? "mutate_portfolio" : "mutate_project";
    const resourceParam = resource === "portfolio" ? { p_portfolio_id: resourceId.toLowerCase() } : { p_project_id: resourceId.toLowerCase() };
    const { data, error } = await supabase.rpc(rpc, {
      p_tenant_id: tenantId.toLowerCase(), ...resourceParam, p_action: action,
      p_patch: parsed.patch, p_expected_version: parsed.expectedVersion,
      p_reason: parsed.reason, p_idempotency_key: parsed.idempotencyKey,
    } as never);
    if (error) {
      if (error.code === "42501") return fail(403, "FORBIDDEN", `Você não pode ${action === "archive" ? "arquivar" : "editar"} este recurso.`, requestId);
      if (error.code === "22023" || error.code === "22007" || error.code === "22P02") return fail(422, "INVALID_RESOURCE", "Os dados do recurso não são válidos.", requestId);
      if (error.code === "40001") return fail(409, "VERSION_CONFLICT", "O recurso foi alterado. Atualize a lista antes de tentar novamente.", requestId);
      if (error.code === "23505") return fail(409, "CONFLICT", "A chave da operação já foi utilizada com outros dados.", requestId);
      if (error.code === "23514") return fail(409, "LIFECYCLE_CONFLICT", "Arquive os Projetos ativos antes de arquivar este Portfólio.", requestId);
      logApiFailure({ requestId, operation: `api.${resource}.mutation`, error: { type: "dependency_failure" }, dependencyCode: error.code });
      return fail(503, "SERVICE_UNAVAILABLE", "Não foi possível atualizar o recurso.", requestId);
    }
    if (!isRecord(data) || !isRecord(data[resource]) || typeof data.correlationId !== "string" || !UUID.test(data.correlationId) || typeof data.idempotentReplay !== "boolean") {
      logApiFailure({ requestId, operation: `api.${resource}.mutation`, error: { type: "invalid_dependency_response" } });
      return fail(503, "SERVICE_UNAVAILABLE", "Não foi possível validar o recurso atualizado.", requestId);
    }
    if (data[resource].id !== resourceId.toLowerCase() || data[resource].tenant_id !== tenantId.toLowerCase()) {
      logApiFailure({ requestId, operation: `api.${resource}.mutation`, error: { type: "dependency_scope_mismatch" } });
      return fail(503, "SERVICE_UNAVAILABLE", "Não foi possível validar o escopo do recurso.", requestId);
    }
    return Response.json({ [resource]: data[resource], correlationId: data.correlationId, idempotentReplay: data.idempotentReplay, requestId }, { headers: NO_STORE });
  } catch (error) {
    logApiFailure({ requestId, operation: "api.resource_mutation", error });
    return fail(503, "SERVICE_UNAVAILABLE", "Não foi possível atualizar o recurso.", requestId);
  }
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

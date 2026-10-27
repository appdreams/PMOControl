import { createApiErrorResponse, logApiFailure } from "@/server/infrastructure/http/api-response";
import { randomUUID } from "node:crypto";
import { isTrustedSameOriginRequest } from "@/server/infrastructure/http/same-origin";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";

const NO_STORE = { "Cache-Control": "private, no-store", "Referrer-Policy": "no-referrer" };
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
function fail(status: number, code: string, message: string, requestId: string) {
  return createApiErrorResponse(status, code, message, requestId, NO_STORE);
}

export async function DELETE(request: Request, context: RouteContext<"/api/v1/tenants/[tenantId]/portfolios/[portfolioId]/projects/[associationId]">) {
  const requestId = randomUUID();
  if (!isTrustedSameOriginRequest(request)) return fail(403, "ORIGIN_NOT_ALLOWED", "Request origin is not allowed.", requestId);
  if (request.headers.get("content-type")?.split(";")[0]?.trim().toLowerCase() !== "application/json") return fail(400, "INVALID_REQUEST", "A JSON body is required.", requestId);
  const { tenantId, portfolioId, associationId } = await context.params;
  if (![tenantId, portfolioId, associationId].every((id) => UUID.test(id))) return fail(404, "NOT_FOUND", "Associação indisponível.", requestId);
  let value: unknown;
  try { value = await request.json(); } catch { return fail(400, "INVALID_REQUEST", "The request body must be valid JSON.", requestId); }
  if (typeof value !== "object" || value === null || Array.isArray(value)) return fail(422, "INVALID_REQUEST", "Dados da remoção inválidos.", requestId);
  const body = value as Record<string, unknown>;
  if (typeof body.expectedVersion !== "string" || !/^[1-9]\d{0,18}$/.test(body.expectedVersion) || typeof body.idempotencyKey !== "string" || !UUID.test(body.idempotencyKey) || typeof body.reason !== "string" || body.reason.trim().length < 1 || body.reason.trim().length > 1000 || body.reason !== body.reason.trim()) return fail(422, "INVALID_REQUEST", "Informe versão, motivo e chave válidos.", requestId);
  try {
    const supabase = await createSupabaseServerClient();
    const { data: auth, error: authError } = await supabase.auth.getClaims();
    if (authError || typeof auth?.claims?.sub !== "string") return fail(401, "UNAUTHENTICATED", "Entre na sua conta.", requestId);
    const { data, error } = await supabase.rpc("mutate_portfolio_project_association", {
      p_tenant_id: tenantId.toLowerCase(), p_portfolio_id: portfolioId.toLowerCase(), p_action: "remove",
      p_project_id: null, p_association_id: associationId.toLowerCase(), p_expected_version: body.expectedVersion,
      p_reason: body.reason, p_idempotency_key: body.idempotencyKey.toLowerCase(),
    });
    if (error) {
      if (error.code === "42501") return fail(403, "FORBIDDEN", "Você não pode remover este vínculo.", requestId);
      if (error.code === "40001" || error.code === "23505") return fail(409, "CONFLICT", "O vínculo foi alterado ou a chave já foi utilizada.", requestId);
      if (error.code === "22023") return fail(422, "INVALID_REQUEST", "Dados da remoção inválidos.", requestId);
      return fail(503, "SERVICE_UNAVAILABLE", "Não foi possível remover o vínculo.", requestId);
    }
    const result = data as Record<string, unknown>;
    const association = result?.association as Record<string, unknown> | undefined;
    if (!association || association.id !== associationId.toLowerCase() || typeof result.correlationId !== "string" || typeof result.idempotentReplay !== "boolean") return fail(503, "SERVICE_UNAVAILABLE", "Não foi possível validar a remoção.", requestId);
    return Response.json({ association, requestId, ...result }, { headers: NO_STORE });
  } catch (error) { logApiFailure({ requestId, operation: "api.v1/tenants/[tenantId]/portfolios/[portfolioId]/projects/[associationId]", error }); return fail(503, "SERVICE_UNAVAILABLE", "Não foi possível remover o vínculo.", requestId); }
}

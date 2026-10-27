import { createApiErrorResponse, logApiFailure } from "@/server/infrastructure/http/api-response";
import { randomUUID } from "node:crypto";
import { isTrustedSameOriginRequest } from "@/server/infrastructure/http/same-origin";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";

const NO_STORE = { "Cache-Control": "private, no-store", "Referrer-Policy": "no-referrer" };
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
function fail(status: number, code: string, message: string, requestId: string) {
  return createApiErrorResponse(status, code, message, requestId, NO_STORE);
}
async function identity() {
  const supabase = await createSupabaseServerClient();
  const { data, error } = await supabase.auth.getClaims();
  return error || typeof data?.claims?.sub !== "string" ? null : supabase;
}

export async function GET(_request: Request, context: RouteContext<"/api/v1/tenants/[tenantId]/portfolios/[portfolioId]/projects">) {
  const requestId = randomUUID();
  const { tenantId, portfolioId } = await context.params;
  if (!UUID.test(tenantId) || !UUID.test(portfolioId)) return fail(404, "NOT_FOUND", "Portfólio indisponível.", requestId);
  try {
    const supabase = await identity();
    if (!supabase) return fail(401, "UNAUTHENTICATED", "Entre na sua conta.", requestId);
    const { data, error } = await supabase.rpc("list_associable_projects", { p_tenant_id: tenantId.toLowerCase(), p_portfolio_id: portfolioId.toLowerCase() });
    if (error) return fail(error.code === "42501" ? 404 : 503, error.code === "42501" ? "NOT_FOUND" : "SERVICE_UNAVAILABLE", "Não foi possível carregar os Projetos disponíveis.", requestId);
    const row = data as { projects?: unknown } | null;
    if (!Array.isArray(row?.projects) || row.projects.some((p) => typeof p !== "object" || p === null || typeof (p as Record<string, unknown>).id !== "string" || !UUID.test((p as Record<string, string>).id))) {
      return fail(503, "SERVICE_UNAVAILABLE", "Não foi possível validar os Projetos disponíveis.", requestId);
    }
    return Response.json(row, { headers: NO_STORE });
  } catch (error) { logApiFailure({ requestId, operation: "api.v1/tenants/[tenantId]/portfolios/[portfolioId]/projects", error }); return fail(503, "SERVICE_UNAVAILABLE", "Não foi possível carregar os Projetos disponíveis.", requestId); }
}

export async function POST(request: Request, context: RouteContext<"/api/v1/tenants/[tenantId]/portfolios/[portfolioId]/projects">) {
  const requestId = randomUUID();
  if (!isTrustedSameOriginRequest(request)) return fail(403, "ORIGIN_NOT_ALLOWED", "Request origin is not allowed.", requestId);
  if (request.headers.get("content-type")?.split(";")[0]?.trim().toLowerCase() !== "application/json") return fail(400, "INVALID_REQUEST", "A JSON body is required.", requestId);
  const { tenantId, portfolioId } = await context.params;
  if (!UUID.test(tenantId) || !UUID.test(portfolioId)) return fail(404, "NOT_FOUND", "Portfólio indisponível.", requestId);
  let value: unknown;
  try { value = await request.json(); } catch { return fail(400, "INVALID_REQUEST", "The request body must be valid JSON.", requestId); }
  if (typeof value !== "object" || value === null || Array.isArray(value)) return fail(422, "INVALID_REQUEST", "Dados da associação inválidos.", requestId);
  const body = value as Record<string, unknown>;
  if (typeof body.projectId !== "string" || !UUID.test(body.projectId) || typeof body.idempotencyKey !== "string" || !UUID.test(body.idempotencyKey) || typeof body.reason !== "string" || body.reason.trim().length < 1 || body.reason.trim().length > 1000 || body.reason !== body.reason.trim()) return fail(422, "INVALID_REQUEST", "Informe Projeto, motivo e chave válida.", requestId);
  try {
    const supabase = await identity();
    if (!supabase) return fail(401, "UNAUTHENTICATED", "Entre na sua conta.", requestId);
    const { data, error } = await supabase.rpc("mutate_portfolio_project_association", {
      p_tenant_id: tenantId.toLowerCase(), p_portfolio_id: portfolioId.toLowerCase(), p_action: "associate",
      p_project_id: body.projectId.toLowerCase(), p_association_id: null, p_expected_version: null,
      p_reason: body.reason, p_idempotency_key: body.idempotencyKey.toLowerCase(),
    });
    if (error) {
      if (error.code === "42501") return fail(403, "FORBIDDEN", "Você não pode associar este Projeto.", requestId);
      if (error.code === "23505") return fail(409, "CONFLICT", "Projeto já associado ou chave reutilizada com outros dados.", requestId);
      if (error.code === "22023") return fail(422, "INVALID_REQUEST", "Dados da associação inválidos.", requestId);
      return fail(503, "SERVICE_UNAVAILABLE", "Não foi possível associar o Projeto.", requestId);
    }
    const result = data as Record<string, unknown>;
    const association = result?.association as Record<string, unknown> | undefined;
    if (!association || typeof association.id !== "string" || !UUID.test(association.id) || typeof result.correlationId !== "string" || typeof result.idempotentReplay !== "boolean") return fail(503, "SERVICE_UNAVAILABLE", "Não foi possível validar a associação.", requestId);
    return Response.json({ association, requestId, ...result }, { status: result.idempotentReplay ? 200 : 201, headers: NO_STORE });
  } catch (error) { logApiFailure({ requestId, operation: "api.v1/tenants/[tenantId]/portfolios/[portfolioId]/projects", error }); return fail(503, "SERVICE_UNAVAILABLE", "Não foi possível associar o Projeto.", requestId); }
}

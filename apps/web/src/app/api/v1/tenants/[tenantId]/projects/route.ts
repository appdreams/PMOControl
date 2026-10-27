import { createApiErrorResponse, logApiFailure } from "@/server/infrastructure/http/api-response";
import { randomUUID } from "node:crypto";
import { isTrustedSameOriginRequest } from "@/server/infrastructure/http/same-origin";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";
import { parseProjectCreateRequest } from "@/modules/identity/application/resource-create-request";

const NO_STORE = { "Cache-Control": "private, no-store", "Referrer-Policy": "no-referrer" };
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
function fail(status: number, code: string, message: string, requestId: string) {
  return createApiErrorResponse(status, code, message, requestId, NO_STORE);
}
function isProjectList(value: unknown): value is { canCreate: boolean; projects: Array<Record<string, unknown>> } {
  if (typeof value !== "object" || value === null || Array.isArray(value)) return false;
  const row = value as Record<string, unknown>;
  return typeof row.canCreate === "boolean" && Array.isArray(row.projects) && row.projects.every((item) => {
    if (typeof item !== "object" || item === null || Array.isArray(item)) return false;
    const project = item as Record<string, unknown>;
    return typeof project.id === "string" && UUID.test(project.id) &&
      typeof project.tenantId === "string" && UUID.test(project.tenantId) &&
      typeof project.portfolioId === "string" && UUID.test(project.portfolioId) &&
      typeof project.name === "string" && typeof project.priority === "string" &&
      typeof project.canEdit === "boolean" && typeof project.canArchive === "boolean" &&
      typeof project.associationId === "string" && UUID.test(project.associationId) &&
      typeof project.associationVersion === "string" && /^[1-9]\d{0,18}$/.test(project.associationVersion) &&
      typeof project.canRemoveAssociation === "boolean" &&
      typeof project.canAssignManager === "boolean" &&
      typeof project.status === "string" && typeof project.version === "string" && /^[1-9]\d{0,18}$/.test(project.version);
  });
}

export async function GET(request: Request, context: RouteContext<"/api/v1/tenants/[tenantId]/projects">) {
  const requestId = randomUUID();
  const { tenantId } = await context.params;
  const portfolioId = new URL(request.url).searchParams.get("portfolioId");
  if (!UUID.test(tenantId) || !portfolioId || !UUID.test(portfolioId)) return fail(404, "NOT_FOUND", "Portfólio indisponível.", requestId);
  try {
    const supabase = await createSupabaseServerClient();
    const { data: auth, error: authError } = await supabase.auth.getClaims();
    if (authError || typeof auth?.claims?.sub !== "string") return fail(401, "UNAUTHENTICATED", "Entre na sua conta.", requestId);
    const { data, error } = await supabase.rpc("list_portfolio_projects", {
      p_tenant_id: tenantId.toLowerCase(), p_portfolio_id: portfolioId.toLowerCase(),
    });
    if (error) return fail(error.code === "42501" ? 404 : 503, error.code === "42501" ? "NOT_FOUND" : "SERVICE_UNAVAILABLE", "Não foi possível carregar os Projetos.", requestId);
    if (!isProjectList(data) || data.projects.some((item) => item.tenantId !== tenantId.toLowerCase() || item.portfolioId !== portfolioId.toLowerCase())) {
      return fail(503, "SERVICE_UNAVAILABLE", "Não foi possível validar os Projetos.", requestId);
    }
    return Response.json(data, { headers: NO_STORE });
  } catch (error) { logApiFailure({ requestId, operation: "api.v1/tenants/[tenantId]/projects", error });
    return fail(503, "SERVICE_UNAVAILABLE", "Não foi possível carregar os Projetos.", requestId);
  }
}

export async function POST(request: Request, context: RouteContext<"/api/v1/tenants/[tenantId]/projects">) {
  const requestId = randomUUID();
  if (!isTrustedSameOriginRequest(request)) return fail(403, "ORIGIN_NOT_ALLOWED", "Request origin is not allowed.", requestId);
  if (request.headers.get("content-type")?.split(";")[0]?.trim().toLowerCase() !== "application/json") return fail(400, "INVALID_REQUEST", "A JSON body is required.", requestId);
  const { tenantId } = await context.params;
  if (!UUID.test(tenantId)) return fail(404, "NOT_FOUND", "Organização indisponível.", requestId);
  let value: unknown;
  try { value = await request.json(); } catch { return fail(400, "INVALID_REQUEST", "The request body must be valid JSON.", requestId); }
  const parsed = parseProjectCreateRequest(value);
  if (!parsed) return fail(422, "INVALID_REQUEST", "Confira os campos do Projeto e a chave da solicitação.", requestId);
  try {
    const supabase = await createSupabaseServerClient();
    const { data: auth, error: authError } = await supabase.auth.getClaims();
    if (authError || typeof auth?.claims?.sub !== "string") return fail(401, "UNAUTHENTICATED", "Entre na sua conta.", requestId);
    const { data, error } = await supabase.rpc("create_portfolio_project", {
      p_tenant_id: tenantId.toLowerCase(), p_portfolio_id: parsed.portfolioId,
      p_name: parsed.name, p_code: parsed.code, p_sponsor_id: parsed.sponsorId,
      p_priority: parsed.priority, p_scope_summary: parsed.scopeSummary,
      p_start_date: parsed.startDate, p_target_end_date: parsed.targetEndDate,
      p_reason: parsed.reason, p_idempotency_key: parsed.idempotencyKey,
    });
    if (error) {
      if (error.code === "42501") return fail(403, "FORBIDDEN", "Você não pode criar Projetos neste Portfólio.", requestId);
      if (error.code === "22023") return fail(422, "INVALID_PROJECT", "Os dados do Projeto não são válidos.", requestId);
      if (error.code === "23505" || error.code === "40001") return fail(409, "CONFLICT", "O código ou a chave da solicitação já foi utilizado.", requestId);
      return fail(503, "SERVICE_UNAVAILABLE", "Não foi possível criar o Projeto.", requestId);
    }
    if (typeof data !== "object" || data === null || Array.isArray(data)) return fail(503, "SERVICE_UNAVAILABLE", "Não foi possível validar o Projeto.", requestId);
    const result = data as Record<string, unknown>;
    if (typeof result.projectId !== "string" || !UUID.test(result.projectId) || result.tenantId !== tenantId.toLowerCase() ||
        result.portfolioId !== parsed.portfolioId || result.name !== parsed.name || result.status !== "planning" ||
        typeof result.version !== "string" || typeof result.correlationId !== "string" || !UUID.test(result.correlationId) ||
        typeof result.idempotentReplay !== "boolean") return fail(503, "SERVICE_UNAVAILABLE", "Não foi possível validar o Projeto.", requestId);
    return Response.json({ project: result, requestId }, { status: result.idempotentReplay ? 200 : 201, headers: NO_STORE });
  } catch (error) { logApiFailure({ requestId, operation: "api.v1/tenants/[tenantId]/projects", error });
    return fail(503, "SERVICE_UNAVAILABLE", "Não foi possível criar o Projeto.", requestId);
  }
}

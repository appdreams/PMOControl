import { createApiErrorResponse, logApiFailure } from "@/server/infrastructure/http/api-response";
import { randomUUID } from "node:crypto";
import { isTrustedSameOriginRequest } from "@/server/infrastructure/http/same-origin";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";

const NO_STORE = { "Cache-Control": "private, no-store", "Referrer-Policy": "no-referrer" };
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
function fail(status: number, code: string, message: string, requestId: string) {
  return createApiErrorResponse(status, code, message, requestId, NO_STORE);
}

export async function GET(_request: Request, context: RouteContext<"/api/v1/tenants/[tenantId]/projects/[projectId]/manager">) {
  const requestId = randomUUID();
  const { tenantId, projectId } = await context.params;
  if (!UUID.test(tenantId) || !UUID.test(projectId)) return fail(404, "NOT_FOUND", "Projeto indisponível.", requestId);
  try {
    const supabase = await createSupabaseServerClient();
    const { data: auth, error: authError } = await supabase.auth.getClaims();
    if (authError || typeof auth?.claims?.sub !== "string") return fail(401, "UNAUTHENTICATED", "Entre na sua conta.", requestId);
    const { data, error } = await supabase.rpc("list_project_manager_candidates", { p_tenant_id: tenantId.toLowerCase(), p_project_id: projectId.toLowerCase() });
    if (error) return fail(error.code === "42501" ? 404 : 503, error.code === "42501" ? "NOT_FOUND" : "SERVICE_UNAVAILABLE", "Não foi possível carregar os membros disponíveis.", requestId);
    const row = data as { manager?: unknown; candidates?: unknown } | null;
    const validPerson = (person: unknown) => typeof person === "object" && person !== null && !Array.isArray(person) && typeof (person as Record<string, unknown>).userId === "string" && UUID.test((person as Record<string, string>).userId) && typeof (person as Record<string, unknown>).displayName === "string";
    if (!row || !(row.manager === null || validPerson(row.manager)) || !Array.isArray(row.candidates) || !row.candidates.every(validPerson)) return fail(503, "SERVICE_UNAVAILABLE", "Não foi possível validar os membros disponíveis.", requestId);
    return Response.json(row, { headers: NO_STORE });
  } catch (error) { logApiFailure({ requestId, operation: "api.v1/tenants/[tenantId]/projects/[projectId]/manager", error }); return fail(503, "SERVICE_UNAVAILABLE", "Não foi possível carregar os membros disponíveis.", requestId); }
}

export async function POST(request: Request, context: RouteContext<"/api/v1/tenants/[tenantId]/projects/[projectId]/manager">) {
  const requestId = randomUUID();
  if (!isTrustedSameOriginRequest(request)) return fail(403, "ORIGIN_NOT_ALLOWED", "Request origin is not allowed.", requestId);
  if (request.headers.get("content-type")?.split(";")[0]?.trim().toLowerCase() !== "application/json") return fail(400, "INVALID_REQUEST", "A JSON body is required.", requestId);
  const { tenantId, projectId } = await context.params;
  if (!UUID.test(tenantId) || !UUID.test(projectId)) return fail(404, "NOT_FOUND", "Projeto indisponível.", requestId);
  let value: unknown;
  try { value = await request.json(); } catch { return fail(400, "INVALID_REQUEST", "The request body must be valid JSON.", requestId); }
  if (typeof value !== "object" || value === null || Array.isArray(value)) return fail(422, "INVALID_REQUEST", "Dados da atribuição inválidos.", requestId);
  const body = value as Record<string, unknown>;
  if (typeof body.subjectId !== "string" || !UUID.test(body.subjectId) || typeof body.expectedVersion !== "string" || !/^[1-9]\d{0,18}$/.test(body.expectedVersion) || typeof body.reason !== "string" || body.reason.trim().length < 1 || body.reason.trim().length > 1000 || typeof body.idempotencyKey !== "string" || !UUID.test(body.idempotencyKey)) return fail(422, "INVALID_REQUEST", "Informe membro, versão, motivo e chave válidos.", requestId);
  try {
    const supabase = await createSupabaseServerClient();
    const { data: auth, error: authError } = await supabase.auth.getClaims();
    if (authError || typeof auth?.claims?.sub !== "string") return fail(401, "UNAUTHENTICATED", "Entre na sua conta.", requestId);
    const { data, error } = await supabase.rpc("assign_project_manager", {
      p_tenant_id: tenantId.toLowerCase(), p_project_id: projectId.toLowerCase(), p_subject_id: body.subjectId.toLowerCase(),
      p_expected_version: body.expectedVersion, p_reason: body.reason.trim(), p_idempotency_key: body.idempotencyKey.toLowerCase(),
    });
    if (error) {
      if (error.code === "42501") return fail(403, "FORBIDDEN", "Você não pode atribuir este gerente ou o membro não está disponível.", requestId);
      if (error.code === "40001" || error.code === "23505") return fail(409, "CONFLICT", "O Projeto mudou ou a chave foi usada com outros dados.", requestId);
      if (error.code === "22023") return fail(422, "INVALID_ASSIGNMENT", "Os dados da atribuição não são válidos.", requestId);
      return fail(503, "SERVICE_UNAVAILABLE", "Não foi possível atribuir o gerente.", requestId);
    }
    const result = data as Record<string, unknown>;
    const project = result?.project as Record<string, unknown> | undefined;
    if (!project || project.id !== projectId.toLowerCase() || project.project_manager_id !== body.subjectId.toLowerCase() || typeof project.version !== "string" || typeof result.correlationId !== "string" || typeof result.idempotentReplay !== "boolean") return fail(503, "SERVICE_UNAVAILABLE", "Não foi possível validar a atribuição.", requestId);
    return Response.json({ project, requestId, ...result }, { status: 200, headers: NO_STORE });
  } catch (error) { logApiFailure({ requestId, operation: "api.v1/tenants/[tenantId]/projects/[projectId]/manager", error }); return fail(503, "SERVICE_UNAVAILABLE", "Não foi possível atribuir o gerente.", requestId); }
}

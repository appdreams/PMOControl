import { createApiErrorResponse, logApiFailure } from "@/server/infrastructure/http/api-response";
import { randomUUID } from "node:crypto";
import { isTrustedSameOriginRequest } from "@/server/infrastructure/http/same-origin";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";

const PRIVATE_NO_STORE = { "Cache-Control": "private, no-store", "Referrer-Policy": "no-referrer" };
const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const ROLE_KEYS = new Set(["pmo_admin", "pmo", "project_manager", "contributor", "executive", "viewer"]);

function errorResponse(status: number, code: string, message: string, requestId: string) {
  return createApiErrorResponse(status, code, message, requestId, PRIVATE_NO_STORE);
}

function parseRequest(value: unknown) {
  if (typeof value !== "object" || value === null || Array.isArray(value)) return null;
  const body = value as Record<string, unknown>;
  if (Object.keys(body).length !== 6 ||
      typeof body.subjectId !== "string" || !UUID_PATTERN.test(body.subjectId) ||
      typeof body.roleKey !== "string" || !ROLE_KEYS.has(body.roleKey) ||
      (body.scopeType !== "portfolio" && body.scopeType !== "project") ||
      typeof body.scopeId !== "string" || !UUID_PATTERN.test(body.scopeId) ||
      typeof body.reason !== "string" || typeof body.idempotencyKey !== "string" || !UUID_PATTERN.test(body.idempotencyKey)) return null;
  const reason = body.reason.trim();
  if (reason.length < 1 || reason.length > 1000) return null;
  return {
    subjectId: body.subjectId.toLowerCase(), roleKey: body.roleKey,
    scopeType: body.scopeType, scopeId: body.scopeId.toLowerCase(),
    reason, idempotencyKey: body.idempotencyKey.toLowerCase(),
  };
}

export async function POST(request: Request, context: RouteContext<"/api/v1/tenants/[tenantId]/resource-grants">) {
  const requestId = randomUUID();
  if (!isTrustedSameOriginRequest(request)) return errorResponse(403, "ORIGIN_NOT_ALLOWED", "Request origin is not allowed.", requestId);
  if (request.headers.get("content-type")?.split(";")[0]?.trim().toLowerCase() !== "application/json") {
    return errorResponse(400, "INVALID_REQUEST", "A JSON body is required.", requestId);
  }
  const { tenantId } = await context.params;
  if (!UUID_PATTERN.test(tenantId)) return errorResponse(404, "NOT_FOUND", "Organização indisponível.", requestId);

  let body: unknown;
  try { body = await request.json(); }
  catch { return errorResponse(400, "INVALID_REQUEST", "The request body must be valid JSON.", requestId); }
  const parsed = parseRequest(body);
  if (!parsed) return errorResponse(422, "INVALID_REQUEST", "Confira papel, membro, escopo e motivo da atribuição.", requestId);

  try {
    const supabase = await createSupabaseServerClient();
    const { data: auth, error: authError } = await supabase.auth.getClaims();
    if (authError || typeof auth?.claims?.sub !== "string") {
      return errorResponse(401, "UNAUTHENTICATED", "Entre na sua conta para continuar.", requestId);
    }
    const { data, error } = await supabase.rpc("assign_resource_role", {
      p_tenant_id: tenantId.toLowerCase(), p_subject_id: parsed.subjectId,
      p_role_key: parsed.roleKey, p_scope_type: parsed.scopeType, p_scope_id: parsed.scopeId,
      p_reason: parsed.reason, p_idempotency_key: parsed.idempotencyKey,
    });
    if (error) {
      if (error.code === "42501") return errorResponse(403, "FORBIDDEN", "Você não pode atribuir este papel neste recurso.", requestId);
      if (error.code === "22023") return errorResponse(422, "INVALID_ASSIGNMENT", "O papel ou escopo não está disponível para esta atribuição.", requestId);
      if (error.code === "23505") return errorResponse(409, "CONFLICT", "A chave da solicitação já foi usada com outros dados.", requestId);
      return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível atribuir o papel agora.", requestId);
    }
    if (typeof data !== "object" || data === null || Array.isArray(data)) {
      return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível validar a atribuição.", requestId);
    }
    const result = data as Record<string, unknown>;
    if (typeof result.grantId !== "string" || !UUID_PATTERN.test(result.grantId) ||
        result.tenantId !== tenantId.toLowerCase() || result.subjectId !== parsed.subjectId ||
        result.roleKey !== parsed.roleKey || result.scopeType !== parsed.scopeType || result.scopeId !== parsed.scopeId ||
        typeof result.correlationId !== "string" || !UUID_PATTERN.test(result.correlationId) ||
        typeof result.idempotentReplay !== "boolean") {
      return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível validar a atribuição.", requestId);
    }
    return Response.json({ grant: result, requestId }, { headers: PRIVATE_NO_STORE });
  } catch (error) { logApiFailure({ requestId, operation: "api.v1/tenants/[tenantId]/resource-grants", error });
    return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível atribuir o papel agora.", requestId);
  }
}

import { createApiErrorResponse, createRequestId, logApiFailure } from "@/server/infrastructure/http/api-response";
import { isTrustedSameOriginRequest } from "@/server/infrastructure/http/same-origin";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";

const NO_STORE = { "Cache-Control": "private, no-store", "Referrer-Policy": "no-referrer" };
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function errorResponse(status: number, code: string, message: string, requestId: string) {
  return createApiErrorResponse(status, code, message, requestId, NO_STORE);
}

function parseBody(value: unknown): { expectedVersion: number; reason: string; idempotencyKey: string } | null {
  if (typeof value !== "object" || value === null || Array.isArray(value)) return null;
  const body = value as Record<string, unknown>;
  if (Object.keys(body).length !== 3 || !Number.isSafeInteger(body.expectedVersion) ||
      (body.expectedVersion as number) < 1 || typeof body.reason !== "string" ||
      typeof body.idempotencyKey !== "string" || !UUID.test(body.idempotencyKey)) return null;
  const reason = body.reason.trim();
  if (reason.length < 1 || reason.length > 1000) return null;
  return { expectedVersion: body.expectedVersion as number, reason, idempotencyKey: body.idempotencyKey.toLowerCase() };
}

export async function POST(
  request: Request,
  context: RouteContext<"/api/v1/tenants/[tenantId]/termination">,
) {
  const requestId = createRequestId();
  if (!isTrustedSameOriginRequest(request)) return errorResponse(403, "ORIGIN_NOT_ALLOWED", "Request origin is not allowed.", requestId);
  if (request.headers.get("content-type")?.split(";")[0]?.trim().toLowerCase() !== "application/json") {
    return errorResponse(400, "INVALID_REQUEST", "A JSON body is required.", requestId);
  }

  const { tenantId } = await context.params;
  if (!UUID.test(tenantId)) return errorResponse(404, "NOT_FOUND", "Organização indisponível.", requestId);
  let value: unknown;
  try { value = await request.json(); }
  catch { return errorResponse(400, "INVALID_REQUEST", "The request body must be valid JSON.", requestId); }
  const body = parseBody(value);
  if (!body) return errorResponse(422, "INVALID_REQUEST", "Informe a versão atual, o motivo e uma chave de operação válida.", requestId);

  try {
    const supabase = await createSupabaseServerClient();
    const { data: auth, error: authError } = await supabase.auth.getClaims();
    if (authError || typeof auth?.claims?.sub !== "string") {
      return errorResponse(401, "UNAUTHENTICATED", "Entre na sua conta para continuar.", requestId);
    }
    const { data, error } = await supabase.rpc("begin_tenant_termination", {
      p_tenant_id: tenantId.toLowerCase(),
      p_expected_version: body.expectedVersion,
      p_reason: body.reason,
      p_idempotency_key: body.idempotencyKey,
    });
    if (error) {
      if (error.code === "42501") return errorResponse(403, "FORBIDDEN", "Você não pode iniciar o encerramento desta organização.", requestId);
      if (error.code === "40001") return errorResponse(409, "VERSION_CONFLICT", "A organização foi alterada. Atualize os dados e tente novamente.", requestId);
      if (error.code === "22023") return errorResponse(422, "INVALID_TRANSITION", "Esta organização não pode iniciar o encerramento neste estado.", requestId);
      if (error.code === "23505") return errorResponse(409, "CONFLICT", "A chave da operação já foi usada com outros dados.", requestId);
      logApiFailure({ requestId, operation: "api.v1/tenants/[tenantId]/termination", error, dependencyCode: error.code });
      return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível iniciar o encerramento agora.", requestId);
    }

    if (typeof data !== "object" || data === null || Array.isArray(data)) {
      return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível validar a transição.", requestId);
    }
    const result = data as Record<string, unknown>;
    if (result.tenantId !== tenantId.toLowerCase() || result.status !== "termination_pending" ||
        !Number.isSafeInteger(result.version) || (result.version as number) !== body.expectedVersion + 1 ||
        typeof result.terminationStartedAt !== "string" || Number.isNaN(Date.parse(result.terminationStartedAt)) ||
        typeof result.correlationId !== "string" || !UUID.test(result.correlationId) ||
        typeof result.idempotentReplay !== "boolean") {
      return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível validar a transição.", requestId);
    }
    return Response.json({ tenant: result, requestId }, { headers: NO_STORE });
  } catch (error) {
    logApiFailure({ requestId, operation: "api.v1/tenants/[tenantId]/termination", error });
    return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível iniciar o encerramento agora.", requestId);
  }
}

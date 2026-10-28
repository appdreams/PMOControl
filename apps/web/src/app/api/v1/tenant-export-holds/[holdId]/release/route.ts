import { createApiErrorResponse, createRequestId, logApiFailure } from "@/server/infrastructure/http/api-response";
import { isTrustedSameOriginRequest } from "@/server/infrastructure/http/same-origin";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";
import { isUuid } from "@/modules/identity/application/versioned-reason-request";

const noStore = { "Cache-Control": "private, no-store", "Referrer-Policy": "no-referrer" };
function fail(status: number, code: string, message: string, requestId: string) {
  return createApiErrorResponse(status, code, message, requestId, noStore);
}

export async function POST(request: Request, context: RouteContext<"/api/v1/tenant-export-holds/[holdId]/release">) {
  const requestId = createRequestId();
  if (!isTrustedSameOriginRequest(request)) return fail(403, "ORIGIN_NOT_ALLOWED", "Request origin is not allowed.", requestId);
  const { holdId } = await context.params;
  if (!isUuid(holdId)) return fail(404, "NOT_FOUND", "Hold indisponível.", requestId);
  let body: unknown;
  try { body = await request.json(); } catch { return fail(400, "INVALID_REQUEST", "The request body must be valid JSON.", requestId); }
  if (!body || typeof body !== "object" || Array.isArray(body)) return fail(422, "INVALID_REQUEST", "Dados de liberação inválidos.", requestId);
  const input = body as Record<string, unknown>;
  if (Object.keys(input).some((key) => !["expectedVersion", "reason", "idempotencyKey"].includes(key)) ||
      !Number.isSafeInteger(input.expectedVersion) || (input.expectedVersion as number) < 1 ||
      typeof input.reason !== "string" || input.reason !== input.reason.trim() || input.reason.length < 1 || input.reason.length > 1000 ||
      !isUuid(input.idempotencyKey)) {
    return fail(422, "INVALID_REQUEST", "Informe versão, motivo e chave de operação válidos.", requestId);
  }
  try {
    const supabase = await createSupabaseServerClient();
    const { data: auth, error: authError } = await supabase.auth.getClaims();
    if (authError || typeof auth?.claims?.sub !== "string") return fail(401, "UNAUTHENTICATED", "Entre na sua conta para continuar.", requestId);
    const { data, error } = await supabase.rpc("release_tenant_export_hold", {
      p_hold_id: holdId.toLowerCase(), p_expected_version: input.expectedVersion,
      p_release_reason: input.reason, p_idempotency_key: input.idempotencyKey,
    });
    if (error) {
      if (error.code === "42501") return fail(403, "FORBIDDEN", "Somente a equipe autorizada da plataforma pode liberar holds.", requestId);
      if (error.code === "40001") return fail(409, "VERSION_CONFLICT", "O hold mudou ou já foi liberado.", requestId);
      if (error.code === "22023") return fail(422, "INVALID_REQUEST", "Os dados de liberação são inválidos.", requestId);
      logApiFailure({ requestId, operation: "api.v1/tenant-export-holds/[holdId]/release", error, dependencyCode: error.code });
      return fail(503, "HOLD_UNAVAILABLE", "Não foi possível liberar o hold agora.", requestId);
    }
    if (!data || typeof data !== "object" || Array.isArray(data) || !isUuid((data as Record<string, unknown>).holdId)) {
      return fail(503, "HOLD_UNAVAILABLE", "Não foi possível validar a liberação.", requestId);
    }
    return Response.json({ hold: data, requestId }, { headers: noStore });
  } catch (error) {
    logApiFailure({ requestId, operation: "api.v1/tenant-export-holds/[holdId]/release", error });
    return fail(503, "HOLD_UNAVAILABLE", "Não foi possível liberar o hold agora.", requestId);
  }
}

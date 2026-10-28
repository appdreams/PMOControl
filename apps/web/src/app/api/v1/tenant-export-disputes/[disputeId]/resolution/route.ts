import { createApiErrorResponse, createRequestId, logApiFailure } from "@/server/infrastructure/http/api-response";
import { isTrustedSameOriginRequest } from "@/server/infrastructure/http/same-origin";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";
import { isUuid } from "@/modules/identity/application/versioned-reason-request";

const noStore = { "Cache-Control": "private, no-store", "Referrer-Policy": "no-referrer" };
function fail(status: number, code: string, message: string, requestId: string) {
  return createApiErrorResponse(status, code, message, requestId, noStore);
}

export async function POST(request: Request, context: RouteContext<"/api/v1/tenant-export-disputes/[disputeId]/resolution">) {
  const requestId = createRequestId();
  if (!isTrustedSameOriginRequest(request)) return fail(403, "ORIGIN_NOT_ALLOWED", "Request origin is not allowed.", requestId);
  const { disputeId } = await context.params;
  if (!isUuid(disputeId)) return fail(404, "NOT_FOUND", "Contestação indisponível.", requestId);
  let body: unknown;
  try { body = await request.json(); } catch { return fail(400, "INVALID_REQUEST", "The request body must be valid JSON.", requestId); }
  if (!body || typeof body !== "object" || Array.isArray(body)) return fail(422, "INVALID_REQUEST", "Dados da resolução inválidos.", requestId);
  const input = body as Record<string, unknown>;
  if (Object.keys(input).some((key) => !["expectedVersion", "outcome", "resolution", "idempotencyKey"].includes(key)) ||
      !Number.isSafeInteger(input.expectedVersion) || (input.expectedVersion as number) < 1 ||
      (input.outcome !== "resolved" && input.outcome !== "rejected") || typeof input.resolution !== "string" ||
      input.resolution !== input.resolution.trim() || input.resolution.length < 1 || input.resolution.length > 1000 ||
      !isUuid(input.idempotencyKey)) {
    return fail(422, "INVALID_REQUEST", "Informe a versão, resultado, motivo e chave válidos.", requestId);
  }
  try {
    const supabase = await createSupabaseServerClient();
    const { data: auth, error: authError } = await supabase.auth.getClaims();
    if (authError || typeof auth?.claims?.sub !== "string") return fail(401, "UNAUTHENTICATED", "Entre na sua conta para continuar.", requestId);
    const { data, error } = await supabase.rpc("resolve_tenant_export_dispute", {
      p_dispute_id: disputeId.toLowerCase(), p_expected_version: input.expectedVersion,
      p_outcome: input.outcome, p_resolution: input.resolution, p_idempotency_key: input.idempotencyKey,
    });
    if (error) {
      if (error.code === "42501") return fail(403, "FORBIDDEN", "Você não pode resolver esta contestação.", requestId);
      if (error.code === "40001") return fail(409, "VERSION_CONFLICT", "A contestação mudou ou já foi resolvida.", requestId);
      if (error.code === "22023") return fail(422, "INVALID_REQUEST", "Os dados da resolução são inválidos.", requestId);
      logApiFailure({ requestId, operation: "api.v1/tenant-export-disputes/[disputeId]/resolution", error, dependencyCode: error.code });
      return fail(503, "RESOLUTION_UNAVAILABLE", "Não foi possível salvar a resolução agora.", requestId);
    }
    if (!data || typeof data !== "object" || Array.isArray(data) || !isUuid((data as Record<string, unknown>).disputeId)) {
      return fail(503, "RESOLUTION_UNAVAILABLE", "Não foi possível validar a resolução.", requestId);
    }
    return Response.json({ dispute: data, requestId }, { headers: noStore });
  } catch (error) {
    logApiFailure({ requestId, operation: "api.v1/tenant-export-disputes/[disputeId]/resolution", error });
    return fail(503, "RESOLUTION_UNAVAILABLE", "Não foi possível salvar a resolução agora.", requestId);
  }
}

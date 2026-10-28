import { createApiErrorResponse, createRequestId, logApiFailure } from "@/server/infrastructure/http/api-response";
import { isTrustedSameOriginRequest } from "@/server/infrastructure/http/same-origin";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";
import { isUuid } from "@/modules/identity/application/versioned-reason-request";

const NO_STORE = { "Cache-Control": "private, no-store", "Referrer-Policy": "no-referrer" };
function errorResponse(status: number, code: string, message: string, requestId: string) {
  return createApiErrorResponse(status, code, message, requestId, NO_STORE);
}

export async function POST(request: Request, context: RouteContext<"/api/v1/tenants/[tenantId]/export">) {
  const requestId = createRequestId();
  if (!isTrustedSameOriginRequest(request)) return errorResponse(403, "ORIGIN_NOT_ALLOWED", "Request origin is not allowed.", requestId);
  if (request.headers.get("content-type")?.split(";")[0]?.trim().toLowerCase() !== "application/json") {
    return errorResponse(400, "INVALID_REQUEST", "A JSON body is required.", requestId);
  }
  const { tenantId } = await context.params;
  if (!isUuid(tenantId)) return errorResponse(404, "NOT_FOUND", "Organização indisponível.", requestId);
  let body: unknown;
  try { body = await request.json(); } catch { return errorResponse(400, "INVALID_REQUEST", "The request body must be valid JSON.", requestId); }
  if (!body || typeof body !== "object" || Array.isArray(body)) return errorResponse(422, "INVALID_REQUEST", "Dados de exportação inválidos.", requestId);
  const value = body as Record<string, unknown>;
  if (!Number.isSafeInteger(value.expectedTenantVersion) || (value.expectedTenantVersion as number) < 1 ||
      !isUuid(value.contactUserId) || !isUuid(value.idempotencyKey) || typeof value.reason !== "string" ||
      value.reason !== value.reason.trim() || value.reason.length < 1 || value.reason.length > 1000) {
    return errorResponse(422, "INVALID_REQUEST", "Informe versão, contato ativo, motivo e chave de operação válidos.", requestId);
  }

  try {
    const supabase = await createSupabaseServerClient();
    const { data: auth, error: authError } = await supabase.auth.getClaims();
    if (authError || typeof auth?.claims?.sub !== "string") return errorResponse(401, "UNAUTHENTICATED", "Entre na sua conta para continuar.", requestId);
    const { data, error } = await supabase.functions.invoke("tenant-export", {
      body: {
        tenantId: tenantId.toLowerCase(),
        expectedTenantVersion: value.expectedTenantVersion,
        contactUserId: value.contactUserId,
        reason: value.reason,
        idempotencyKey: value.idempotencyKey,
      },
    });
    if (error) {
      logApiFailure({ requestId, operation: "api.v1/tenants/[tenantId]/export", error });
      const context = "context" in error ? error.context : undefined;
      if (context instanceof Response) {
        if (context.status === 401) return errorResponse(401, "UNAUTHENTICATED", "Entre na sua conta para continuar.", requestId);
        if (context.status === 403) return errorResponse(403, "FORBIDDEN", "Você não pode gerar este export.", requestId);
        if (context.status === 409) return errorResponse(409, "CONFLICT", "A organização foi alterada ou a chave já foi usada.", requestId);
        if (context.status === 422) return errorResponse(422, "INVALID_TRANSITION", "A organização não pode gerar export neste estado.", requestId);
      }
      return errorResponse(503, "EXPORT_UNAVAILABLE", "Não foi possível gerar o export agora.", requestId);
    }
    if (!data || typeof data !== "object" || Array.isArray(data)) return errorResponse(503, "EXPORT_UNAVAILABLE", "Não foi possível validar o export agora.", requestId);
    const result = data as Record<string, unknown>;
    const replay = result.idempotentReplay === true;
    if (result.tenantId !== tenantId.toLowerCase() || typeof result.exportId !== "string" || !isUuid(result.exportId) ||
        result.status !== "available" || (!replay && (typeof result.availableAt !== "string" || typeof result.purgeAfter !== "string" ||
        !Number.isSafeInteger(result.artifactBytes) || typeof result.sha256 !== "string"))) {
      return errorResponse(503, "EXPORT_UNAVAILABLE", "Não foi possível validar a disponibilidade do export.", requestId);
    }
    return Response.json({ export: result, requestId }, { headers: NO_STORE });
  } catch (error) {
    logApiFailure({ requestId, operation: "api.v1/tenants/[tenantId]/export", error });
    return errorResponse(503, "EXPORT_UNAVAILABLE", "Não foi possível gerar o export agora.", requestId);
  }
}

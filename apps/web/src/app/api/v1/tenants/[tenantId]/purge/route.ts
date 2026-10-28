import { createApiErrorResponse, createRequestId, logApiFailure } from "@/server/infrastructure/http/api-response";
import { isTrustedSameOriginRequest } from "@/server/infrastructure/http/same-origin";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";
import { isUuid } from "@/modules/identity/application/versioned-reason-request";

const noStore = { "Cache-Control": "private, no-store", "Referrer-Policy": "no-referrer" };
function fail(status: number, code: string, message: string, requestId: string) {
  return createApiErrorResponse(status, code, message, requestId, noStore);
}

export async function POST(request: Request, context: RouteContext<"/api/v1/tenants/[tenantId]/purge">) {
  const requestId = createRequestId();
  if (!isTrustedSameOriginRequest(request)) return fail(403, "ORIGIN_NOT_ALLOWED", "Request origin is not allowed.", requestId);
  if (request.headers.get("content-type")?.split(";")[0]?.trim().toLowerCase() !== "application/json") {
    return fail(400, "INVALID_REQUEST", "A JSON body is required.", requestId);
  }
  const { tenantId } = await context.params;
  if (!isUuid(tenantId)) return fail(404, "NOT_FOUND", "Organização indisponível.", requestId);
  let body: unknown;
  try { body = await request.json(); } catch { return fail(400, "INVALID_REQUEST", "The request body must be valid JSON.", requestId); }
  if (!body || typeof body !== "object" || Array.isArray(body)) return fail(422, "INVALID_REQUEST", "Dados de purge inválidos.", requestId);
  const input = body as Record<string, unknown>;
  if (Object.keys(input).some((key) => !["exportId", "expectedTenantVersion", "reason", "idempotencyKey"].includes(key)) ||
      !isUuid(input.exportId) || !Number.isSafeInteger(input.expectedTenantVersion) ||
      (input.expectedTenantVersion as number) < 1 || typeof input.reason !== "string" ||
      input.reason !== input.reason.trim() || input.reason.length < 1 || input.reason.length > 1000 ||
      !isUuid(input.idempotencyKey)) {
    return fail(422, "INVALID_REQUEST", "Informe exportação, versão, motivo e chave válidos.", requestId);
  }
  try {
    const supabase = await createSupabaseServerClient();
    const { data: auth, error: authError } = await supabase.auth.getClaims();
    if (authError || typeof auth?.claims?.sub !== "string") return fail(401, "UNAUTHENTICATED", "Entre na sua conta para continuar.", requestId);
    const { data, error } = await supabase.functions.invoke("tenant-export", {
      body: {
        action: "purge", tenantId: tenantId.toLowerCase(), exportId: (input.exportId as string).toLowerCase(),
        expectedTenantVersion: input.expectedTenantVersion, reason: input.reason, idempotencyKey: input.idempotencyKey,
      },
    });
    if (error) {
      const upstream = "context" in error ? error.context : undefined;
      if (upstream instanceof Response) {
        if (upstream.status === 401) return fail(401, "UNAUTHENTICATED", "Entre na sua conta para continuar.", requestId);
        if (upstream.status === 403) return fail(403, "FORBIDDEN", "Você não pode executar o purge desta organização.", requestId);
        if (upstream.status === 409) return fail(409, "VERSION_CONFLICT", "A organização foi alterada. Atualize e tente novamente.", requestId);
        if (upstream.status === 422) return fail(422, "PURGE_BLOCKED", "A retenção, contestação ou legal hold ainda impede o purge.", requestId);
      }
      logApiFailure({ requestId, operation: "api.v1/tenants/[tenantId]/purge", error });
      return fail(503, "PURGE_UNAVAILABLE", "O purge será retomado quando o serviço estiver disponível.", requestId);
    }
    if (!data || typeof data !== "object" || Array.isArray(data)) return fail(503, "PURGE_UNAVAILABLE", "Não foi possível validar o andamento do purge.", requestId);
    const result = (data as Record<string, unknown>).purge;
    if (!result || typeof result !== "object" || Array.isArray(result) ||
        (result as Record<string, unknown>).tenantId !== tenantId.toLowerCase() ||
        !["in_progress", "blocked", "completed"].includes(String((result as Record<string, unknown>).status))) {
      return fail(503, "PURGE_UNAVAILABLE", "Não foi possível validar o andamento do purge.", requestId);
    }
    return Response.json({ purge: result, requestId }, { headers: noStore });
  } catch (error) {
    logApiFailure({ requestId, operation: "api.v1/tenants/[tenantId]/purge", error });
    return fail(503, "PURGE_UNAVAILABLE", "O purge será retomado quando o serviço estiver disponível.", requestId);
  }
}

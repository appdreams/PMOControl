import { createApiErrorResponse, createRequestId, logApiFailure } from "@/server/infrastructure/http/api-response";
import { isTrustedSameOriginRequest } from "@/server/infrastructure/http/same-origin";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";
import { isUuid } from "@/modules/identity/application/versioned-reason-request";

const noStore = { "Cache-Control": "private, no-store", "Referrer-Policy": "no-referrer" };
const datasets = new Set(["tenant", "userProfiles", "memberships", "invitations", "roles", "rolePermissions", "accessGrants", "portfolios", "projects", "portfolioProjects", "auditEvents"]);
function fail(status: number, code: string, message: string, requestId: string) {
  return createApiErrorResponse(status, code, message, requestId, noStore);
}

export async function POST(request: Request, context: RouteContext<"/api/v1/tenant-exports/[exportId]/disputes">) {
  const requestId = createRequestId();
  if (!isTrustedSameOriginRequest(request)) return fail(403, "ORIGIN_NOT_ALLOWED", "Request origin is not allowed.", requestId);
  const { exportId } = await context.params;
  if (!isUuid(exportId)) return fail(404, "NOT_FOUND", "Exportação indisponível.", requestId);
  if (request.headers.get("content-type")?.split(";")[0]?.trim().toLowerCase() !== "application/json") {
    return fail(400, "INVALID_REQUEST", "A JSON body is required.", requestId);
  }
  let body: unknown;
  try { body = await request.json(); } catch { return fail(400, "INVALID_REQUEST", "The request body must be valid JSON.", requestId); }
  if (!body || typeof body !== "object" || Array.isArray(body)) return fail(422, "INVALID_REQUEST", "Dados da contestação inválidos.", requestId);
  const input = body as Record<string, unknown>;
  if (Object.keys(input).some((key) => !["reason", "datasets", "idempotencyKey"].includes(key)) ||
      typeof input.reason !== "string" || input.reason !== input.reason.trim() || input.reason.length < 1 || input.reason.length > 1000 ||
      !Array.isArray(input.datasets) || input.datasets.length < 1 || input.datasets.length > 32 ||
      !input.datasets.every((item) => typeof item === "string" && datasets.has(item)) ||
      !isUuid(input.idempotencyKey)) {
    return fail(422, "INVALID_REQUEST", "Informe motivo, conjuntos exportados e chave de operação válidos.", requestId);
  }
  try {
    const supabase = await createSupabaseServerClient();
    const { data: auth, error: authError } = await supabase.auth.getClaims();
    if (authError || typeof auth?.claims?.sub !== "string") return fail(401, "UNAUTHENTICATED", "Entre na sua conta para continuar.", requestId);
    const { data, error } = await supabase.rpc("file_my_tenant_export_dispute", {
      p_export_id: exportId.toLowerCase(), p_reason: input.reason,
      p_disputed_scope: { schema_version: "1", datasets: input.datasets },
      p_idempotency_key: input.idempotencyKey,
    });
    if (error) {
      if (error.code === "42501") return fail(403, "FORBIDDEN", "Você não pode contestar esta exportação.", requestId);
      if (error.code === "23505") return fail(409, "CONFLICT", "A chave já foi usada com outros dados ou há outra contestação em aberto.", requestId);
      if (error.code === "22023") return fail(422, "INVALID_DISPUTE", "A janela de contestação expirou ou o escopo não corresponde à exportação.", requestId);
      logApiFailure({ requestId, operation: "api.v1/tenant-exports/[exportId]/disputes", error, dependencyCode: error.code });
      return fail(503, "DISPUTE_UNAVAILABLE", "Não foi possível registrar a contestação agora.", requestId);
    }
    if (!data || typeof data !== "object" || Array.isArray(data) || !isUuid((data as Record<string, unknown>).disputeId)) {
      return fail(503, "DISPUTE_UNAVAILABLE", "Não foi possível validar a contestação.", requestId);
    }
    return Response.json({ dispute: data, requestId }, { headers: noStore });
  } catch (error) {
    logApiFailure({ requestId, operation: "api.v1/tenant-exports/[exportId]/disputes", error });
    return fail(503, "DISPUTE_UNAVAILABLE", "Não foi possível registrar a contestação agora.", requestId);
  }
}

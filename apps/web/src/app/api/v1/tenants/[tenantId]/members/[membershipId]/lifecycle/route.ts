import { createApiErrorResponse, logApiFailure } from "@/server/infrastructure/http/api-response";
import { randomUUID } from "node:crypto";
import { isTrustedSameOriginRequest } from "@/server/infrastructure/http/same-origin";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";

const PRIVATE_NO_STORE = { "Cache-Control": "private, no-store", "Referrer-Policy": "no-referrer" };
const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const VERSION_PATTERN = /^[1-9]\d{0,18}$/;
const BIGINT_MAX = BigInt("9223372036854775807");

function errorResponse(status: number, code: string, message: string, requestId: string) {
  return createApiErrorResponse(status, code, message, requestId, PRIVATE_NO_STORE);
}

function parseRequest(value: unknown): { transition: "suspend" | "reactivate"; reason: string; expectedVersion: string; idempotencyKey: string } | null {
  if (typeof value !== "object" || value === null || Array.isArray(value)) return null;
  const body = value as Record<string, unknown>;
  if (Object.keys(body).length !== 4 ||
      (body.transition !== "suspend" && body.transition !== "reactivate") ||
      typeof body.reason !== "string" || typeof body.expectedVersion !== "string" ||
      typeof body.idempotencyKey !== "string" || !UUID_PATTERN.test(body.idempotencyKey)) return null;
  const reason = body.reason.trim();
  if (reason.length < 1 || reason.length > 1000 || !VERSION_PATTERN.test(body.expectedVersion)) return null;
  if (BigInt(body.expectedVersion) > BIGINT_MAX) return null;
  return { transition: body.transition, reason, expectedVersion: body.expectedVersion, idempotencyKey: body.idempotencyKey };
}

export async function POST(
  request: Request,
  context: RouteContext<"/api/v1/tenants/[tenantId]/members/[membershipId]/lifecycle">,
) {
  const requestId = randomUUID();
  if (!isTrustedSameOriginRequest(request)) return errorResponse(403, "ORIGIN_NOT_ALLOWED", "Request origin is not allowed.", requestId);
  if (request.headers.get("content-type")?.split(";")[0]?.trim().toLowerCase() !== "application/json") {
    return errorResponse(400, "INVALID_REQUEST", "A JSON body is required.", requestId);
  }

  const { tenantId, membershipId } = await context.params;
  if (!UUID_PATTERN.test(tenantId) || !UUID_PATTERN.test(membershipId)) {
    return errorResponse(404, "NOT_FOUND", "Organização ou membro indisponível.", requestId);
  }

  let body: unknown;
  try { body = await request.json(); }
  catch { return errorResponse(400, "INVALID_REQUEST", "The request body must be valid JSON.", requestId); }
  const parsed = parseRequest(body);
  if (!parsed) return errorResponse(422, "INVALID_REQUEST", "Informe a ação e um motivo válido para alterar o acesso.", requestId);

  try {
    const supabase = await createSupabaseServerClient();
    const { data: auth, error: authError } = await supabase.auth.getClaims();
    if (authError || typeof auth?.claims?.sub !== "string") {
      return errorResponse(401, "UNAUTHENTICATED", "Entre na sua conta para continuar.", requestId);
    }

    const { data, error } = await supabase.rpc("transition_tenant_membership", {
      p_tenant_id: tenantId.toLowerCase(),
      p_membership_id: membershipId.toLowerCase(),
      p_transition: parsed.transition,
      p_reason: parsed.reason,
      p_expected_version: parsed.expectedVersion,
      p_idempotency_key: parsed.idempotencyKey.toLowerCase(),
    });
    if (error) {
      if (error.code === "42501") return errorResponse(403, "FORBIDDEN", "Você não pode alterar este acesso.", requestId);
      if (error.code === "22023") return errorResponse(422, "INVALID_TRANSITION", "O estado deste acesso não permite esta ação.", requestId);
      if (error.code === "40001" || error.code === "23505") return errorResponse(409, "CONFLICT", "A lista mudou. Atualize e tente novamente.", requestId);
      if (error.code === "23514") return errorResponse(409, "LAST_ADMIN_REQUIRED", "A organização precisa manter ao menos um administrador ativo.", requestId);
      return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível alterar este acesso agora.", requestId);
    }

    if (typeof data !== "object" || data === null || Array.isArray(data)) {
      return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível confirmar a alteração.", requestId);
    }
    const result = data as Record<string, unknown>;
    const expectedStatus = parsed.transition === "suspend" ? "suspended" : "active";
    if (result.membershipId !== membershipId.toLowerCase() || result.status !== expectedStatus ||
        typeof result.version !== "string" || !VERSION_PATTERN.test(result.version) ||
        typeof result.correlationId !== "string" || !UUID_PATTERN.test(result.correlationId) ||
        typeof result.idempotentReplay !== "boolean") {
      return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível validar a alteração.", requestId);
    }
    return Response.json({ membership: result, requestId }, { headers: PRIVATE_NO_STORE });
  } catch (error) { logApiFailure({ requestId, operation: "api.v1/tenants/[tenantId]/members/[membershipId]/lifecycle", error });
    return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível alterar este acesso agora.", requestId);
  }
}

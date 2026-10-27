import { createApiErrorResponse, logApiFailure } from "@/server/infrastructure/http/api-response";
import { randomUUID } from "node:crypto";
import { isTrustedSameOriginRequest } from "@/server/infrastructure/http/same-origin";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";

const PRIVATE_NO_STORE = { "Cache-Control": "private, no-store", "Referrer-Policy": "no-referrer" };
const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const ROLE_KEY_PATTERN = /^[a-z][a-z0-9_.-]{1,79}$/;
const REQUEST_KEYS = ["tenantId", "subjectId", "roleKey", "scopeType", "scopeId", "reason", "idempotencyKey"];

function errorResponse(status: number, code: string, message: string, requestId: string) {
  return createApiErrorResponse(status, code, message, requestId, PRIVATE_NO_STORE);
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

export async function POST(request: Request) {
  const requestId = randomUUID();
  if (!isTrustedSameOriginRequest(request)) return errorResponse(403, "ORIGIN_NOT_ALLOWED", "Request origin is not allowed.", requestId);
  if (request.headers.get("content-type")?.split(";")[0]?.trim().toLowerCase() !== "application/json") {
    return errorResponse(400, "INVALID_REQUEST", "A JSON body is required.", requestId);
  }

  let body: unknown;
  try { body = await request.json(); }
  catch { return errorResponse(400, "INVALID_REQUEST", "The request body must be valid JSON.", requestId); }
  if (!isRecord(body) || Object.keys(body).length !== REQUEST_KEYS.length ||
      !REQUEST_KEYS.every((key) => key in body) ||
      typeof body.tenantId !== "string" || !UUID_PATTERN.test(body.tenantId) ||
      typeof body.subjectId !== "string" || !UUID_PATTERN.test(body.subjectId) ||
      typeof body.roleKey !== "string" || !ROLE_KEY_PATTERN.test(body.roleKey) ||
      body.scopeType !== "tenant" || body.scopeId !== body.tenantId ||
      typeof body.reason !== "string" || body.reason !== body.reason.trim() ||
      body.reason.length < 1 || body.reason.length > 1000 ||
      typeof body.idempotencyKey !== "string" || !UUID_PATTERN.test(body.idempotencyKey)) {
    return errorResponse(422, "INVALID_REQUEST", "Informe membro, papel, escopo Tenant, motivo e chave de idempotência válidos.", requestId);
  }

  const tenantId = (body.tenantId as string).toLowerCase();
  const subjectId = (body.subjectId as string).toLowerCase();
  const idempotencyKey = (body.idempotencyKey as string).toLowerCase();

  try {
    const supabase = await createSupabaseServerClient();
    const { data: auth, error: authError } = await supabase.auth.getClaims();
    if (authError || typeof auth?.claims?.sub !== "string") {
      return errorResponse(401, "UNAUTHENTICATED", "Entre na sua conta para continuar.", requestId);
    }

    const { data, error } = await supabase.rpc("assign_tenant_role", {
      p_tenant_id: tenantId,
      p_subject_id: subjectId,
      p_role_key: body.roleKey,
      p_reason: body.reason,
      p_idempotency_key: idempotencyKey,
    });
    if (error) {
      if (error.code === "42501") return errorResponse(403, "FORBIDDEN", "Você não pode atribuir esse papel neste Tenant.", requestId);
      if (error.code === "23505") return errorResponse(409, "CONFLICT", "A atribuição já existe ou a chave foi usada com outro conteúdo.", requestId);
      if (error.code === "22023") return errorResponse(422, "INVALID_ASSIGNMENT", "Papel, escopo ou resultado da atribuição indisponível.", requestId);
      return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível atribuir o papel agora.", requestId);
    }
    if (!isRecord(data) || typeof data.grantId !== "string" || !UUID_PATTERN.test(data.grantId) ||
        data.roleKey !== body.roleKey ||
        data.tenantId !== tenantId || data.subjectId !== subjectId ||
        data.scopeType !== "tenant" || data.scopeId !== tenantId ||
        typeof data.idempotentReplay !== "boolean") {
      return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível confirmar a atribuição.", requestId);
    }

    return Response.json({ grant: data }, { status: data.idempotentReplay ? 200 : 201, headers: PRIVATE_NO_STORE });
  } catch (error) { logApiFailure({ requestId, operation: "api.v1/access-grants", error });
    return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível atribuir o papel agora.", requestId);
  }
}

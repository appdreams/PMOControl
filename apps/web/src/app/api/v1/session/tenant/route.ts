import { createApiErrorResponse, createRequestId, logApiFailure } from "@/server/infrastructure/http/api-response";
import { resolveSupabaseRequestContext } from "@/server/infrastructure/supabase/request-context";
import { isTrustedSameOriginRequest } from "@/server/infrastructure/http/same-origin";

const PRIVATE_NO_STORE = { "Cache-Control": "private, no-store" };
const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function errorResponse(status: number, code: string, message: string, requestId: string) {
  return createApiErrorResponse(status, code, message, requestId, PRIVATE_NO_STORE);
}

export async function POST(request: Request) {
  const requestId = createRequestId();
  if (!isTrustedSameOriginRequest(request)) {
    return errorResponse(403, "ORIGIN_NOT_ALLOWED", "Request origin is not allowed.", requestId);
  }

  if (request.headers.get("content-type")?.split(";")[0]?.trim().toLowerCase() !== "application/json") {
    return errorResponse(400, "INVALID_REQUEST", "A JSON body is required.", requestId);
  }

  let body: unknown;
  try {
    body = await request.json();
  } catch {
    return errorResponse(400, "INVALID_REQUEST", "The request body must be valid JSON.", requestId);
  }

  if (
    typeof body !== "object" || body === null || Array.isArray(body) ||
    Object.keys(body).length !== 1 || !("tenantId" in body) ||
    typeof body.tenantId !== "string" || !UUID_PATTERN.test(body.tenantId)
  ) {
    return errorResponse(400, "INVALID_REQUEST", "A valid tenantId is required.", requestId);
  }

  let resolution: Awaited<ReturnType<typeof resolveSupabaseRequestContext>>;
  try {
    resolution = await resolveSupabaseRequestContext(body.tenantId);
  } catch (error) {
    logApiFailure({ requestId, operation: "api.v1/session/tenant", error });
    return errorResponse(503, "CONTEXT_UNAVAILABLE", "The session context is temporarily unavailable.", requestId);
  }
  if (!resolution.ok) {
    if (resolution.reason === "unauthenticated") {
      return errorResponse(401, "UNAUTHENTICATED", "Authentication is required.", resolution.correlationId);
    }
    if (resolution.reason === "context_unavailable") {
      return errorResponse(503, "CONTEXT_UNAVAILABLE", "The session context is temporarily unavailable.", resolution.correlationId);
    }
    if (resolution.reason === "tenant_selection_required") {
      return errorResponse(400, "TENANT_SELECTION_REQUIRED", "A Tenant selection is required.", resolution.correlationId);
    }
    return errorResponse(404, "TENANT_NOT_FOUND", "Tenant is not available.", resolution.correlationId);
  }

  return Response.json({
    tenant: { id: resolution.context.tenantId, name: resolution.context.tenantName },
    selectedTenantId: resolution.context.tenantId,
    correlationId: resolution.context.correlationId,
  }, { headers: PRIVATE_NO_STORE });
}

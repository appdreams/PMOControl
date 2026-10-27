import { createApiErrorResponse, createRequestId, logApiFailure } from "@/server/infrastructure/http/api-response";
import { resolveSupabaseRequestContext } from "@/server/infrastructure/supabase/request-context";

const PRIVATE_NO_STORE = { "Cache-Control": "private, no-store" };

export async function GET() {
  let resolution: Awaited<ReturnType<typeof resolveSupabaseRequestContext>>;
  try {
    resolution = await resolveSupabaseRequestContext();
  } catch (error) {
    const requestId = createRequestId();
    logApiFailure({ requestId, operation: "api.v1/session/tenants", error });
    return createApiErrorResponse(503, "CONTEXT_UNAVAILABLE", "The session context is temporarily unavailable.", requestId, PRIVATE_NO_STORE);
  }

  if (!resolution.ok) {
    if (resolution.reason === "unauthenticated") {
      return createApiErrorResponse(401, "UNAUTHENTICATED", "Authentication is required.", resolution.correlationId, PRIVATE_NO_STORE);
    }
    if (resolution.reason === "context_unavailable") {
      return createApiErrorResponse(503, "CONTEXT_UNAVAILABLE", "The session context is temporarily unavailable.", resolution.correlationId, PRIVATE_NO_STORE);
    }
    if (resolution.reason === "tenant_selection_required") {
      return Response.json({
        tenants: resolution.availableTenants?.map(({ tenantId, name }) => ({ id: tenantId, name })) ?? [],
        selectedTenantId: null,
        correlationId: resolution.correlationId,
      }, { headers: PRIVATE_NO_STORE });
    }
    return Response.json({ tenants: [], selectedTenantId: null, correlationId: resolution.correlationId }, {
      headers: PRIVATE_NO_STORE,
    });
  }

  return Response.json({
    tenants: [{ id: resolution.context.tenantId, name: resolution.context.tenantName }],
    selectedTenantId: resolution.context.tenantId,
    correlationId: resolution.context.correlationId,
  }, { headers: PRIVATE_NO_STORE });
}

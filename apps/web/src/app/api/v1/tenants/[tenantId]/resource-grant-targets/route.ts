import { createApiErrorResponse, logApiFailure } from "@/server/infrastructure/http/api-response";
import { randomUUID } from "node:crypto";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";

const PRIVATE_NO_STORE = { "Cache-Control": "private, no-store", "Referrer-Policy": "no-referrer" };
const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function errorResponse(status: number, code: string, message: string, requestId: string) {
  return createApiErrorResponse(status, code, message, requestId, PRIVATE_NO_STORE);
}

function isTargetList(value: unknown): value is { resources: Array<{ scopeType: "portfolio" | "project"; scopeId: string; label: string }> } {
  if (typeof value !== "object" || value === null || Array.isArray(value)) return false;
  const resources = (value as { resources?: unknown }).resources;
  return Array.isArray(resources) && resources.every((entry) => {
    if (typeof entry !== "object" || entry === null || Array.isArray(entry)) return false;
    const item = entry as Record<string, unknown>;
    return (item.scopeType === "portfolio" || item.scopeType === "project") &&
      typeof item.scopeId === "string" && UUID_PATTERN.test(item.scopeId) &&
      typeof item.label === "string" && item.label.length > 0 && item.label.length <= 160;
  });
}

export async function GET(_request: Request, context: RouteContext<"/api/v1/tenants/[tenantId]/resource-grant-targets">) {
  const requestId = randomUUID();
  const { tenantId } = await context.params;
  if (!UUID_PATTERN.test(tenantId)) return errorResponse(404, "NOT_FOUND", "Organização indisponível.", requestId);
  try {
    const supabase = await createSupabaseServerClient();
    const { data: auth, error: authError } = await supabase.auth.getClaims();
    if (authError || typeof auth?.claims?.sub !== "string") {
      return errorResponse(401, "UNAUTHENTICATED", "Entre na sua conta para continuar.", requestId);
    }
    const { data, error } = await supabase.rpc("list_resource_grant_targets", { p_tenant_id: tenantId.toLowerCase() });
    if (error) {
      if (error.code === "42501") return errorResponse(403, "FORBIDDEN", "Você não pode consultar recursos para atribuir papéis.", requestId);
      return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível carregar os recursos agora.", requestId);
    }
    if (!isTargetList(data)) return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível validar a lista de recursos.", requestId);
    return Response.json(data, { headers: PRIVATE_NO_STORE });
  } catch (error) { logApiFailure({ requestId, operation: "api.v1/tenants/[tenantId]/resource-grant-targets", error });
    return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível carregar os recursos agora.", requestId);
  }
}

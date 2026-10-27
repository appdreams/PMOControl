import { createApiErrorResponse, logApiFailure } from "@/server/infrastructure/http/api-response";
import { randomUUID } from "node:crypto";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";

const PRIVATE_NO_STORE = { "Cache-Control": "private, no-store", "Referrer-Policy": "no-referrer" };
const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

type InvitationScope = Readonly<{
  scopeType: "tenant" | "portfolio" | "project";
  scopeId: string;
  label: string;
  roleKeys: string[];
}>;

function isInvitationScopes(value: unknown): value is { scopes: InvitationScope[] } {
  if (typeof value !== "object" || value === null || Array.isArray(value)) return false;
  const scopes = (value as Record<string, unknown>).scopes;
  return Array.isArray(scopes) && scopes.every((scope) => {
    if (typeof scope !== "object" || scope === null || Array.isArray(scope)) return false;
    const row = scope as Record<string, unknown>;
    return (row.scopeType === "tenant" || row.scopeType === "portfolio" || row.scopeType === "project") &&
      typeof row.scopeId === "string" && UUID_PATTERN.test(row.scopeId) &&
      typeof row.label === "string" && row.label.length > 0 &&
      Array.isArray(row.roleKeys) && row.roleKeys.length > 0 &&
      row.roleKeys.every((key) => typeof key === "string");
  });
}

function errorResponse(status: number, code: string, message: string, requestId: string) {
  return createApiErrorResponse(status, code, message, requestId, PRIVATE_NO_STORE);
}

export async function GET(_request: Request, context: RouteContext<"/api/v1/tenants/[tenantId]/invitation-scopes">) {
  const requestId = randomUUID();
  const { tenantId } = await context.params;
  if (!UUID_PATTERN.test(tenantId)) return errorResponse(404, "NOT_FOUND", "Organização indisponível.", requestId);

  try {
    const supabase = await createSupabaseServerClient();
    const { data: auth, error: authError } = await supabase.auth.getClaims();
    if (authError || typeof auth?.claims?.sub !== "string") {
      return errorResponse(401, "UNAUTHENTICATED", "Entre na sua conta para continuar.", requestId);
    }
    const { data, error } = await supabase.rpc("list_delegable_invitation_scopes", {
      p_tenant_id: tenantId.toLowerCase(),
    });
    if (error) {
      if (error.code === "42501") return errorResponse(403, "FORBIDDEN", "Você não pode convidar membros nesta organização.", requestId);
      return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível carregar os escopos de convite.", requestId);
    }
    if (!isInvitationScopes(data)) {
      return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível validar os escopos de convite.", requestId);
    }
    return Response.json(data, { headers: PRIVATE_NO_STORE });
  } catch (error) { logApiFailure({ requestId, operation: "api.v1/tenants/[tenantId]/invitation-scopes", error });
    return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível carregar os escopos de convite.", requestId);
  }
}

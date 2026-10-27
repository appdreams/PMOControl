import { createApiErrorResponse, logApiFailure } from "@/server/infrastructure/http/api-response";
import { randomUUID } from "node:crypto";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";

const PRIVATE_NO_STORE = { "Cache-Control": "private, no-store", "Referrer-Policy": "no-referrer" };
const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function errorResponse(status: number, code: string, message: string, requestId: string) {
  return createApiErrorResponse(status, code, message, requestId, PRIVATE_NO_STORE);
}

function isMemberDirectory(value: unknown): value is { members: Array<Record<string, unknown>> } {
  if (typeof value !== "object" || value === null || Array.isArray(value)) return false;
  const members = (value as { members?: unknown }).members;
  return Array.isArray(members) && members.every((member) => {
    if (typeof member !== "object" || member === null || Array.isArray(member)) return false;
    const row = member as Record<string, unknown>;
    return typeof row.membershipId === "string" && UUID_PATTERN.test(row.membershipId) &&
      typeof row.userId === "string" && UUID_PATTERN.test(row.userId) &&
      typeof row.displayName === "string" &&
      ["active", "suspended", "revoked"].includes(String(row.status)) &&
      typeof row.activatedAt === "string" && typeof row.version === "string" && /^[1-9]\d{0,18}$/.test(row.version) && Array.isArray(row.tenantRoleKeys) &&
      row.tenantRoleKeys.every((key) => typeof key === "string");
  });
}

export async function GET(_request: Request, context: RouteContext<"/api/v1/tenants/[tenantId]/members">) {
  const requestId = randomUUID();
  const { tenantId } = await context.params;
  if (!UUID_PATTERN.test(tenantId)) return errorResponse(404, "NOT_FOUND", "Organização indisponível.", requestId);

  try {
    const supabase = await createSupabaseServerClient();
    const { data: auth, error: authError } = await supabase.auth.getClaims();
    if (authError || typeof auth?.claims?.sub !== "string") {
      return errorResponse(401, "UNAUTHENTICATED", "Entre na sua conta para continuar.", requestId);
    }

    const { data, error } = await supabase.rpc("list_tenant_members", { p_tenant_id: tenantId });
    if (error) {
      if (error.code === "42501") return errorResponse(404, "NOT_FOUND", "Organização indisponível.", requestId);
      return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível carregar os membros agora.", requestId);
    }
    if (!isMemberDirectory(data)) {
      return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível validar a lista de membros.", requestId);
    }

    return Response.json(data, { headers: PRIVATE_NO_STORE });
  } catch (error) { logApiFailure({ requestId, operation: "api.v1/tenants/[tenantId]/members", error });
    return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível carregar os membros agora.", requestId);
  }
}

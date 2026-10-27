import { createApiErrorResponse, logApiFailure } from "@/server/infrastructure/http/api-response";
import { createHash, randomBytes, randomUUID } from "node:crypto";
import { isTrustedSameOriginRequest } from "@/server/infrastructure/http/same-origin";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";
import { parseFirstAdminInvitationRequest } from "@/modules/identity/application/first-admin-invitation-request";

const PRIVATE_NO_STORE = { "Cache-Control": "private, no-store" };
const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function errorResponse(status: number, code: string, message: string, requestId: string) {
  return createApiErrorResponse(status, code, message, requestId, PRIVATE_NO_STORE);
}

export async function POST(request: Request, context: RouteContext<"/api/v1/tenants/[tenantId]/invitations/first-admin">) {
  const requestId = randomUUID();
  if (!isTrustedSameOriginRequest(request)) return errorResponse(403, "ORIGIN_NOT_ALLOWED", "Request origin is not allowed.", requestId);
  if (request.headers.get("content-type")?.split(";")[0]?.trim().toLowerCase() !== "application/json") {
    return errorResponse(400, "INVALID_REQUEST", "A JSON body is required.", requestId);
  }

  const { tenantId } = await context.params;
  if (!UUID_PATTERN.test(tenantId)) return errorResponse(400, "INVALID_REQUEST", "A valid Tenant is required.", requestId);

  let body: unknown;
  try { body = await request.json(); }
  catch { return errorResponse(400, "INVALID_REQUEST", "The request body must be valid JSON.", requestId); }
  const parsed = parseFirstAdminInvitationRequest(body);
  if (!parsed) return errorResponse(422, "INVALID_REQUEST", "Informe um e-mail válido e o motivo do convite.", requestId);

  try {
    const supabase = await createSupabaseServerClient();
    const { data: auth, error: authError } = await supabase.auth.getClaims();
    if (authError || typeof auth?.claims?.sub !== "string") {
      return errorResponse(401, "UNAUTHENTICATED", "Entre na sua conta para continuar.", requestId);
    }

    const token = randomBytes(32).toString("base64url");
    const tokenHash = createHash("sha256").update(token).digest("hex");
    const { data, error } = await supabase.rpc("create_first_tenant_admin_invitation", {
      p_tenant_id: tenantId,
      p_email: parsed.email,
      p_token_hash: `\\x${tokenHash}`,
      p_reason: parsed.reason,
    });
    if (error) {
      if (error.code === "42501") return errorResponse(403, "FORBIDDEN", "Você não pode convidar o primeiro administrador desta organização.", requestId);
      if (error.code === "23505") return errorResponse(409, "ALREADY_ACTIVATED", "O primeiro administrador já foi ativado.", requestId);
      if (error.code === "22023") return errorResponse(422, "INVALID_REQUEST", "O convite não pode ser criado com esses dados.", requestId);
      return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível criar o convite agora.", requestId);
    }

    if (typeof data !== "object" || data === null || Array.isArray(data) || typeof data.invitationId !== "string") {
      return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível confirmar a criação do convite.", requestId);
    }

    const invitationUrl = new URL("/convite/aceitar", request.url);
    invitationUrl.hash = `token=${token}`;
    return Response.json({ invitation: { id: data.invitationId, url: invitationUrl.toString(), expiresAt: data.expiresAt } }, {
      status: 201,
      headers: { ...PRIVATE_NO_STORE, "Referrer-Policy": "no-referrer" },
    });
  } catch (error) { logApiFailure({ requestId, operation: "api.v1/tenants/[tenantId]/invitations/first-admin", error });
    return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível criar o convite agora.", requestId);
  }
}

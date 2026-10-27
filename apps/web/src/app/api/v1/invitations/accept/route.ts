import { createApiErrorResponse, logApiFailure } from "@/server/infrastructure/http/api-response";
import { createHash, randomUUID } from "node:crypto";
import { isTrustedSameOriginRequest } from "@/server/infrastructure/http/same-origin";
import { isValidInvitationToken } from "@/modules/identity/application/first-admin-invitation-request";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";

const PRIVATE_NO_STORE = { "Cache-Control": "private, no-store", "Referrer-Policy": "no-referrer" };

function errorResponse(status: number, code: string, message: string, requestId: string) {
  return createApiErrorResponse(status, code, message, requestId, PRIVATE_NO_STORE);
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
  if (typeof body !== "object" || body === null || Array.isArray(body) || Object.keys(body).length !== 1 || !("token" in body) || !isValidInvitationToken(body.token)) {
    return errorResponse(422, "INVALID_INVITATION", "O link do convite é inválido ou expirou.", requestId);
  }

  try {
    const supabase = await createSupabaseServerClient();
    const { data: auth, error: authError } = await supabase.auth.getClaims();
    if (authError || typeof auth?.claims?.sub !== "string") return errorResponse(401, "UNAUTHENTICATED", "Entre com a conta vinculada ao convite.", requestId);

    const tokenHash = createHash("sha256").update(body.token).digest("hex");
    const { data, error } = await supabase.rpc("accept_tenant_invitation", { p_token_hash: `\\x${tokenHash}` });
    if (error) {
      if (error.code === "42501") return errorResponse(403, "FORBIDDEN", "Entre com o e-mail confirmado ao qual o convite foi enviado.", requestId);
      if (error.code === "23505") return errorResponse(409, "INVITATION_USED", "O convite já foi utilizado ou o acesso já foi ativado.", requestId);
      if (error.code === "22023") return errorResponse(422, "INVALID_INVITATION", "O convite é inválido, expirou ou não pertence a esta conta.", requestId);
      return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível aceitar o convite agora.", requestId);
    }
    if (typeof data !== "object" || data === null || Array.isArray(data) ||
        typeof data.tenantId !== "string" || typeof data.tenantName !== "string" ||
        !["first_admin", "tenant_member"].includes(String(data.invitationKind)) ||
        (data.invitationKind === "tenant_member" && typeof data.roleKey !== "string")) {
      return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível confirmar a ativação do acesso.", requestId);
    }
    return Response.json({ tenant: {
      id: data.tenantId,
      name: data.tenantName,
      invitationKind: data.invitationKind,
      roleKey: typeof data.roleKey === "string" ? data.roleKey : null,
    } }, { headers: PRIVATE_NO_STORE });
  } catch (error) { logApiFailure({ requestId, operation: "api.v1/invitations/accept", error });
    return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível aceitar o convite agora.", requestId);
  }
}

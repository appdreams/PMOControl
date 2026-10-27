import { createApiErrorResponse, logApiFailure } from "@/server/infrastructure/http/api-response";
import { createHash, randomBytes, randomUUID } from "node:crypto";
import { parseTenantMemberInvitationRequest } from "@/modules/identity/application/tenant-member-invitation-request";
import { isTrustedSameOriginRequest } from "@/server/infrastructure/http/same-origin";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";

const PRIVATE_NO_STORE = { "Cache-Control": "private, no-store", "Referrer-Policy": "no-referrer" };
const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function errorResponse(status: number, code: string, message: string, requestId: string) {
  return createApiErrorResponse(status, code, message, requestId, PRIVATE_NO_STORE);
}

function isInvitationResult(value: unknown, roleKey: string, scopeType: string, scopeId: string): value is {
  invitationId: string; roleKey: string; expiresAt: string; scopeType: string; scopeId: string;
} {
  if (typeof value !== "object" || value === null || Array.isArray(value)) return false;
  const row = value as Record<string, unknown>;
  return typeof row.invitationId === "string" && UUID_PATTERN.test(row.invitationId) &&
    row.roleKey === roleKey && row.scopeType === scopeType && row.scopeId === scopeId &&
    typeof row.expiresAt === "string" &&
    Number.isFinite(Date.parse(row.expiresAt));
}

export async function POST(request: Request, context: RouteContext<"/api/v1/tenants/[tenantId]/invitations">) {
  const requestId = randomUUID();
  if (!isTrustedSameOriginRequest(request)) return errorResponse(403, "ORIGIN_NOT_ALLOWED", "Request origin is not allowed.", requestId);
  if (request.headers.get("content-type")?.split(";")[0]?.trim().toLowerCase() !== "application/json") {
    return errorResponse(400, "INVALID_REQUEST", "A JSON body is required.", requestId);
  }

  const { tenantId } = await context.params;
  if (!UUID_PATTERN.test(tenantId)) return errorResponse(404, "NOT_FOUND", "Organização indisponível.", requestId);

  let body: unknown;
  try { body = await request.json(); }
  catch { return errorResponse(400, "INVALID_REQUEST", "The request body must be valid JSON.", requestId); }
  const parsed = parseTenantMemberInvitationRequest(body, tenantId);
  if (!parsed) return errorResponse(422, "INVALID_REQUEST", "Informe e-mail, papel e motivo válidos.", requestId);

  try {
    const supabase = await createSupabaseServerClient();
    const { data: auth, error: authError } = await supabase.auth.getClaims();
    if (authError || typeof auth?.claims?.sub !== "string") {
      return errorResponse(401, "UNAUTHENTICATED", "Entre na sua conta para continuar.", requestId);
    }

    const token = randomBytes(32).toString("base64url");
    const tokenHash = createHash("sha256").update(token).digest("hex");
    const { data, error } = await supabase.rpc("create_tenant_member_invitation", {
      p_tenant_id: tenantId.toLowerCase(),
      p_email: parsed.email,
      p_role_key: parsed.roleKey,
      p_token_hash: `\\x${tokenHash}`,
      p_reason: parsed.reason,
      p_scope_type: parsed.scopeType,
      p_scope_id: parsed.scopeId,
    });
    if (error) {
      if (error.code === "42501") return errorResponse(403, "FORBIDDEN", "Você não pode convidar este membro com esse papel.", requestId);
      if (error.code === "22023") return errorResponse(422, "INVALID_INVITATION", "O convite não pode ser criado com esses dados.", requestId);
      if (error.code === "23505") return errorResponse(409, "CONFLICT", "Já existe uma alteração concorrente para este convite.", requestId);
      return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível criar o convite agora.", requestId);
    }
    if (!isInvitationResult(data, parsed.roleKey, parsed.scopeType, parsed.scopeId)) {
      return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível confirmar a criação do convite.", requestId);
    }

    const invitationUrl = new URL("/convite/aceitar", request.url);
    invitationUrl.hash = `token=${token}`;
    return Response.json({ invitation: {
      id: data.invitationId,
      roleKey: data.roleKey,
      scopeType: data.scopeType,
      scopeId: data.scopeId,
      url: invitationUrl.toString(),
      expiresAt: data.expiresAt,
    } }, { status: 201, headers: PRIVATE_NO_STORE });
  } catch (error) { logApiFailure({ requestId, operation: "api.v1/tenants/[tenantId]/invitations", error });
    return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível criar o convite agora.", requestId);
  }
}

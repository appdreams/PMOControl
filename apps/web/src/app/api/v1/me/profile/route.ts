import { createApiErrorResponse, logApiFailure } from "@/server/infrastructure/http/api-response";
import { randomUUID } from "node:crypto";
import { parseProfileUpdateRequest } from "@/modules/identity/application/profile-update-request";
import { isTrustedSameOriginRequest } from "@/server/infrastructure/http/same-origin";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";

const PRIVATE_NO_STORE = { "Cache-Control": "private, no-store", "Referrer-Policy": "no-referrer" };

function errorResponse(status: number, code: string, message: string, requestId: string) {
  return createApiErrorResponse(status, code, message, requestId, PRIVATE_NO_STORE);
}

function isProfile(value: unknown): value is { displayName: string; complete: boolean } {
  return typeof value === "object" && value !== null && !Array.isArray(value) &&
    typeof (value as Record<string, unknown>).displayName === "string" &&
    typeof (value as Record<string, unknown>).complete === "boolean";
}

export async function GET() {
  const requestId = randomUUID();
  try {
    const supabase = await createSupabaseServerClient();
    const { data: auth, error: authError } = await supabase.auth.getClaims();
    if (authError || typeof auth?.claims?.sub !== "string") {
      return errorResponse(401, "UNAUTHENTICATED", "Entre na sua conta para continuar.", requestId);
    }
    const { data, error } = await supabase.rpc("get_my_profile");
    if (error) return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível carregar seu perfil agora.", requestId);
    if (!isProfile(data)) return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível validar seu perfil.", requestId);
    return Response.json({ profile: data }, { headers: PRIVATE_NO_STORE });
  } catch (error) { logApiFailure({ requestId, operation: "api.v1/me/profile", error });
    return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível carregar seu perfil agora.", requestId);
  }
}

export async function PATCH(request: Request) {
  const requestId = randomUUID();
  if (!isTrustedSameOriginRequest(request)) {
    return errorResponse(403, "ORIGIN_NOT_ALLOWED", "Request origin is not allowed.", requestId);
  }
  if (request.headers.get("content-type")?.split(";")[0]?.trim().toLowerCase() !== "application/json") {
    return errorResponse(400, "INVALID_REQUEST", "A JSON body is required.", requestId);
  }

  let body: unknown;
  try { body = await request.json(); }
  catch { return errorResponse(400, "INVALID_REQUEST", "The request body must be valid JSON.", requestId); }
  const parsed = parseProfileUpdateRequest(body);
  if (!parsed) return errorResponse(400, "INVALID_REQUEST", "Informe um nome de exibição entre 2 e 120 caracteres.", requestId);

  try {
    const supabase = await createSupabaseServerClient();
    const { data: auth, error: authError } = await supabase.auth.getClaims();
    if (authError || typeof auth?.claims?.sub !== "string") {
      return errorResponse(401, "UNAUTHENTICATED", "Entre na sua conta para continuar.", requestId);
    }
    const { data, error } = await supabase.rpc("update_my_profile", { p_display_name: parsed.displayName });
    if (error) {
      if (error.code === "22023") return errorResponse(400, "INVALID_REQUEST", "Informe um nome de exibição entre 2 e 120 caracteres.", requestId);
      return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível salvar seu perfil agora.", requestId);
    }
    if (!isProfile(data)) return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível validar seu perfil salvo.", requestId);
    return Response.json({ profile: data }, { headers: PRIVATE_NO_STORE });
  } catch (error) { logApiFailure({ requestId, operation: "api.v1/me/profile", error });
    return errorResponse(503, "SERVICE_UNAVAILABLE", "Não foi possível salvar seu perfil agora.", requestId);
  }
}

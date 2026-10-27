import { createApiErrorResponse, createRequestId, logApiFailure } from "@/server/infrastructure/http/api-response";
import { isTrustedSameOriginRequest } from "@/server/infrastructure/http/same-origin";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";
import { getSupabasePublicConfig } from "@/server/infrastructure/supabase/config";

const PRIVATE_NO_STORE = { "Cache-Control": "private, no-store" };

export async function POST(request: Request) {
  const requestId = createRequestId();
  if (!isTrustedSameOriginRequest(request)) {
    return createApiErrorResponse(403, "ORIGIN_NOT_ALLOWED", "Request origin is not allowed.", requestId, PRIVATE_NO_STORE);
  }
  if (!getSupabasePublicConfig()) {
    return createApiErrorResponse(503, "SERVICE_UNAVAILABLE", "Authentication is not configured.", requestId, PRIVATE_NO_STORE);
  }

  try {
    const supabase = await createSupabaseServerClient();
    const { error } = await supabase.auth.signOut({ scope: "local" });
    if (error) throw error;
    return new Response(null, { status: 204, headers: PRIVATE_NO_STORE });
  } catch (error) {
    logApiFailure({ requestId, operation: "api.v1.auth.logout", error });
    return createApiErrorResponse(503, "SERVICE_UNAVAILABLE", "Unable to end the current session.", requestId, PRIVATE_NO_STORE);
  }
}

import "server-only";

function getConfiguredAppOrigin(): string | null {
  const configuredOrigin = process.env.APP_ORIGIN?.trim();
  if (!configuredOrigin) {
    return process.env.NODE_ENV === "production" ? null : "http://localhost:3000";
  }

  try {
    const parsed = new URL(configuredOrigin);
    const isLocalHttp = parsed.protocol === "http:" &&
      (parsed.hostname === "localhost" || parsed.hostname === "127.0.0.1");
    if (
      (parsed.protocol !== "https:" && !isLocalHttp) || parsed.username || parsed.password ||
      parsed.pathname !== "/" || parsed.search || parsed.hash
    ) {
      return null;
    }
    return parsed.origin;
  } catch {
    return null;
  }
}

/** Requires the canonical app Origin and Host; never trusts forwarded headers. */
export function isTrustedSameOriginRequest(request: Request): boolean {
  const expectedOrigin = getConfiguredAppOrigin();
  const originHeader = request.headers.get("origin");
  const hostHeader = request.headers.get("host");
  if (!expectedOrigin || !originHeader || !hostHeader) return false;

  try {
    const origin = new URL(originHeader);
    const requestHost = new URL(`${new URL(expectedOrigin).protocol}//${hostHeader}`);
    return origin.origin === expectedOrigin && requestHost.origin === expectedOrigin &&
      !requestHost.username && !requestHost.password && requestHost.host.toLowerCase() === hostHeader.toLowerCase();
  } catch {
    return false;
  }
}

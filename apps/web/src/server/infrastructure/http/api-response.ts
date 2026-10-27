import { randomUUID } from "node:crypto";

type ApiErrorHeaders = Record<string, string>;

const NO_STORE_HEADERS = {
  "Cache-Control": "private, no-store",
  "Referrer-Policy": "no-referrer",
};
const loggedRequestIds = new Set<string>();

/** Stable ID shared by the client error envelope and server-side diagnostics. */
export function createRequestId(): string {
  return randomUUID();
}

/** Builds the approved API error envelope and exposes its safe correlation ID in a header. */
export function createApiErrorResponse(
  status: number,
  code: string,
  message: string,
  requestId: string,
  headers: ApiErrorHeaders = NO_STORE_HEADERS,
): Response {
  if (status >= 500) {
    logApiFailure({
      requestId,
      operation: "api.unclassified_failure",
      error: { kind: "service_unavailable" },
    });
  }
  return Response.json(
    { error: { code, message, requestId } },
    { status, headers: { ...NO_STORE_HEADERS, ...headers, "X-Request-Id": requestId } },
  );
}

/** Logs only safe diagnostic fields. Never serialize an exception message, stack, or request body. */
export function logApiFailure(input: {
  requestId: string;
  operation: string;
  error: unknown;
  dependencyCode?: unknown;
}): void {
  if (loggedRequestIds.has(input.requestId)) return;
  loggedRequestIds.add(input.requestId);
  if (loggedRequestIds.size > 1024) {
    const oldestRequestId = loggedRequestIds.values().next().value;
    if (oldestRequestId) loggedRequestIds.delete(oldestRequestId);
  }

  const rawName = input.error instanceof Error ? input.error.name : "UnknownError";
  const errorType = /^[A-Za-z][A-Za-z0-9_]{0,63}$/.test(rawName) ? rawName : "UnknownError";
  const dependencyCode = typeof input.dependencyCode === "string" && /^[0-9A-Z]{5}$/.test(input.dependencyCode)
    ? input.dependencyCode
    : undefined;

  console.error(JSON.stringify({
    event: "api.unexpected_failure",
    requestId: input.requestId,
    operation: input.operation,
    errorType,
    ...(dependencyCode ? { dependencyCode } : {}),
  }));
}

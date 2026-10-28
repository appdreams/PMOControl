export type VersionedReasonRequest = Readonly<{
  expectedVersion: number;
  reason: string;
  idempotencyKey: string;
}>;

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const SENSITIVE_REASON_PATTERN = /(password|passwd|token|secret|cookie|authorization|credential|api[_-]?key)\s*[:=]\s*\S+|(^|\s)Bearer\s+[a-z0-9._~-]{20,}|[a-z0-9_-]{10,}\.[a-z0-9_-]{10,}\.[a-z0-9_-]{10,}/i;

export function isUuid(value: unknown): value is string {
  return typeof value === "string" && UUID_PATTERN.test(value);
}

export function parseVersionedReasonRequest(value: unknown): VersionedReasonRequest | null {
  if (typeof value !== "object" || value === null || Array.isArray(value)) return null;
  const body = value as Record<string, unknown>;
  if (Object.keys(body).length !== 3 || !Number.isSafeInteger(body.expectedVersion) ||
      (body.expectedVersion as number) < 1 || typeof body.reason !== "string" ||
      !isUuid(body.idempotencyKey)) return null;
  const reason = body.reason.trim();
  if (reason.length < 1 || reason.length > 1000 || SENSITIVE_REASON_PATTERN.test(reason)) return null;
  return {
    expectedVersion: body.expectedVersion as number,
    reason,
    idempotencyKey: body.idempotencyKey.toLowerCase(),
  };
}

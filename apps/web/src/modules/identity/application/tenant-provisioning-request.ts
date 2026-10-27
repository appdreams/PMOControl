export type TenantProvisioningRequest = Readonly<{
  displayName: string;
  reason: string;
  idempotencyKey: string;
}>;

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

/** Accepts only user-controlled fields; identifiers are derived by the server. */
export function parseTenantProvisioningRequest(value: unknown): TenantProvisioningRequest | null {
  if (typeof value !== "object" || value === null || Array.isArray(value)) return null;
  const body = value as Record<string, unknown>;
  const allowedKeys = ["displayName", "reason", "idempotencyKey"];
  if (Object.keys(body).length !== allowedKeys.length || !Object.keys(body).every((key) => allowedKeys.includes(key))) {
    return null;
  }
  if (
    typeof body.displayName !== "string" || body.displayName !== body.displayName.trim() ||
    body.displayName.length < 1 || body.displayName.length > 160 ||
    typeof body.reason !== "string" || body.reason !== body.reason.trim() ||
    body.reason.length < 1 || body.reason.length > 1000 ||
    typeof body.idempotencyKey !== "string" || !UUID_PATTERN.test(body.idempotencyKey)
  ) return null;

  return {
    displayName: body.displayName,
    reason: body.reason,
    idempotencyKey: body.idempotencyKey,
  };
}

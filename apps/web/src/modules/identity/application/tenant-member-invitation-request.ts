const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const ROLE_KEY_PATTERN = /^[a-z][a-z0-9_.-]{1,79}$/;

export type TenantMemberInvitationRequest = Readonly<{
  email: string;
  roleKey: string;
  reason: string;
  scopeType: "tenant" | "portfolio" | "project";
  scopeId: string;
}>;

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

export function parseTenantMemberInvitationRequest(value: unknown, tenantId: string): TenantMemberInvitationRequest | null {
  if (typeof value !== "object" || value === null || Array.isArray(value)) return null;
  const body = value as Record<string, unknown>;
  const keys = Object.keys(body);
  const legacyShape = keys.length === 3 && !Object.hasOwn(body, "scopeType") && !Object.hasOwn(body, "scopeId");
  const scopedShape = keys.length === 5 && Object.hasOwn(body, "scopeType") && Object.hasOwn(body, "scopeId");
  if ((!legacyShape && !scopedShape) || !Object.hasOwn(body, "email") ||
      !Object.hasOwn(body, "roleKey") || !Object.hasOwn(body, "reason")) return null;
  if (typeof body.email !== "string" || typeof body.roleKey !== "string" || typeof body.reason !== "string") return null;

  const email = body.email.trim().toLowerCase();
  const roleKey = body.roleKey.trim();
  const reason = body.reason.trim();
  const scopeType = legacyShape ? "tenant" : body.scopeType;
  const scopeId = legacyShape ? tenantId.toLowerCase() : body.scopeId;
  if (!EMAIL_PATTERN.test(email) || email.length > 320 || !ROLE_KEY_PATTERN.test(roleKey) ||
      reason.length < 1 || reason.length > 1000 ||
      (scopeType !== "tenant" && scopeType !== "portfolio" && scopeType !== "project") ||
      typeof scopeId !== "string" || !UUID_PATTERN.test(scopeId) ||
      (scopeType === "tenant" && scopeId.toLowerCase() !== tenantId.toLowerCase())) return null;
  return { email, roleKey, reason, scopeType, scopeId: scopeId.toLowerCase() };
}

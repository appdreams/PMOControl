const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export type FirstAdminInvitationRequest = Readonly<{ email: string; reason: string }>;

export function parseFirstAdminInvitationRequest(value: unknown): FirstAdminInvitationRequest | null {
  if (typeof value !== "object" || value === null || Array.isArray(value)) return null;
  const body = value as Record<string, unknown>;
  if (Object.keys(body).length !== 2 || !Object.hasOwn(body, "email") || !Object.hasOwn(body, "reason")) return null;
  if (typeof body.email !== "string" || typeof body.reason !== "string") return null;

  const email = body.email.trim().toLowerCase();
  const reason = body.reason.trim();
  if (!EMAIL_PATTERN.test(email) || email.length > 320 || reason.length < 1 || reason.length > 1000) return null;
  return { email, reason };
}

export function isValidInvitationToken(value: unknown): value is string {
  return typeof value === "string" && /^[A-Za-z0-9_-]{43}$/.test(value);
}

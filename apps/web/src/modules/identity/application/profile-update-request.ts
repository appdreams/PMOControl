export type ProfileUpdateRequest = { displayName: string };

export function parseProfileUpdateRequest(body: unknown): ProfileUpdateRequest | null {
  if (typeof body !== "object" || body === null || Array.isArray(body)) return null;
  const record = body as Record<string, unknown>;
  if (Object.keys(record).length !== 1 || typeof record.displayName !== "string") return null;
  const displayName = record.displayName.trim();
  if (record.displayName !== displayName || displayName.length < 2 || displayName.length > 120) return null;
  return { displayName };
}

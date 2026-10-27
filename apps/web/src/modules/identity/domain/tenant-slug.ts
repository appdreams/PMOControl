/** Converts an organization name into the stable, URL-safe Tenant identifier. */
export function generateTenantSlug(displayName: string): string | null {
  if (typeof displayName !== "string") return null;

  const slug = displayName
    .normalize("NFKD")
    .replace(/\p{M}/gu, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 63)
    .replace(/-+$/g, "");

  return slug.length >= 3 ? slug : null;
}

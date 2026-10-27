import { getPermissionDefinition } from "./permission-catalog";
import type { AuthorizationDecision } from "./authorization";

/** Effective platform-scoped permission after trusted role expansion. */
export type PlatformAccessGrant = Readonly<{
  tenantId: null;
  subjectId: string;
  permission: string;
  scopeType: "platform";
  scopeId: "platform";
  effect: "allow" | "deny";
  startsAt: number;
  expiresAt: number | null;
  revokedAt: number | null;
}>;

export type PlatformAuthorizationInput = Readonly<{
  actor: { id: string; active: boolean; sessionValid: boolean } | null;
  permission: string;
  grants: readonly PlatformAccessGrant[];
  /** Server clock, epoch milliseconds. Grant validity is [startsAt, expiresAt). */
  now: number;
}>;

const isRecord = (value: unknown): value is Record<string, unknown> =>
  typeof value === "object" && value !== null && !Array.isArray(value);

/**
 * Evaluates platform permissions independently from Tenant membership.
 * The adapter must verify the session and expand platform roles from trusted DB rows.
 */
export function authorizePlatform(input: PlatformAuthorizationInput): AuthorizationDecision {
  if (!isRecord(input) || !Array.isArray(input.grants)) {
    return { allowed: false, reason: "invalid_context" };
  }

  const { actor, permission, now } = input;
  const definition = typeof permission === "string" ? getPermissionDefinition(permission) : null;
  if (
    !actor?.id || actor.active !== true || actor.sessionValid !== true ||
    !definition || !definition.scopeTypes.includes("platform") || !Number.isFinite(now)
  ) {
    return { allowed: false, reason: "invalid_context" };
  }

  let hasAllow = false;
  for (const grant of input.grants) {
    if (!isRecord(grant)) return { allowed: false, reason: "invalid_context" };
    if (grant.subjectId !== actor.id || grant.permission !== permission || grant.scopeType !== "platform") {
      continue;
    }

    const startsAt = grant.startsAt;
    const expiresAt = grant.expiresAt;
    const revokedAt = grant.revokedAt;
    if (
      grant.tenantId !== null || grant.scopeId !== "platform" ||
      (grant.effect !== "allow" && grant.effect !== "deny") ||
      typeof startsAt !== "number" || !Number.isFinite(startsAt) ||
      (expiresAt !== null && (typeof expiresAt !== "number" || !Number.isFinite(expiresAt) || expiresAt <= startsAt)) ||
      (revokedAt !== null && (typeof revokedAt !== "number" || !Number.isFinite(revokedAt)))
    ) {
      return { allowed: false, reason: "invalid_context" };
    }

    if (revokedAt !== null || startsAt > now || (expiresAt !== null && now >= expiresAt)) continue;
    if (grant.effect === "deny") return { allowed: false, reason: "explicit_deny" };
    hasAllow = true;
  }

  return hasAllow
    ? { allowed: true, reason: "allowed" }
    : { allowed: false, reason: "no_grant" };
}

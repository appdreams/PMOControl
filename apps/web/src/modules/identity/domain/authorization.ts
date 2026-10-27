import { getPermissionDefinition } from "./permission-catalog.ts";

/** Pure policy evaluation. Inputs MUST be freshly resolved by trusted server adapters.
 * This function neither verifies sessions nor makes client-supplied context trustworthy.
 * Initial slice: exact tenant scopes only; inheritance and platform commands fail closed.
 */
export type Scope = Readonly<{
  type: "tenant" | "portfolio" | "project" | "resource" | "item";
  id: string;
}>;

export type AccessGrant = Readonly<{
  tenantId: string;
  subjectId: string;
  permission: string;
  scope: Scope;
  effect: "allow" | "deny";
  startsAt: number;
  expiresAt: number | null;
  revokedAt: number | null;
}>;

export type AuthorizationInput = Readonly<{
  actor: { id: string; active: boolean; sessionValid: boolean } | null;
  tenant: { id: string; status: string } | null;
  membership: { userId: string; tenantId: string; status: string } | null;
  resource: { tenantId: string; scope: Scope };
  permission: string;
  dataPolicyAllows: boolean;
  workflowAllows: boolean;
  grants: readonly AccessGrant[];
  /** Server clock, epoch milliseconds. Grant validity is [startsAt, expiresAt). */
  now: number;
}>;

export type AuthorizationDecision = Readonly<{
  allowed: boolean;
  /** Internal reason only. Public boundaries must not enumerate resources. */
  reason: "allowed" | "invalid_context" | "policy_denied" | "explicit_deny" | "no_grant";
}>;

const isRecord = (value: unknown): value is Record<string, unknown> =>
  typeof value === "object" && value !== null && !Array.isArray(value);

const isScope = (value: unknown): value is Scope => {
  if (!isRecord(value)) return false;
  return ["tenant", "portfolio", "project", "resource", "item"].includes(String(value.type)) &&
    typeof value.id === "string" && value.id.trim().length > 0;
};

export function authorize(input: AuthorizationInput): AuthorizationDecision {
  if (!isRecord(input) || !Array.isArray(input.grants)) {
    return { allowed: false, reason: "invalid_context" };
  }
  const { actor, tenant, membership, resource, permission, now } = input;
  const permissionDefinition = typeof permission === "string"
    ? getPermissionDefinition(permission)
    : null;
  if (
    !actor?.id || actor.active !== true || actor.sessionValid !== true ||
    !tenant?.id || tenant.status !== "active" ||
    !membership || membership.status !== "active" ||
    membership.userId !== actor.id || membership.tenantId !== tenant.id ||
    !isRecord(resource) || resource.tenantId !== tenant.id || !isScope(resource.scope) ||
    (resource.scope.type === "tenant" && resource.scope.id !== tenant.id) ||
    !permissionDefinition || permission.startsWith("platform.") ||
    !permissionDefinition.scopeTypes.includes(resource.scope.type) ||
    !Number.isFinite(now)
  ) {
    return { allowed: false, reason: "invalid_context" };
  }
  if (input.dataPolicyAllows !== true || input.workflowAllows !== true) {
    return { allowed: false, reason: "policy_denied" };
  }

  let hasAllow = false;
  for (const grant of input.grants) {
    if (!isRecord(grant)) return { allowed: false, reason: "invalid_context" };
    if (
      grant.tenantId !== tenant.id || grant.subjectId !== actor.id ||
      grant.permission !== permission || grant.revokedAt !== null
    ) continue;
    // Corrupt matching lifecycle data must never silently remove a deny.
    const startsAt = grant.startsAt;
    const expiresAt = grant.expiresAt;
    if (!isScope(grant.scope) || typeof startsAt !== "number" || !Number.isFinite(startsAt) ||
      (expiresAt !== null && (typeof expiresAt !== "number" || !Number.isFinite(expiresAt) || expiresAt <= startsAt)) ||
      (grant.effect !== "allow" && grant.effect !== "deny")) {
      return { allowed: false, reason: "invalid_context" };
    }
    if (startsAt > now || (expiresAt !== null && now >= expiresAt)) continue;
    if (grant.scope.type !== resource.scope.type || grant.scope.id !== resource.scope.id) {
      // Until trusted ancestry is implemented, a potentially intersecting deny
      // blocks conservatively. Never discard it merely because scope differs.
      if (grant.effect === "deny") return { allowed: false, reason: "policy_denied" };
      continue;
    }
    if (grant.effect === "deny") return { allowed: false, reason: "explicit_deny" };
    hasAllow = true;
  }
  return hasAllow
    ? { allowed: true, reason: "allowed" }
    : { allowed: false, reason: "no_grant" };
}

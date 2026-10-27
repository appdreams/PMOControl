import { authorize, type AccessGrant, type Scope } from "./authorization.ts";
import { getPermissionDefinition } from "./permission-catalog.ts";

export type DelegationRole = Readonly<{
  id: string;
  tenantId: string | null;
  scopeType: "tenant" | "platform";
  status: "active" | "retired";
  permissions: readonly string[];
}>;

export type DelegationInput = Readonly<{
  actor: { id: string; active: boolean; sessionValid: boolean } | null;
  tenant: { id: string; status: string } | null;
  membership: { userId: string; tenantId: string; status: string } | null;
  targetRole: DelegationRole | null;
  targetScope: Scope;
  targetScopeTenantId: string | null;
  grants: readonly AccessGrant[];
  now: number;
}>;

export type DelegationDecision = Readonly<{
  allowed: boolean;
  reason: "allowed" | "invalid_context" | "invite_permission_missing" | "delegation_ceiling";
}>;

/**
 * A preset can contain permissions for several resource kinds. Only permissions
 * whose catalog explicitly supports the selected scope are effective there;
 * callers must persist the grant at that exact scope. Unknown/platform
 * permissions invalidate the role instead of being silently ignored.
 */
export function getRolePermissionsForScope(
  permissions: readonly string[],
  scopeType: Scope["type"],
): readonly string[] | null {
  if (!Array.isArray(permissions) || permissions.length === 0 ||
      new Set(permissions).size !== permissions.length) return null;

  const applicable: string[] = [];
  for (const permission of permissions) {
    const definition = typeof permission === "string" ? getPermissionDefinition(permission) : null;
    if (!definition || permission.startsWith("platform.")) return null;
    if (definition.scopeTypes.includes(scopeType)) applicable.push(permission);
  }
  return applicable.length > 0 ? applicable : null;
}

const DENIED = (reason: DelegationDecision["reason"]): DelegationDecision => ({ allowed: false, reason });

function isScope(value: unknown): value is Scope {
  if (typeof value !== "object" || value === null || Array.isArray(value)) return false;
  const scope = value as Record<string, unknown>;
  return ["tenant", "portfolio", "project", "resource", "item"].includes(String(scope.type)) &&
    typeof scope.id === "string" && scope.id.trim().length > 0;
}

/**
 * Checks an allow-role assignment against freshly resolved server facts.
 * The issuer needs membership.invite at the exact Tenant scope and must
 * independently hold every permission applicable to the selected scope at
 * that exact resource. Permissions for other scope types do not apply there.
 * No Tenant/Portfolio/Project inheritance is assumed.
 */
export function canDelegateRole(input: DelegationInput): DelegationDecision {
  if (!input || !Array.isArray(input.grants) || !Array.isArray(input.targetRole?.permissions) ||
      !Number.isFinite(input.now) || !input.tenant?.id || !isScope(input.targetScope) ||
      input.targetScopeTenantId !== input.tenant.id ||
      (input.targetScope.type === "tenant" && input.targetScope.id !== input.tenant.id)) {
    return DENIED("invalid_context");
  }

  const role = input.targetRole;
  const scopedPermissions = getRolePermissionsForScope(role.permissions, input.targetScope.type);
  if (
    !role.id || role.status !== "active" || role.scopeType !== "tenant" ||
    role.tenantId !== input.tenant.id || !scopedPermissions
  ) {
    return DENIED("invalid_context");
  }

  const inviteDecision = authorize({
    actor: input.actor,
    tenant: input.tenant,
    membership: input.membership,
    resource: { tenantId: input.tenant.id, scope: { type: "tenant", id: input.tenant.id } },
    permission: "membership.invite",
    dataPolicyAllows: true,
    workflowAllows: true,
    grants: input.grants,
    now: input.now,
  });
  if (!inviteDecision.allowed) {
    return DENIED(inviteDecision.reason === "invalid_context" ? "invalid_context" : "invite_permission_missing");
  }

  for (const permission of scopedPermissions) {
    const decision = authorize({
      actor: input.actor,
      tenant: input.tenant,
      membership: input.membership,
      resource: { tenantId: input.tenant.id, scope: input.targetScope },
      permission,
      dataPolicyAllows: true,
      workflowAllows: true,
      grants: input.grants,
      now: input.now,
    });
    if (!decision.allowed) return DENIED("delegation_ceiling");
  }

  return { allowed: true, reason: "allowed" };
}

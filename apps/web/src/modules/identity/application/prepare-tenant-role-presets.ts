import {
  getPermissionDefinition,
  PERMISSION_CATALOG_VERSION,
  ROLE_PRESETS,
  type PermissionKey,
  type RolePresetKey,
} from "../domain/permission-catalog";

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export type TenantRolePresetRow = Readonly<{
  tenantId: string;
  key: RolePresetKey;
  name: string;
  scopeType: "tenant";
  isSystem: true;
  status: "active";
}>;

export type TenantRolePermissionRow = Readonly<{
  tenantId: string;
  roleKey: RolePresetKey;
  permissionKey: PermissionKey;
}>;

export type TenantRoleMaterializationPlan = Readonly<{
  catalogVersion: typeof PERMISSION_CATALOG_VERSION;
  tenantId: string;
  roles: readonly TenantRolePresetRow[];
  rolePermissions: readonly TenantRolePermissionRow[];
}>;

export type TenantRoleMaterializationPlanResult =
  | { ok: true; plan: TenantRoleMaterializationPlan }
  | { ok: false; reason: "invalid_tenant_id" | "invalid_role_catalog" };

/**
 * Builds deterministic Tenant-scoped preset rows for the trusted onboarding
 * transaction. This planner does not authenticate the actor or write the DB.
 */
export function prepareTenantRolePresets(tenantId: string): TenantRoleMaterializationPlanResult {
  if (typeof tenantId !== "string" || !UUID_PATTERN.test(tenantId)) {
    return { ok: false, reason: "invalid_tenant_id" };
  }

  const roles: TenantRolePresetRow[] = [];
  const rolePermissions: TenantRolePermissionRow[] = [];

  for (const [presetKey, preset] of Object.entries(ROLE_PRESETS)) {
    if (preset.scopeType !== "tenant") continue;

    const roleKey = presetKey as RolePresetKey;

    roles.push({
      tenantId,
      key: roleKey,
      name: preset.name,
      scopeType: "tenant",
      isSystem: true,
      status: "active",
    });

    const permissionKeys = [...new Set(preset.initialPermissions)].sort();
    for (const permissionKey of permissionKeys) {
      const definition = getPermissionDefinition(permissionKey);
      if (!definition || definition.scopeTypes.includes("platform")) {
        return { ok: false, reason: "invalid_role_catalog" };
      }

      rolePermissions.push({ tenantId, roleKey, permissionKey });
    }
  }

  if (roles.length === 0) return { ok: false, reason: "invalid_role_catalog" };

  roles.sort((left, right) => left.key.localeCompare(right.key));
  rolePermissions.sort((left, right) =>
    left.roleKey.localeCompare(right.roleKey) || left.permissionKey.localeCompare(right.permissionKey),
  );

  return {
    ok: true,
    plan: {
      catalogVersion: PERMISSION_CATALOG_VERSION,
      tenantId,
      roles,
      rolePermissions,
    },
  };
}

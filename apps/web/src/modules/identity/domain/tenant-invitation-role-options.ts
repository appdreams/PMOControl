import { getPermissionDefinition, ROLE_PRESETS, type RolePresetKey } from "./permission-catalog.ts";

/**
 * Client-side hint only. The invitation RPC remains authoritative and rechecks
 * both the actor's effective grant ceiling and the selected Tenant scope.
 */
export function getDelegableTenantInvitationRoleKeys(issuerRoleKeys: readonly string[]): RolePresetKey[] {
  const issuerPermissions = new Set(
    issuerRoleKeys.flatMap((roleKey) => ROLE_PRESETS[roleKey as RolePresetKey]?.initialPermissions ?? []),
  );

  return (Object.keys(ROLE_PRESETS) as RolePresetKey[]).filter((roleKey) => {
    const targetPermissions = ROLE_PRESETS[roleKey].initialPermissions;
    return targetPermissions.every((permissionKey) =>
      issuerPermissions.has(permissionKey) &&
      getPermissionDefinition(permissionKey)?.scopeTypes.includes("tenant"),
    );
  });
}

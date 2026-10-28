-- F1-03: cover the final RBAC catalog foreign key with an index.
CREATE INDEX tenant_role_preset_permissions_permission_key_idx
  ON private.tenant_role_preset_permissions (permission_key);

# SPEC-003 — RBAC & Contextual Authorization — Database

**Status:** Draft — logical tables aligned with canonical access catalog

Canonical tables: `roles`, `permissions`, `role_permissions`, `access_grants`, `memberships`. `access_grants` includes `tenant_id, subject_id, role_id, scope_type, scope_id, effect, granted_by, reason, starts_at, expires_at, revoked_at, version`. System roles have `tenant_id IS NULL`; Tenant-specific grants always carry Tenant ID.

Constraints: allowed `effect IN ('allow','deny')`; valid scope types; role/scope Tenant consistency; unique active grant key `(tenant_id, subject_id, role_id, scope_type, scope_id, permission/effect)` as catalog design permits; `expires_at > starts_at`; immutable issuer/reason after creation except controlled revocation metadata. Permission catalog is deployed/versioned with application, not user-editable.

Indexes: `(tenant_id,subject_id,revoked_at,expires_at)`, `(tenant_id,scope_type,scope_id)`, role-permission lookup. RLS denies absent verified actor context. Grant-management writes check delegation ceiling in application and commit audit event atomically. Authorization decision cache is non-authoritative and invalidated on membership/grant/policy changes.

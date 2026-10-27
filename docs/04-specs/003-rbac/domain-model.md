# SPEC-003 — RBAC & Contextual Authorization — Domain Model

**Status:** Draft — authorization primitives and boundaries defined

## Entities

- `Role(id, tenant_id nullable, key, name, is_system, status)` — system templates platform-defined; customer role editor excluded from MVP. Platform roles are system-owned and only usable at the platform scope; Tenant roles belong to one Tenant.
- `Permission(key, resource_type, action, data_classification, is_sensitive)` — catalog owned by application release.
- `RolePermission(role_id, permission_key)` — maps template capability; never bypasses resource scope.
- `AccessGrant(id, tenant_id, subject_id, role_id, scope_type, scope_id, effect, granted_by, reason, starts_at, expires_at, revoked_at, version)` assigns a role; it does not store a permission key. Effective permission grants are derived by expanding `RolePermission` and applying deny precedence after scope resolution.
- `AuthorizationDecision(actor_id, tenant_id, resource, action, result, policy_version, reason_code, correlation_id)` — ephemeral/diagnostic; retain minimal audit-worthy denials only.

## Evaluation and precedence

1. Resolve authenticated actor and active membership.
2. Resolve target resource and Tenant/scope ancestry from the database.
3. Collect only grants valid now and in that ancestry; inheritance requires explicit scope rule.
4. Require permission key plus data policy; check workflow/domain state.
5. Explicit deny overrides allow; otherwise missing grant denies.
6. Return minimal decision reason; do not reveal cross-tenant resource existence.

## Invariants

- Tenant boundary is absolute; no grant crosses Tenant.
- Role name alone never authorizes; grant is scoped and time-bounded when needed.
- Delegation ceiling prevents privilege escalation.
- Revoked/expired membership or grant denies immediately on next check.
- AI/exports/jobs receive no wider context than initiating actor.

## Delegation ceiling implementation

`apps/web/src/modules/identity/domain/delegation.ts` implements a pure check for a proposed allow-role assignment. The issuer must have `membership.invite` at the exact Tenant scope and must hold every permission in the target role at the exact target scope under the same active-membership, time-window, and deny rules used by `authorize`. The target role must be active and Tenant-owned; a trusted resource resolver must confirm that the requested scope belongs to the current Tenant. Each permission must support the requested scope type. The function consumes trusted server-resolved grants; it is not an authorization boundary until a database transaction/RPC invokes equivalent checks against current rows.

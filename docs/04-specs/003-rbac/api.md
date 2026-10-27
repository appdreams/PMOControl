# SPEC-003 — RBAC & Contextual Authorization — API

**Status:** Draft — logical grant APIs; schema/policy versioning pending

## User/admin routes

- `GET /api/v1/access-grants`: list grants visible to administrator's Tenant/scope; allowlisted filters for subject, role, scope, status.
- `POST /api/v1/access-grants`: Tenant role assignment through the established delegation ceiling.
- `POST /api/v1/tenants/{tenantId}/resource-grants`: implemented for `subjectId, roleKey, scopeType, scopeId, reason, idempotencyKey`; assigns only `pmo_admin|pmo|project_manager|contributor|executive|viewer` to another active member, at an active same-Tenant Portfolio or Project. The DB resolves the resource, requires active Tenant-scoped `membership.grant` with deny precedence, rejects self-assignment and tenant-admin grants at resource scope, checks role compatibility against the versioned scope catalog, and commits grant + audit atomically. `membership.grant` is present only in Tenant Admin and PMO Admin presets. Workspace exposes the assignment form; resource CRUD remains pending.
- `GET /api/v1/tenants/{tenantId}/resource-grant-targets`: returns only active same-Tenant Portfolio/Project IDs and labels to a caller with active `membership.grant` and no active deny; the workspace form uses this minimal list.
- `POST /api/v1/access-grants/{id}/revoke`: revoke grant; idempotent; invalidate applicable authorization caches.
- `GET /api/v1/roles`: list available system role templates for current Tenant; no arbitrary role/permission creation in MVP.
- `GET /api/v1/session/permissions`: return caller's effective permission keys for selected Tenant/scope, omitting resource existence outside caller scope.

The authoritative boundaries are the private grant functions behind authenticated public RPC wrappers. Ordinary member invitation issue/acceptance enforces the delegation ceiling at the exact Tenant/Portfolio/Project scope. First-admin acceptance continues through its dedicated helper.

## Internal decision service

`authorize(actor, action, resource)` is an internal server/service call, not a client-controlled endpoint. It resolves Tenant/scope from authoritative resource records; callers cannot supply trusted role/grant resolution results.

## Errors and consistency

`401` unauthenticated; `403` insufficient grant/delegation; `404` hidden out-of-scope grant; `409` concurrent grant/revocation; `422` invalid scope/role/time range; `429` rate limit. Writes use expected version/idempotency where retried. Grant write and audit event commit atomically. Decision caches are keyed by actor+tenant+scope+permission+policy version and invalidated on revocation.

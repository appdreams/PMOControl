# SPEC-003 — RBAC & Contextual Authorization — API

**Status:** Draft — logical grant APIs; schema/policy versioning pending

## User/admin routes

- `GET /api/v1/access-grants`: list grants visible to administrator's Tenant/scope; allowlisted filters for subject, role, scope, status.
- `POST /api/v1/access-grants`: create grant with `subjectId, roleKey, scopeType, scopeId, effect, reason, startsAt, expiresAt`; server derives issuer/Tenant and validates delegation ceiling.
- `POST /api/v1/access-grants/{id}/revoke`: revoke grant; idempotent; invalidate applicable authorization caches.
- `GET /api/v1/roles`: list available system role templates for current Tenant; no arbitrary role/permission creation in MVP.
- `GET /api/v1/session/permissions`: return caller's effective permission keys for selected Tenant/scope, omitting resource existence outside caller scope.

## Internal decision service

`authorize(actor, action, resource)` is an internal server/service call, not a client-controlled endpoint. It resolves Tenant/scope from authoritative resource records; callers cannot supply trusted role/grant resolution results.

## Errors and consistency

`401` unauthenticated; `403` insufficient grant/delegation; `404` hidden out-of-scope grant; `409` concurrent grant/revocation; `422` invalid scope/role/time range; `429` rate limit. Writes use expected version/idempotency where retried. Grant write and audit event commit atomically. Decision caches are keyed by actor+tenant+scope+permission+policy version and invalidated on revocation.

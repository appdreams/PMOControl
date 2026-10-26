# Screen — Tenant Management

**Status:** Draft — MVP behavior mapped to SPEC-002

## Purpose and users

Platform operations manages tenant provisioning, suspension/reactivation, export-first termination and quota visibility. Tenant Admin sees only the tenant's own profile and cannot create, suspend or terminate a tenant.

## Actions and states

- Create Tenant and its first Tenant Admin membership.
- Suspend/reactivate with required reason and confirmation; display impact on active sessions and integrations.
- Start termination; show export generation, ready artifact, validation receipt, 90-day purge countdown, legal hold and final purge state.
- Show loading, empty, forbidden, conflict, export-failed, export-ready, legal-hold and completed states. Never display customer content to Platform Admin by default.

## Behavioral trace

`SPEC-002 FR-002-01/02/05 → tenant.lifecycle.create|suspend|terminate (Platform Team only) → tenant provision/lifecycle/export APIs → AC-002-01–05 → TC-002-01–08`.

## Security

Tenant ID and actor are server-derived. Every lifecycle transition requires platform permission, reason, audit event and idempotent command. Termination cannot begin purge until export is ready; legal hold blocks the covered purge scope.

Behavioral contract trace: [SCREEN-TRACEABILITY.md](../../SCREEN-TRACEABILITY.md).

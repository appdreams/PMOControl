# SPEC-002 — Multi-Tenancy — Events

**Status:** Draft — tenant lifecycle events

`TenantCreated`, `TenantSuspended`, `TenantTerminationStarted`, `TenantExportReady`, `TenantExportDisputed`, `TenantExportDisputeResolved`, `TenantAdminTransferred`, `TenantTerminated`, `MembershipGranted`, `MembershipRevoked`. Include tenant, actor, state transition, reason, correlation/version and timestamp. Export event includes artifact identity/checksum, never export content. Purge completion records scope and result without payload. Events are appended with authoritative state transition and consumers are idempotent.

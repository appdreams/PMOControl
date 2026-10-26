# SPEC-027 — Audit Log — Events

**Status:** Draft — audit records are written by domain commands

Audit Log does not emit generic `AuditCreated/Updated/Archived` events. It stores append-only audit records produced by other domain operations: tenant lifecycle/membership/grant changes, baseline/forecast/financial changes, status publication/correction, RAG override, decisions, support access, sensitive export, document access and import application.

Audit append is part of the source transaction/outbox where required. Envelope records actor, tenant, action, resource, occurred_at, correlation ID and payload version; before/after data is allowlisted/redacted. Secrets and full confidential payloads are excluded. Querying the log is not a new business event; access to the log itself may produce minimized security telemetry.

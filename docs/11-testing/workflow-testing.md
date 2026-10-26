# Workflow Testing

**Status:** Draft — workflows de domínio em alinhamento

## Status (MVP)

Draft → Validate → Publish directly by explicitly authorized Project Manager → Immutable Snapshot. Correction requires `status.update.correct` + reason and creates a successor publication. Under Review/PMO Review is future scope, not a required MVP transition.

## Baseline

Change Request → Review/Approval → New Version.

## Decision

Request → Approve/Reject/Defer according to decision permissions.

## Import

Upload → Staging → Validate → Preview → Confirm → Apply.

## Testar

Transições válidas/inválidas, permission/scope, Tenant isolation, idempotency, optimistic concurrency, atomic commit, immutable history, correction successor, audit e post-commit retries.

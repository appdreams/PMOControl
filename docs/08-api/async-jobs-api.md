# Async Jobs API

**Status:** Approved

## Use cases

Reports, exports, imports, notifications, integration sync and AI tasks
that should not block request lifecycle.

## Pattern

Command → authoritative commit where applicable → enqueue Inngest → job
execution → persisted result/status.

## Job state

Queued / Running / Succeeded / Failed / Cancelled where supported.

## Requirements

Tenant context, idempotency, correlation ID, retry policy and
authorization of result retrieval.

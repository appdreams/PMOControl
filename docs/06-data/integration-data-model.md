# Integration Data Model

**Status:** Approved

## Tables

### `integration_connections`

Tenant, provider, status, configuration metadata, secret reference, last
health/sync timestamps.

### `external_mappings`

Maps internal entity IDs to provider/resource/external IDs.

### `webhook_receipts`

Provider event ID, tenant/connection, signature validation status,
received timestamp, processing status and idempotency key.

## Source authority

Every integration must define whether PMO Control, external provider or
a governed merge process is authoritative for each field/entity.

## Idempotency

Inbound events and sync jobs must be replay-safe.

## Conflict handling

Conflicts must not silently overwrite governed state. Record conflict
context and require workflow resolution where necessary.

## Security

Never place provider secrets in business-readable JSON. Webhooks require
validation, replay protection and tenant resolution before mutation.

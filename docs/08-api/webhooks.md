# Webhooks

**Status:** Approved

## Inbound

Verify signature → replay/timestamp check → resolve connection/tenant →
validate schema → idempotency check → enqueue/process → audit/telemetry.

## Outbound

Future outbound webhooks require explicit tenant configuration, signed
payloads, retry/backoff and delivery status.

## Response

Acknowledge safely without exposing internals.

## Failure

External failure never corrupts authoritative PMO Control state.

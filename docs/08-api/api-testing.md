# API Testing

**Status:** Approved

## Contract

Validate request/response schemas and documented error codes.

## Authorization

Every sensitive endpoint tests: - authorized same scope; - unauthorized
scope; - different tenant; - revoked membership; - forged resource ID.

## Workflow

Test invalid transitions, concurrency conflicts and idempotent retries.

## Integration

Test signature/replay/idempotency and provider failure.

## AI

Test unauthorized grounding, proposal confirmation and fresh
authorization before writes.

## Release

Cross-tenant or critical authorization failures block release.

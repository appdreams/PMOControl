# SPEC-023 — Time Machine — Events

**Status:** Draft — projection consumer contract

This read model does not emit business-domain events and has no authoritative mutation path. It consumes committed events `StatusPublished, SnapshotCreated` to mark/rebuild its authorized projection. Consumers are tenant-scoped, idempotent, replayable and preserve source versions/as-of timestamps.

Projection refresh failure does not roll back the source command; expose stale/refresh time and retry safely. User query/dismissal telemetry is operational metadata, not a business-domain event, and must not include protected content.

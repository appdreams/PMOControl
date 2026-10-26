# SPEC-014 — Status Update — Events

**Status:** Draft — aligned with PDD catalog

- `StatusDraftCreated` when editable draft is created.
- `StatusPublished` after authoritative transaction commits Publication and Snapshot.
- `StatusCorrected` after successor publication commits; link prior and successor IDs and reason reference.

Snapshot creation is separately represented by `SnapshotCreated` from Spec 016. Notification/projection effects consume committed outbox records. No event is emitted for failed pre-commit publication. Envelope carries tenant/project/status/publication IDs, actor, timestamps, correlation ID and payload/rule versions; no full protected data or secrets.

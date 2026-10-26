# Status & Snapshot Data Model

**Status:** Draft — alinhado ao contrato snapshot-v1 da Spec 016

## Current state

Operational entities remain mutable according to authorization and
workflow.

## Status Update

`status_updates` records the preparation/review lifecycle.
`status_update_sections` may hold structured sections/drafts without replacing
source entities.

## Publication transaction

``` text
Validate
→ Calculate KPIs
→ Calculate RAG
→ Consolidate
→ Create Publication
→ Create Snapshot
→ Register Audit
→ Commit
```

Dashboard refresh, notifications, report generation and AI summaries may
execute post-commit asynchronously.

## Snapshot

Canonical hybrid model:

-   indexed relational header;
-   immutable structured JSON payload;
-   explicit schema/version identifier;
-   key indexed attributes for history queries.

Canonical header fields (payload contract in `docs/04-specs/016-snapshots/database.md`):

``` text
id
tenant_id
project_id
status_publication_id
snapshot_version
schema_version
reporting_period
calculated_rag
effective_rag
progress_percent
published_at
published_by
payload jsonb
payload_hash (SHA-256 over RFC 8785 canonical JSON)
```

## Immutability

No ordinary UPDATE/DELETE after publication. Corrections require a new
status publication/snapshot.

## Time Machine

Historical views read snapshots, not reconstructed mutable operational
tables.

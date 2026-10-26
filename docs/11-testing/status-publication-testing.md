# Status Publication Testing

**Status:** Draft — aligned to Specs 014–016; executable fixtures required

## Sequência

Validate → versioned KPI/RAG calculation → consolidate → persist Publication + exact `snapshot-v1` payload/hash + status transition + audit/outbox atomically → commit → asynchronous idempotent effects.

## Casos críticos

-   publicação válida;
-   validation failure;
-   concurrent publish;
-   retry/idempotency;
-   snapshot creation failure;
-   audit failure;
-   post-commit notification failure.
-   exact snapshot schema/hash validation and tamper detection;
-   correction creates successor publication/snapshot, never modifies prior record;
-   rag-v1 threshold boundaries and missing-input `incomplete` behavior.
-   monthly reporting period, Tenant-local month end, weekday deadline and duplicate active draft behavior;
-   `kpi-v1` formulas, N/A reasons and source-version change between preview and commit.

## Invariante

Nunca existir status oficialmente publicado sem snapshot consistente.

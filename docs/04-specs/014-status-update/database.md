# SPEC-014 — Status Update — Database

**Status:** Draft — transaction, monthly period and KPI-v1 linkage defined

## Logical tables

- `status_updates(id, tenant_id, project_id, reporting_period DATE, status_date DATE, status, version, executive_summary, created_by, updated_by, created_at, updated_at, published_at)`; `reporting_period` is first day of month, `status_date` is last day in Tenant timezone; MVP enum `draft|published|superseded`.
- `status_update_sections(id, status_update_id, section_key, content_json, source_versions_json, updated_at, updated_by)`; one row per section/draft.
- `status_publications(id, tenant_id, project_id, status_update_id, snapshot_id, published_by, published_at, idempotency_key, kpi_rule_set_version, rag_rule_version_id, supersedes_publication_id, correction_reason)`.
- `snapshots` is owned by Spec 016 and references `status_publications`; publish transaction inserts both with `status_updates.status='published'` and outbox/audit rows.

## Constraints

Unique partial `(tenant_id, project_id, reporting_period)` for one active draft; check `reporting_period = date_trunc('month', reporting_period)::date`; `status_date` equals month end in Tenant timezone; unique publish idempotency key scoped by tenant/operation; unique `status_publications.snapshot_id`; same-tenant composite FKs; `version >= 1`; correction reason required when `supersedes_publication_id` is non-null. Published records/snapshots deny ordinary UPDATE/DELETE. Snapshot is a unique FK to `snapshots.id` and is created in the same transaction per Spec 016.

## RLS/indexes/transaction

RLS tenant-scopes reads/writes and application permissions enforce create/edit/publish/correct. Index `(tenant_id,project_id,status_date DESC)`, `(tenant_id,project_id,status)` and publication `(tenant_id,project_id,published_at DESC)`. One DB transaction includes publication, snapshot, status transition and audit/outbox; consumers run post-commit. Each publication persists `kpi_rule_set_version='kpi-v1'` and RAG rule version. Snapshot payload is `snapshot-v1` and includes both.

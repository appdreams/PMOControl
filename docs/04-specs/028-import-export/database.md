# SPEC-028 — Import & Export — Database

**Status:** Draft — modelo lógico e constraints necessários

## Tabela lógica

`import_jobs(id UUID,tenant_id UUID,actor_id UUID,entity_type TEXT,target_project_id UUID NULL,source_file_key TEXT,template_version TEXT NULL,import_mode TEXT NULL,source_checksum CHAR(64) NULL,target_project_version BIGINT NULL,target_scope_checksum CHAR(64) NULL,existing_scope_counts JSONB NULL,replace_confirmed_at TIMESTAMPTZ NULL,replace_confirmed_by UUID NULL,mapping_version TEXT,status TEXT,row_count INTEGER,error_count INTEGER,confirmed_at TIMESTAMPTZ NULL,applied_at TIMESTAMPTZ NULL,expires_at TIMESTAMPTZ,version BIGINT,created_at/updated_at TIMESTAMPTZ)` tracks generic jobs and project-import target/mode/confirmation. `target_scope_checksum` binds the preview/impact summary to the exact active dataset reviewed.

`import_staging_rows(id UUID,tenant_id UUID,job_id UUID,row_number INTEGER,entity_type TEXT NULL,external_key TEXT NULL,normalized_data JSONB,validation_errors JSONB,status TEXT,created_at TIMESTAMPTZ,expires_at TIMESTAMPTZ)` stores staged rows only. `export_jobs(id UUID,tenant_id UUID,actor_id UUID,entity_type TEXT,authorized_filters JSONB,allowed_fields JSONB,status TEXT,artifact_key TEXT,checksum_sha256 TEXT,row_count BIGINT,expires_at TIMESTAMPTZ,created_at/updated_at TIMESTAMPTZ)` tracks private, authorized output.

## Constraints

- Composite FKs bind actor, job, staging row, target Project and artifact to the same Tenant. Generic import transitions `uploaded→mapped→validated→previewed→confirmed→applying→applied` or `failed|cancelled|expired`; initial project import from an empty v1 scope may transition from validated preview directly to applying without mode selection/confirmation prompt. `applied_at` requires a valid authorized apply path; `confirmed_at` is nullable only for this initial path. Staging rows cannot write source tables before the atomic apply step.
- Project import mode `initial|append|replace`; `target_project_id` required for `entity_type='project_dataset'`; template version must be allowlisted. Initial mode is accepted only by `apply-initial` after a server check proves the v1 scope remains empty. Project target is derived from the authorized selection and validated against active Tenant membership, Project status and `project.data.import` on every command.
- Replacement requires `project.data.import.replace`, version-match on target data, non-empty reason, explicit typed confirmation token hash, confirmation actor/time, and a current affected-record summary. Apply transaction archives active mutable rows in the template v1 entity scope and their active external-key mappings, inserts staged rows and new mappings, writes audit/events, and commits together. Any failure rolls back the replacement.
- Append mode inserts only new external keys. Duplicate keys within the workbook or active Project scope are blocking conflicts. It does not update or overwrite existing entities. All sheet references resolve by `(entity_type,external_key)` within the combined target Project dataset.
- Persist external keys in the existing `external_mappings` table under a dedicated provider namespace `project_xlsx_v1`, with Tenant, Project, entity type, external key and internal record ID. Unique active mapping per `(tenant_id,project_id,provider,entity_type,external_id)`; on replacement archive the prior active mapping and create new mappings so incoming keys do not collide with historical rows.
- Project-import mapping fields are `(tenant_id,project_id,provider='project_xlsx_v1',entity_type,external_id,internal_id,source_job_id,is_active,archived_at)`; active-key uniqueness is partial/conditional and same-Tenant composite relations are mandatory. Retain archived mappings for lineage; never resolve append conflicts against a different Tenant/Project.
- Project identity, published status/publications, immutable snapshots, audit events, legal holds and records outside the declared v1 workbook scope are never hard-deleted or reset. Existing append-only child history remains attached to archived source records. A replacement with unsafe inbound/cross-project references is rejected with row/entity diagnostics.
- `.xlsx` parser accepts only exact `project-import-v1` worksheet/header schema; reject macros, formulas, external links, extra/hidden sheets, unknown columns and unexpected Project code. Example workbook uses synthetic data only. Malware scan precedes parsing; upload limits follow platform policy.
- Staging expires within 30 days after completion/failure; `row_number > 0`; export field/filter sets are allowlisted and reauthorized at execution and download. CSV output escapes formula-leading `=,+,-,@`.
- Artifact keys are opaque/private, checksums server-generated, and expiry required. Idempotency key unique per `(tenant_id,actor_id,operation)` for confirm/export retry.
- Indexes `(tenant_id,actor_id,created_at DESC)`, `(tenant_id,status,created_at)`, `(tenant_id,target_project_id,created_at DESC)`, `(tenant_id,job_id,row_number)`, `(tenant_id,job_id,entity_type,external_key)` unique when external key is present, and `(tenant_id,expires_at)`.

## RLS e transações

RLS filtra Tenant a partir de contexto verificado; escrita também exige autorização de aplicação. Não aceitar `tenant_id` do cliente como contexto seguro. Eventos/outbox gravados na mesma transação das mutações que os originam; consumidores executam após commit.

## Migration e exclusão

Expand → migrate/backfill → verify → contract. Staging, reports and artifacts are purged idempotently at expiry; source updates commit only after explicit confirm and final permission/data-policy validation.

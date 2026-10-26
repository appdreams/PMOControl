# SPEC-024 — Report Builder — Database

**Status:** Draft — modelo lógico e constraints necessários

## Tabela lógica

`report_definitions(id UUID,tenant_id UUID,owner_id UUID,name TEXT,template_key TEXT,config JSONB,scope JSONB,is_shared BOOLEAN,version BIGINT,created_at/updated_at TIMESTAMPTZ)` stores validated, allowlisted saved configurations.

`report_runs(id UUID,tenant_id UUID,requested_by UUID,definition_id UUID NULL,template_key TEXT,filters JSONB,temporal_mode TEXT,as_of TIMESTAMPTZ NULL,output_format TEXT,status TEXT,progress SMALLINT,artifact_key TEXT NULL,checksum_sha256 TEXT NULL,expires_at TIMESTAMPTZ NULL,error_code TEXT NULL,created_at/updated_at TIMESTAMPTZ)` stores each run request and lifecycle.

## Constraints

- Composite FK ensures definition/run/requester share Tenant. `temporal_mode IN ('current','published')`; output format allowlist `csv|xlsx|pdf`; progress 0–100; status `queued|running|succeeded|failed|expired`.
- Persisted filters/config are schema-validated and contain only allowlisted fields; no client-supplied Tenant/permission is stored as authority. Download rechecks current access and expiry.
- Artifact key is private/opaque; checksum is server-generated. Indexes `(tenant_id,owner_id,updated_at DESC)`, `(tenant_id,status,created_at)` and `(tenant_id,requested_by,created_at DESC)`.

## RLS e transações

RLS filtra Tenant a partir de contexto verificado; escrita também exige autorização de aplicação. Não aceitar `tenant_id` do cliente como contexto seguro. Eventos/outbox gravados na mesma transação das mutações que os originam; consumidores executam após commit.

## Migration e exclusão

Expand → migrate/backfill → verify → contract. Expired artifacts are purged idempotently; run metadata follows tenant/audit retention and never contains unauthorized report rows.

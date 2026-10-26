# SPEC-016 — Snapshots — Database

**Status:** Draft — modelo lógico e constraints necessários

## Tabela canônica `snapshots`

`snapshots`: `id UUID PK, tenant_id UUID, project_id UUID, status_publication_id UUID UNIQUE, snapshot_version INT, schema_version TEXT, reporting_period DATE, status_date DATE, calculated_rag TEXT, effective_rag TEXT, progress_percent DECIMAL(5,2), published_at TIMESTAMPTZ, published_by UUID, supersedes_snapshot_id UUID NULL, payload JSONB, payload_hash TEXT, created_at TIMESTAMPTZ`. Hash = SHA-256 of RFC 8785 canonical UTF-8 JSON over an envelope `{header, payload}`, excluding only `payload_hash`; header fields are included once in `header`.

Payload v1 obrigatório: `project` (id, name, code, status, owner_id), `period` (reporting_period, status_date, tenant_timezone), `narrative` (executive_summary, achievements[], challenges[], next_period_priorities[]), `kpis` (rule_set_version=`kpi-v1`, progress_planned_percent, progress_actual_percent, schedule_variance_days, schedule_variance_percent, approved_budget, forecast_at_completion, cost_variance_percent, on_time_delivery_percent), `rag` (calculated, effective, rule_set_version=`rag-v1`, indicators[], override nullable `{override_id, reason, actor_id, created_at, expires_at}`), `milestones[]`, `risks[]`, `issues[]`, `decisions[]`, `actions[]`, `source_versions{}`. Cada array tem ordenação estável por ID; timestamps UTC ISO-8601; valores monetários string decimal; valores não disponíveis são `null` com `availability`/reason explícito, nunca omitidos silenciosamente. Dados confidenciais são filtrados pelo policy de publicação do Tenant; secrets e prompt/output de IA ficam excluídos.

## Constraints

- PK UUID; `UNIQUE(tenant_id,id)`, `UNIQUE(tenant_id,status_publication_id)`, `UNIQUE(tenant_id,project_id,snapshot_version)`; composite FKs bind Project, Publication and predecessor to same Tenant/Project. `CHECK(snapshot_version >= 1)` and progress 0–100 when present.
- Uma publicação tem exatamente um snapshot; correção cria publicação e snapshot sucessores apontando para os anteriores. Não atualizar payload/schema/hash já gravados.
- `schema_version='snapshot-v1'` identifica este contrato. Mudança incompatível exige novo schema version e leitor compatível; migration não reescreve payload histórico.
- `schema_version` allowlist begins with `snapshot-v1`; `payload_hash` is 64 lowercase hex chars and computed server-side. `supersedes_snapshot_id` cannot point to self or another Project; successor numbering is monotonic within the Project.
- Indexes `(tenant_id,project_id,published_at DESC)`, `(tenant_id,project_id,reporting_period,snapshot_version)` and `(tenant_id,status_publication_id)`.

## RLS e transações

RLS filtra Tenant a partir de contexto verificado; escrita também exige autorização de aplicação. Não aceitar `tenant_id` do cliente como contexto seguro. Eventos/outbox gravados na mesma transação das mutações que os originam; consumidores executam após commit.

## Migration e exclusão

Expand → migrate/backfill → verify → contract. Dados históricos/imutáveis não recebem update/delete ordinário; retenção e purge seguem o workflow central. Este contrato é o modelo mestre para a migration.

# SPEC-008 — Deliverables — Database

**Status:** Draft — modelo lógico e constraints necessários

## Tabela lógica

`deliverables(id UUID, tenant_id UUID, project_id UUID, milestone_id UUID NULL, name TEXT, owner_id UUID NULL, baseline_date DATE NULL, forecast_date DATE NULL, acceptance_required BOOLEAN, delivered_at TIMESTAMPTZ NULL, acceptance_status TEXT, accepted_at TIMESTAMPTZ NULL, progress NUMERIC(5,2), status TEXT, version BIGINT, created_at/updated_at TIMESTAMPTZ, created_by/updated_by UUID)`; evidence resides in `evidence_links` with independent ownership/classification.

## Constraints

- PK UUID, `UNIQUE(tenant_id,id)`, FKs compostas `(tenant_id,project_id)` e `(tenant_id,milestone_id,project_id)`; milestone é opcional, mas quando informado deve pertencer ao mesmo Project. `CHECK(progress BETWEEN 0 AND 100)`, delivery status `planned|in_progress|delivered|cancelled` e acceptance status `not_required|pending|accepted|rejected` conforme PDD §49.
- `delivered_at` não implica aceite. Entrega exige evidência quando requerida pela política do tipo; aceite formal inicia como pending. `accepted_at` só existe após decisão accepted; rejeição exige motivo e preserva entrega/evidência para nova submissão/decisão.
- Índices `(tenant_id,project_id,status)`, `(tenant_id,project_id,baseline_date)` e `(tenant_id,owner_id,status)`; updates usam `version`.

## RLS e transações

RLS filtra Tenant a partir de contexto verificado; escrita também exige autorização de aplicação. Não aceitar `tenant_id` do cliente como contexto seguro. Eventos/outbox gravados na mesma transação das mutações que os originam; consumidores executam após commit.

## Migration e exclusão

Expand → migrate/backfill → verify → contract. Entrega, evidências e decisões de aceite não são removidas por update ordinário; archive preserva histórico e hard delete segue retenção central.

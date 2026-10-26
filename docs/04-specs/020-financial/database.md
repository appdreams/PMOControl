# SPEC-020 — Financial — Database

**Status:** Draft — modelo lógico e constraints necessários

## Tabela lógica

`project_financials(id UUID,tenant_id UUID,project_id UUID,currency CHAR(3),approved_budget NUMERIC(20,4) NULL,revised_budget NUMERIC(20,4) NULL,committed_amount NUMERIC(20,4),actual_amount NUMERIC(20,4),forecast_at_completion NUMERIC(20,4) NULL,period DATE NULL,baseline_version BIGINT NULL,version BIGINT,updated_by UUID,updated_at TIMESTAMPTZ)`; approved budget changes are versioned audited commands, not overwrites. A row may exist before an approved budget; forecast and baseline fields are nullable until their governed lifecycle step.

## Constraints

- PK UUID; composite FK `(tenant_id,project_id)`; `currency` must be ISO-4217; monetary fields use exact NUMERIC and are non-negative; never use float.
- One current row per `(tenant_id,project_id,currency)`; baseline version must refer to the approved Project baseline. Forecast/actual updates cannot mutate approved budget; concurrency via `version`.
- Variance values are derived, not separately writable: cost variance = `(forecast_at_completion - approved_budget) / approved_budget`; if budget is null/zero, API returns N/A + reason, never division by zero.
- Index `(tenant_id,project_id)` and `(tenant_id,period)`; field access requires separate `financial.view|edit|export` data grants.

## RLS e transações

RLS filtra Tenant a partir de contexto verificado; escrita também exige autorização de aplicação. Não aceitar `tenant_id` do cliente como contexto seguro. Eventos/outbox gravados na mesma transação das mutações que os originam; consumidores executam após commit.

## Migration e exclusão

Expand → migrate/backfill → verify → contract. Approved baseline revisions are immutable; corrections append a governed version. Tenant purge follows central retention policy.

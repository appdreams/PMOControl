# SPEC-010 — Issues — Database

**Status:** Draft — modelo lógico e constraints necessários

## Tabela lógica

`issues(id UUID,tenant_id UUID,project_id UUID,source_risk_id UUID NULL,description TEXT,root_cause TEXT NULL,impact TEXT,priority TEXT,owner_id UUID NULL,opened_at TIMESTAMPTZ,due_date DATE NULL,resolved_at TIMESTAMPTZ NULL,resolution TEXT NULL,status TEXT,blocker BOOLEAN,version BIGINT,created_by/updated_by UUID,created_at/updated_at TIMESTAMPTZ)`.

## Constraints

- PK UUID and `UNIQUE(tenant_id,id)`; composite FK for Project, optional source Risk and owner membership enforce same Tenant/Project.
- `CHECK(status IN ('open','analyzing','in_progress','blocked','resolved','closed'))` per PDD §49; `CHECK(priority IN ('low','medium','high','critical'))`; `blocker` is an explicit boolean, not inferred from priority. `resolved_at` and non-empty resolution are required in resolved/closed states; unresolved states must not carry resolution timestamp. `UNIQUE(tenant_id,source_risk_id)` when source risk is not null prevents duplicate Issue materialization.
- Aging is a query value derived from `opened_at` and resolved/closed timestamp or current time; do not persist a separately mutable aging value.
- Indexes `(tenant_id,project_id,status,opened_at)`, `(tenant_id,project_id,due_date)`, `(tenant_id,owner_id,status)`; source risk is same-Tenant and same-Project.

## RLS e transações

RLS filtra Tenant a partir de contexto verificado; escrita também exige autorização de aplicação. Não aceitar `tenant_id` do cliente como contexto seguro. Eventos/outbox gravados na mesma transação das mutações que os originam; consumidores executam após commit.

## Migration e exclusão

Expand → migrate/backfill → verify → contract. Resolution/closure preserves history; archive/delete follows central retention policy.

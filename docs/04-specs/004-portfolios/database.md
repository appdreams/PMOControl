# SPEC-004 — Portfolios — Database

**Status:** Draft — modelo lógico e constraints necessários

## Tabela lógica

`portfolios(id UUID, tenant_id UUID, name TEXT, code TEXT, owner_id UUID, sponsor_id UUID NULL, category TEXT, status TEXT, start_date DATE NULL, target_end_date DATE NULL, archived_at TIMESTAMPTZ NULL, version BIGINT, created_at TIMESTAMPTZ, created_by UUID, updated_at TIMESTAMPTZ, updated_by UUID)`; relação com Projects permanece em `portfolio_projects`.

`portfolio_projects(id UUID,tenant_id UUID,portfolio_id UUID,project_id UUID,linked_at TIMESTAMPTZ,linked_by UUID,removed_at TIMESTAMPTZ NULL,removed_by UUID NULL,version BIGINT)` is a temporal association; removal ends the relation without deleting it.

## Constraints

- `PRIMARY KEY(id)`; `UNIQUE(tenant_id, id)` para FKs compostas e índice único `(tenant_id, upper(trim(code)))` para código não vazio.
- `FOREIGN KEY (tenant_id, owner_id)` e `(tenant_id, sponsor_id)` referenciam memberships/actors permitidos no mesmo Tenant; `portfolio_projects` garante same-tenant para Portfolio e Project. Partial unique index permits only one active identical association.
- `CHECK(status IN ('active','archived'))`; `CHECK(code = upper(trim(code)) AND trim(code) <> '')`; se ambas as datas existirem, `target_end_date >= start_date`; `version >= 1`.
- Índices `(tenant_id,status,name)`, `(tenant_id,owner_id,status)` e chave única tenant-scoped para associação de Project.

## RLS e transações

RLS filtra Tenant a partir de contexto verificado; escrita também exige autorização de aplicação. Não aceitar `tenant_id` do cliente como contexto seguro. Eventos/outbox gravados na mesma transação das mutações que os originam; consumidores executam após commit.

## Migration e exclusão

Expand → migrate/backfill → verify → contract. Arquivar define `archived_at` e mantém relações/histórico; remoção da associação não apaga Project. Hard delete segue o workflow central de retenção. Esta especificação lógica é a base de migration e requer revisão na implementação.

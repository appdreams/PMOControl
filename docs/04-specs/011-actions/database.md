# SPEC-011 — Actions — Database

**Status:** Draft — modelo lógico e constraints necessários

## Tabela lógica

`actions(id UUID,tenant_id UUID,project_id UUID,source_type TEXT NULL,source_id UUID NULL,title TEXT,description TEXT NULL,owner_id UUID NULL,priority TEXT,start_date DATE NULL,due_date DATE NULL,actual_completed_at TIMESTAMPTZ NULL,progress NUMERIC(5,2),status TEXT,completion_outcome TEXT NULL,version BIGINT,created_by/updated_by UUID,created_at/updated_at TIMESTAMPTZ)`.

## Constraints

- PK UUID and composite FKs bind Project and owner to the same Tenant. `source_type/source_id` is an allowlisted polymorphic link validated to the same Tenant; source is immutable after creation except through an audited relink command. The initial source-type allowlist is `risk`, `issue`, `milestone`, `deliverable`, `decision`, and `manual`. `manual` means the Action was created independently and requires `source_id = NULL`; the other values require a valid same-Tenant/Project source reference. Additions require an explicit domain/API/import contract update.
- `CHECK(status IN ('not_started','in_progress','blocked','completed','cancelled'))` per PDD §19; `CHECK(priority IN ('low','medium','high','critical'))`; `CHECK(progress BETWEEN 0 AND 100)`. Completed requires progress=100 and `actual_completed_at`; non-completed status cannot carry completion timestamp. Cancellation requires reason and preserves source.
- Indexes `(tenant_id,project_id,status,due_date)`, `(tenant_id,owner_id,status,due_date)`, and `(tenant_id,source_type,source_id)`; updates use optimistic `version`.

## RLS e transações

RLS filtra Tenant a partir de contexto verificado; escrita também exige autorização de aplicação. Não aceitar `tenant_id` do cliente como contexto seguro. Eventos/outbox gravados na mesma transação das mutações que os originam; consumidores executam após commit.

## Migration e exclusão

Expand → migrate/backfill → verify → contract. Completion and cancellation retain history/source; hard delete follows central retention policy.

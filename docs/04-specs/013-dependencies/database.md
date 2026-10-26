# SPEC-013 — Dependencies — Database

**Status:** Draft — modelo lógico e constraints necessários

## Tabela lógica

`dependencies(id UUID,tenant_id UUID,source_type TEXT,source_id UUID,target_type TEXT,target_id UUID,dependency_type TEXT,owner_id UUID NULL,criticality TEXT NULL,due_date DATE NULL,status TEXT,impact TEXT NULL,lag_days INTEGER DEFAULT 0,version BIGINT,created_by/updated_by UUID,created_at/updated_at TIMESTAMPTZ)`.

## Constraints

- PK UUID and `UNIQUE(tenant_id,id)`; source/target endpoint type allowlist is `project|deliverable|milestone|area|supplier`; endpoint resolver verifies existence, Tenant and permitted relation type. Self-edge is rejected.
- `CHECK(dependency_type IN ('finish_to_start','start_to_start','finish_to_finish','start_to_finish'))`, `CHECK(status IN ('active','resolved','cancelled'))`, `CHECK(lag_days >= 0)` and no duplicate active edge for same tenant/source/target/type.
- Cycle detection runs transactionally across the dependency graph; if concurrent inserts could create a cycle, lock the Tenant/Project graph or serialize the mutation. Cross-project edges are allowed only within one Tenant.
- Indexes `(tenant_id,source_type,source_id,status)`, `(tenant_id,target_type,target_id,status)` and `(tenant_id,due_date,status)`.

## RLS e transações

RLS filtra Tenant a partir de contexto verificado; escrita também exige autorização de aplicação. Não aceitar `tenant_id` do cliente como contexto seguro. Eventos/outbox gravados na mesma transação das mutações que os originam; consumidores executam após commit.

## Migration e exclusão

Expand → migrate/backfill → verify → contract. Resolving/cancelling closes the edge without deleting history; endpoint changes require an audited update with expected version.

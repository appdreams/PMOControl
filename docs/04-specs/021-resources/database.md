# SPEC-021 — Resources — Database

**Status:** Draft — modelo lógico e constraints necessários

## Tabela lógica

`resources(id UUID,tenant_id UUID,person_id UUID NULL,resource_type TEXT,display_name TEXT,role TEXT,skills JSONB,capacity_percent NUMERIC(5,2),availability_start DATE NULL,availability_end DATE NULL,status TEXT,version BIGINT,created_at/updated_at TIMESTAMPTZ)`; personal identifiers are minimized and field-classified.

`allocations(id UUID,tenant_id UUID,project_id UUID,resource_id UUID,role TEXT,capacity_percent NUMERIC(5,2),start_date DATE,end_date DATE NULL,status TEXT,override_reason TEXT NULL,version BIGINT,created_by UUID,created_at/updated_at TIMESTAMPTZ)`.

## Constraints

- PK UUID and composite FKs ensure resource, Project and person membership share Tenant; `capacity_percent BETWEEN 0 AND 100`; `end_date >= start_date` when bounded.
- No overlapping active allocation for the same resource/Project/time interval unless authorized override has non-empty reason and audit. Total overlapping allocation over resource capacity is rejected by serialized domain transaction or explicitly overridden by separate grant.
- Cost/rate fields are excluded from this table and require separate financial data policy. Resource PII is not returned by capacity-only query.
- Indexes `(tenant_id,project_id,status,start_date,end_date)`, `(tenant_id,resource_id,status,start_date,end_date)` and `(tenant_id,person_id)`.

## RLS e transações

RLS filtra Tenant a partir de contexto verificado; escrita também exige autorização de aplicação. Não aceitar `tenant_id` do cliente como contexto seguro. Eventos/outbox gravados na mesma transação das mutações que os originam; consumidores executam após commit.

## Migration e exclusão

Expand → migrate/backfill → verify → contract. Allocation changes retain audit/version history; resource deletion is blocked while active allocations exist and otherwise follows retention policy.

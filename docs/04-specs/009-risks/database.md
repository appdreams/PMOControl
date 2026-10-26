# SPEC-009 — Risks — Database

**Status:** Draft — modelo lógico e constraints necessários

## Tabela lógica

`risks(id UUID,tenant_id UUID,project_id UUID,title TEXT,description TEXT,cause TEXT,consequence TEXT,category TEXT,owner_id UUID NULL,status TEXT,trend TEXT,due_date DATE NULL,version BIGINT,created_at/updated_at TIMESTAMPTZ,created_by/updated_by UUID)`.

`risk_assessments(id UUID,tenant_id UUID,risk_id UUID,probability SMALLINT,impact SMALLINT,score SMALLINT,level TEXT,assessed_by UUID,assessed_at TIMESTAMPTZ,version BIGINT)` is append-only. `risk_responses(id UUID,tenant_id UUID,risk_id UUID,mitigation TEXT,contingency TEXT,owner_id UUID,due_date DATE,status TEXT,created_by UUID,created_at TIMESTAMPTZ,version BIGINT)` preserves response history.

## Constraints

- PK UUID; composite FKs enforce same Tenant/Project for Risk, assessment, response and linked Issue. One assessment may be current for display, but prior assessment rows are never overwritten.
- `CHECK(status IN ('identified','assessing','treating','monitoring','closed','materialized'))` per PDD §49; `CHECK(probability BETWEEN 1 AND 5 AND impact BETWEEN 1 AND 5)` and `score = probability * impact`; `risk_assessments` immutable after insert. Provisionar para cada Tenant a taxonomia inicial de `category`: `scope`, `schedule`, `cost`, `quality`, `resource`, `supplier`, `technical`, `security`, `compliance`, `other`; e de `trend`: `improving`, `stable`, `worsening`. Os códigos permanecem estáveis e os rótulos podem ser traduzidos/customizados por Tenant; novos valores requerem configuração explícita e não alteram registros históricos.
- Materialization is represented by unique nullable `issues.source_risk_id` referencing the same-Tenant/Project Risk; it does not delete Risk assessments or close the Risk implicitly.
- Indexes `(tenant_id,project_id,status)`, `(tenant_id,owner_id,status)`, `(tenant_id,risk_id,assessed_at DESC)` and `(tenant_id,project_id,due_date)`.

## RLS e transações

RLS filtra Tenant a partir de contexto verificado; escrita também exige autorização de aplicação. Não aceitar `tenant_id` do cliente como contexto seguro. Eventos/outbox gravados na mesma transação das mutações que os originam; consumidores executam após commit.

## Migration e exclusão

Expand → migrate/backfill → verify → contract. Risk and assessment history are retained on close/materialization; purge follows the central retention workflow.

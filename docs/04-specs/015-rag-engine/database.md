# SPEC-015 — RAG Engine — Database

**Status:** Draft — modelo lógico e constraints necessários

## Tabela lógica

`rag_rule_versions(id UUID,tenant_id UUID,project_type TEXT,version TEXT,effective_from DATE,thresholds_json JSONB,created_by UUID,created_at TIMESTAMPTZ)` is immutable after activation. `rag_evaluations(id UUID,tenant_id UUID,project_id UUID,as_of DATE,evaluation_status TEXT,calculated_rag TEXT NULL,effective_rag TEXT NULL,rule_version_id UUID,normalized_inputs_json JSONB,inputs_hash CHAR(64),evaluated_at TIMESTAMPTZ)` is append-only. `rag_overrides(id UUID,tenant_id UUID,project_id UUID,evaluation_id UUID,previous_effective_rag TEXT,new_effective_rag TEXT,reason TEXT,actor_id UUID,created_at TIMESTAMPTZ,expires_at TIMESTAMPTZ NULL,revoked_at TIMESTAMPTZ NULL)` preserves override lifecycle. Never overwrite calculated result with override.

## Constraints

- PK UUID and composite FKs bind every rule/evaluation/override to the same Tenant and Project; `UNIQUE(tenant_id,project_type,version)`; at most one rule version effective for a given type/date.
- Rule JSON must validate against `rag-v1` schema; RAG values `green|amber|red`. `evaluation_status IN ('complete','incomplete')`; incomplete evaluations have null calculated/effective values and never replace last complete publication. `inputs_hash` is SHA-256 of RFC 8785 canonical normalized input plus rule version ID.
- `CHECK(probability BETWEEN 1 AND 5)` and `CHECK(impact BETWEEN 1 AND 5)` for source assessment values; score is derived as product. Overrides apply only to a complete evaluation; reason length >=10; `revoked_at >= created_at`; only one currently active override per Project.
- Indexes `(tenant_id,project_id,as_of DESC)`, `(tenant_id,project_type,effective_from DESC)`, `(tenant_id,project_id,created_at DESC)`.
- Override reason length >= 10; revocation/expiry is append-only lifecycle metadata; prior override rows remain available for audit.

## RLS e transações

RLS filtra Tenant a partir de contexto verificado; escrita também exige autorização de aplicação. Não aceitar `tenant_id` do cliente como contexto seguro. Eventos/outbox gravados na mesma transação das mutações que os originam; consumidores executam após commit.

## Migration e exclusão

Expand → migrate/backfill → verify → contract. Rule versions and evaluations are immutable; override expiry/revoke is represented as lifecycle metadata. Tenant purge follows central retention policy.

# SPEC-027 — Audit Log — Database

**Status:** Draft — modelo lógico e constraints necessários

## Tabela lógica

`audit_events(id UUID,tenant_id UUID NULL,actor_id UUID,actor_type TEXT,action TEXT,resource_type TEXT,resource_id UUID NULL,occurred_at TIMESTAMPTZ,correlation_id UUID,reason TEXT NULL,before_redacted JSONB NULL,after_redacted JSONB NULL,source TEXT,schema_version TEXT,idempotency_key TEXT NULL)` is append-only. Platform events may have null Tenant only when the action itself is platform-scoped.

## Constraints

- PK UUID; `occurred_at` is UTC; action/source/schema are allowlisted; `before_redacted/after_redacted` are scrubbed by schema before persistence and secrets/auth tokens are rejected. No foreign key to polymorphic resource, but tenant/resource scope is validated by trusted writer.
- `UNIQUE(tenant_id,source,idempotency_key)` when key is present; actor identity is service-derived. Application role has no insert/update/delete; only trusted writer may append, and retention purge uses separate audited procedure.
- Indexes `(tenant_id,occurred_at DESC)`, `(tenant_id,resource_type,resource_id,occurred_at DESC)`, `(tenant_id,actor_id,occurred_at DESC)`, `(tenant_id,correlation_id)`.

## RLS e transações

RLS filtra Tenant a partir de contexto verificado; escrita também exige autorização de aplicação. Não aceitar `tenant_id` do cliente como contexto seguro. Eventos/outbox gravados na mesma transação das mutações que os originam; consumidores executam após commit.

## Migration e exclusão

Expand → migrate/backfill → verify → contract. Audit events are append-only during the retention period; only scoped retention procedure may purge, recording purge completion metadata without copying event payloads.

# SPEC-027 — Audit Log — Database

**Status:** Draft — modelo lógico e constraints necessários

## Tabela lógica

`audit_events(id UUID,tenant_id UUID NULL,actor_id UUID,actor_type TEXT,action TEXT,resource_type TEXT,resource_id UUID NULL,occurred_at TIMESTAMPTZ,correlation_id UUID,reason TEXT NULL,before_redacted JSONB NULL,after_redacted JSONB NULL,source TEXT,schema_version TEXT,idempotency_key TEXT NULL)` is append-only. `actor_id` is NOT NULL; allowlisted actor types are `user`, `platform_service`, and `system_job`. For `user`, it is the verified `auth.uid()`. Service/job IDs come from a release-owned, versioned actor catalog (stable UUID per service/job key); the trusted writer rejects unknown ID/type pairs. No client or service-role direct insert is permitted, so the polymorphic actor reference is validated by the writer rather than an FK. Platform events may have null Tenant only when the action itself is platform-scoped.

## Constraints

- PK UUID; `occurred_at` is UTC; action/source/schema and actor_type are allowlisted; `before_redacted/after_redacted` are scrubbed by event-specific schema before persistence and secrets/auth tokens are rejected. Pre-authentication failures are not application audit rows. No foreign key to polymorphic resource, but tenant/resource scope is validated by trusted writer.
- `CREATE UNIQUE INDEX ... ON audit_events (tenant_id,source,idempotency_key) NULLS NOT DISTINCT WHERE idempotency_key IS NOT NULL` prevents duplicate platform events where `tenant_id` is NULL as well as tenant events. PostgreSQL baseline is 17. Actor identity is resolved from the verified caller/service boundary; client-provided actor IDs are rejected. Application role has no update/delete; inserts use the authenticated command/RPC boundary and retention purge uses a separate audited procedure.
- Indexes `(tenant_id,occurred_at DESC)`, `(tenant_id,resource_type,resource_id,occurred_at DESC)`, `(tenant_id,actor_id,occurred_at DESC)`, `(tenant_id,correlation_id)`.

## RLS e transações

RLS filtra Tenant a partir de contexto verificado; escrita também exige autorização de aplicação. Não aceitar `tenant_id` do cliente como contexto seguro. Eventos/outbox gravados na mesma transação das mutações que os originam; consumidores executam após commit.

## Migration e exclusão

Expand → migrate/backfill → verify → contract. Audit events are append-only during the retention period; only scoped retention procedure may purge, recording purge completion metadata without copying event payloads.

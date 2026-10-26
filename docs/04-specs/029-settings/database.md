# SPEC-029 — Settings — Database

**Status:** Draft — modelo lógico e constraints necessários

## Tabela lógica

`tenant_settings(id UUID,tenant_id UUID,key TEXT,value_schema_version INTEGER,value JSONB,secret_ref TEXT NULL,updated_by UUID,updated_at TIMESTAMPTZ,version BIGINT)` stores typed tenant configuration. Secret values are never persisted in `value`; only opaque secret-manager references may be stored in `secret_ref`.

## Constraints

- PK UUID, FK to Tenant, `UNIQUE(tenant_id,key)`, `version >= 1`; `key` must match a registered setting definition and `value_schema_version` must validate against that definition before write.
- Secret-classified settings require `secret_ref` and reject raw secret values; read responses redact references/values unless a separate secret-management grant permits metadata. Reset returns to versioned default, not delete.
- Every change emits audit with key/version/actor/reason, never the value or secret. Concurrent updates require expected version; no cross-tenant setting IDs or key probing.
- Index `(tenant_id,key)` and `(tenant_id,updated_at DESC)`.

## RLS e transações

RLS filtra Tenant a partir de contexto verificado; escrita também exige autorização de aplicação. Não aceitar `tenant_id` do cliente como contexto seguro. Eventos/outbox gravados na mesma transação das mutações que os originam; consumidores executam após commit.

## Migration e exclusão

Expand → migrate/backfill → verify → contract. Settings remain tenant-owned and versioned; removing a key uses an audited reset/deprecation workflow and secret rotation never exposes secret material.

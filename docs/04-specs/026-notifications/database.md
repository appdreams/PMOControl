# SPEC-026 — Notifications — Database

**Status:** Draft — modelo lógico e constraints necessários

## Tabela lógica

`notifications(id UUID,tenant_id UUID,recipient_id UUID,event_id UUID,type TEXT,payload_minimized JSONB,read_at TIMESTAMPTZ,created_at TIMESTAMPTZ,expires_at TIMESTAMPTZ)` stores the recipient inbox projection.

`notification_preferences(id UUID,user_id UUID,tenant_id UUID NULL,event_type TEXT,channels JSONB,is_enabled BOOLEAN,version BIGINT,updated_at TIMESTAMPTZ)` stores actor-owned preferences; null Tenant means global preference, otherwise active membership is required.

`notification_deliveries(id UUID,tenant_id UUID,notification_id UUID,channel TEXT,dedupe_key TEXT,attempt_count INTEGER,status TEXT,next_retry_at TIMESTAMPTZ,delivered_at TIMESTAMPTZ,last_error_code TEXT,created_at/updated_at TIMESTAMPTZ)` stores channel delivery lifecycle. Payload is created only from committed event; retries never repeat source command.

## Constraints

- Composite FK ensures recipient membership and notification/delivery share Tenant; unique `(tenant_id,channel,dedupe_key)` makes delivery idempotent. `attempt_count >= 0`; channel allowlist `in_app|email`; status `queued|sending|delivered|retryable_failed|permanent_failed|cancelled`.
- Preference unique key `(user_id,tenant_id,event_type)`; actor can read/update only own preferences, and tenant-specific preferences require active same-Tenant membership. Channel keys and event types are allowlisted.
- Read state is recipient-only. Payload allowlist excludes secrets, full document contents and confidential data not granted to recipient; event ID is unique with recipient/type for dedupe.
- Indexes `(tenant_id,recipient_id,created_at DESC)`, `(tenant_id,recipient_id,read_at,created_at DESC)`, `(tenant_id,status,next_retry_at)`.

## RLS e transações

RLS filtra Tenant a partir de contexto verificado; escrita também exige autorização de aplicação. Não aceitar `tenant_id` do cliente como contexto seguro. Eventos/outbox gravados na mesma transação das mutações que os originam; consumidores executam após commit.

## Migration e exclusão

Expand → migrate/backfill → verify → contract. Expired inbox/delivery metadata follows retention policy; worker retries use bounded exponential backoff and stop on permanent failure.

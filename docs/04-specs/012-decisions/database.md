# SPEC-012 — Decisions — Database

**Status:** Draft — modelo lógico e constraints necessários

## Tabela lógica

`decisions(id UUID,tenant_id UUID,project_id UUID,subject TEXT,context TEXT,options JSONB,requested_by UUID,decision_maker_id UUID NULL,due_date DATE NULL,decided_at TIMESTAMPTZ NULL,status TEXT,outcome TEXT NULL,impact TEXT,version BIGINT,created_by UUID,created_at/updated_at TIMESTAMPTZ)`. Evidence uses canonical `evidence_links`; comments use append-only `decision_comments(id,tenant_id,decision_id,author_id,body,created_at)`.

## Constraints

- PK UUID and composite FKs for Project, requester and decision maker enforce same Tenant. `options` must be a non-empty JSON array of bounded, labeled options. `decision_comments` has composite FK to Decision and author membership, non-empty body ≤ 4000 chars, no update/delete by app role; attachments use same-Tenant `evidence_links`.
- `CHECK(status IN ('pending','approved','rejected','deferred','cancelled'))` per PDD §20. Final statuses require `decided_at`, `decision_maker_id` and outcome; pending must not contain a final outcome. Approve/reject/defer are command-only state transitions and append history; no generic update may rewrite a prior outcome.
- Indexes `(tenant_id,project_id,status,due_date)`, `(tenant_id,decision_maker_id,status,due_date)`; expected version on decision commands prevents conflicting concurrent outcomes.

## RLS e transações

RLS filtra Tenant a partir de contexto verificado; escrita também exige autorização de aplicação. Não aceitar `tenant_id` do cliente como contexto seguro. Eventos/outbox gravados na mesma transação das mutações que os originam; consumidores executam após commit.

## Migration e exclusão

Expand → migrate/backfill → verify → contract. Decision outcomes and their audit history are retained; hard delete follows central retention policy.

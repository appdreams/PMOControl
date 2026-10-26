# Row-Level Security

**Status:** Draft — trusted context and policy shape defined; implementation review pending

## Papel

RLS reforça isolamento e políticas de dados, mas não substitui
autorização da aplicação.

## Default

Tabelas tenant-owned devem operar com política deny-by-default.

## Testes mínimos

-   authorized same tenant → allow;
-   unauthorized scope → deny;
-   different tenant → deny;
-   revoked membership → deny;
-   forged ID → deny;
-   missing tenant context → deny;
-   privileged path unintended → deny.

## Service role

Somente server-side, nunca exposta ao browser, com uso mínimo e
auditável.

Trusted context is transaction-local and set only after server-side session + membership validation. Missing actor/tenant context, inactive membership or suspended Tenant fails closed. App role does not own protected tables and cannot bypass RLS; all tenant-owned tables use tenant predicate and same-tenant composite relations. Status publications, snapshots and audit records deny app-role update/delete; purge is a separate audited path with legal-hold checks. Canonical policy contract: `docs/06-data/rls-data-policies.md`.

Project purge is an explicit retention workflow, not a general RLS bypass. Use a separate narrowly scoped privileged procedure, server-verified `platform.projects.purge`, one target Project, confirmation/version checks, legal-hold enforcement and append-only audit. Never grant Platform Root Admin direct tenant-table reads or `BYPASSRLS`.

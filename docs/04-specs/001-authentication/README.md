# SPEC-001 --- Authentication --- Readme

**Status:** In progress — MVP login, recovery, callback, logout, SSR refresh, self-service profile and invalid/expired session messaging implemented; production session-age/provider settings remain outside the Phase 1 gate.\
**Spec:** 001\
**Módulo:** Authentication\
**Arquivo:** `README.md`

------------------------------------------------------------------------

## Objetivo

Identity, sessão e recuperação de acesso.

## Invariante principal

**Supabase Auth autentica; autorização de negócio permanece interna.**

## Estrutura da Spec

Esta pasta segue o `SPEC-TEMPLATE` oficial:

``` text
README.md
requirements.md
domain-model.md
user-flows.md
business-rules.md
database.md
api.md
ui.md
permissions.md
events.md
acceptance-criteria.md
edge-cases.md
test-cases.md
```

## Fonte de verdade

O módulo mantém sua entidade operacional oficial; dashboards,
relatórios, Status e IA consomem projeções autorizadas.

## Segurança

Toda operação aplica
`Tenant + Role + Scope + Permission + Data Policy + Workflow Rule`, com
default `DENY`.

## Integrações internas

Quando aplicável: Project Control Center → Status Update → Snapshot →
Dashboard/Portfolio → Reports → PMO Copilot.

## Referências

-   `/docs/00-foundation/`
-   `/docs/02-architecture/`
-   `/docs/03-adrs/`
-   `/docs/04-specs/001-authentication/`

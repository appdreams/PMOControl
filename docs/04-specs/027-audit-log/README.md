# SPEC-027 --- Audit Log --- Readme

**Status:** Fase 1 concluída — append-only boundary, atomic domain events, credential-event provider logs and database payload redaction guard are covered; CI `40621234785` passed. Query/export UI remains future scope.\
**Spec:** 027\
**Módulo:** Audit Log\
**Arquivo:** `README.md`

------------------------------------------------------------------------

## Objetivo

Registro append-oriented de eventos sensíveis.

## Invariante principal

**Audit é imutável para usuários comuns.**

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
-   `/docs/04-specs/027-audit-log/`

# SPEC-027 --- Audit Log --- Readme

**Status:** In progress — append-only audit foundation and transactional events implemented; systematic payload scrub and remaining Auth-event observability review remain pending.\
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

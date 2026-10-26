# SPEC-023 --- Time Machine --- Readme

**Status:** Draft — remediation required\
**Spec:** 023\
**Módulo:** Time Machine\
**Arquivo:** `README.md`

------------------------------------------------------------------------

## Objetivo

Navegação histórica por publicações.

## Invariante principal

**Passado vem de Snapshots, não do estado atual.**

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
-   `/docs/04-specs/023-time-machine/`

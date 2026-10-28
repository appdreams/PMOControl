# SPEC-002 --- Multi-Tenancy --- Readme

**Status:** In progress — Tenant, membership, invitation and resource foundations implemented in DEV; private export generation, contact download, integrity verification and first-download audit are implemented. Notification/delivery, dispute/legal hold workflows and retention purge remain pending.\
**Spec:** 002\
**Módulo:** Multi-Tenancy\
**Arquivo:** `README.md`

------------------------------------------------------------------------

## Objetivo

Isolamento e lifecycle de organizações clientes.

## Invariante principal

**Tenant é fronteira de segurança, não filtro de UI.**

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
-   `/docs/04-specs/002-multi-tenancy/`

# SPEC-003 --- RBAC & Contextual Authorization --- Readme

**Status:** Fase 1 concluída — versioned permission catalog, Tenant/resource delegation, lifecycle and exact-scope authorization implemented in DEV; migrations and transactional smokes passed CI `40621234785`. Remaining query surfaces and broader domain features belong to later phases.\
**Spec:** 003\
**Módulo:** RBAC & Contextual Authorization\
**Arquivo:** `README.md`

------------------------------------------------------------------------

## Objetivo

Autorização contextual por role, scope e permission.

## Invariante principal

**Effective Access = Tenant + Role + Scope + Permission + Data Policy +
Workflow Rule.**

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
-   `/docs/04-specs/003-rbac/`

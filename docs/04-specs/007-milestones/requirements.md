# SPEC-007 — Milestones — Requirements

**Status:** Draft — domínio especificado; revisão de contrato transversal pendente  
**Spec:** 007

## Objetivo e regra de domínio

Baseline Date, Forecast Date e Actual Date nunca se sobrescrevem entre si.

## Requisitos funcionais testáveis

- **FR-007-01:** consultar/listar Milestones somente dentro de `Project`, com paginação/filtros allowlisted e sem revelar recursos não autorizados.
- **FR-007-02:** criar/derivar Milestone usando apenas campos aceitos pelo domínio: `tenant_id, project_id, name, type, owner_id, baseline_date`; validar required fields e relações autorizadas.
- **FR-007-03:** atualizar somente campos mutáveis e transições válidas; usar `expected_version` em mutações concorrentes.
- **FR-007-04:** executar operações governadas: createMilestone, updateMilestone, changeForecast, completeMilestone, requestBaselineChange.
- **FR-007-05:** preservar ownership, histórico, origem e relacionamentos; nunca permitir vínculo cross-tenant.
- **FR-007-06:** registrar eventos/audit nas mudanças sensíveis e publicar projeções somente após commit.
- **FR-007-07:** respostas e exports aplicam scope e data policy por campo/registro.
- **FR-007-08:** states de loading, empty, validation error, forbidden, conflict e failure são distinguíveis na UI sem revelar dados protegidos.

- **FR-007-09:** Enforce the domain invariant: Baseline Date, Forecast Date e Actual Date nunca se sobrescrevem entre si.

## Requisitos não funcionais

Tenant isolation server-side/RLS; queries bounded e indexadas; idempotência em comandos repetíveis; datas UTC; logs minimizados; erros estáveis conforme `docs/08-api/errors.md`.

## Fora do escopo / decisões pendentes

Custom fields/workflow configurável, quotas comerciais e formatos não definidos pelo PDD permanecem fora do contrato até decisão explícita.

## Rastreabilidade

Invariante e campos desta Spec devem ser mapeados aos documentos correspondentes em `docs/06-data`, `docs/07-security`, `docs/08-api` e `docs/11-testing`.


## Acceptance/test traceability

- `FR-007-01` authorized query → `AC-007-01` → `TC-007-01`.
- `FR-007-02`, `FR-007-04` primary create/command → `AC-007-02` → `TC-007-01/02`.
- `FR-007-03` version/lifecycle → `AC-007-05` → `TC-007-03/05`.
- `FR-007-05` Tenant/source relationship → `AC-007-04` → `TC-007-04/05`.
- `FR-007-06` audit/post-commit → `AC-007-02` → `TC-007-06`.
- `FR-007-07` data policy/export → `AC-007-04` → `TC-007-07`.
- `FR-007-08` UI states/error surfaces → `AC-007-05` → `TC-007-08`; module-specific extensions remain listed in acceptance/tests.


- `FR-007-09` domain invariant → `AC-007-06` → `TC-007-10`.

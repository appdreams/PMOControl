# SPEC-020 — Financial — Requirements

**Status:** Draft — domínio especificado; revisão de contrato transversal pendente  
**Spec:** 020

## Objetivo e regra de domínio

Dados Restricted; baseline aprovada não muda com forecast/actual; access financial.view/edit explícito.

## Requisitos funcionais testáveis

- **FR-020-01:** consultar/listar Financial somente dentro de `Project + Financial permission`, com paginação/filtros allowlisted e sem revelar recursos não autorizados.
- **FR-020-02:** criar/derivar ProjectFinancials usando apenas campos aceitos pelo domínio: `project_id, currency, approved_budget, revised_budget, committed_amount, actual_amount`; validar required fields e relações autorizadas.
- **FR-020-03:** atualizar somente campos mutáveis e transições válidas; usar `expected_version` em mutações concorrentes.
- **FR-020-04:** executar operações governadas: readFinancials, recordCommitment, recordActual, updateForecast, requestBudgetBaselineChange.
- **FR-020-05:** preservar ownership, histórico, origem e relacionamentos; nunca permitir vínculo cross-tenant.
- **FR-020-06:** registrar eventos/audit nas mudanças sensíveis e publicar projeções somente após commit.
- **FR-020-07:** respostas e exports aplicam scope e data policy por campo/registro.
- **FR-020-08:** states de loading, empty, validation error, forbidden, conflict e failure são distinguíveis na UI sem revelar dados protegidos.

- **FR-020-09:** Enforce the domain invariant: Dados Restricted; baseline aprovada não muda com forecast/actual; access financial.view/edit explícito.

## Requisitos não funcionais

Tenant isolation server-side/RLS; queries bounded e indexadas; idempotência em comandos repetíveis; datas UTC; logs minimizados; erros estáveis conforme `docs/08-api/errors.md`.

## Fora do escopo / decisões pendentes

Custom fields/workflow configurável, quotas comerciais e formatos não definidos pelo PDD permanecem fora do contrato até decisão explícita.

## Rastreabilidade

Invariante e campos desta Spec devem ser mapeados aos documentos correspondentes em `docs/06-data`, `docs/07-security`, `docs/08-api` e `docs/11-testing`.


## Acceptance/test traceability

- `FR-020-01` authorized query → `AC-020-01` → `TC-020-01`.
- `FR-020-02`, `FR-020-04` primary create/command → `AC-020-02` → `TC-020-01/02`.
- `FR-020-03` version/lifecycle → `AC-020-05` → `TC-020-03/05`.
- `FR-020-05` Tenant/source relationship → `AC-020-04` → `TC-020-04/05`.
- `FR-020-06` audit/post-commit → `AC-020-02` → `TC-020-06`.
- `FR-020-07` data policy/export → `AC-020-04` → `TC-020-07`.
- `FR-020-08` UI states/error surfaces → `AC-020-05` → `TC-020-08`; module-specific extensions remain listed in acceptance/tests.


- `FR-020-09` domain invariant → `AC-020-06` → `TC-020-10`.

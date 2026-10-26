# SPEC-012 — Decisions — Requirements

**Status:** Draft — domínio especificado; revisão de contrato transversal pendente  
**Spec:** 012

## Objetivo e regra de domínio

Approve/Reject/Defer exige ator autorizado, prazo/contexto e histórico append-oriented.

## Requisitos funcionais testáveis

- **FR-012-01:** consultar/listar Decisions somente dentro de `Project/Decision`, com paginação/filtros allowlisted e sem revelar recursos não autorizados.
- **FR-012-02:** criar/derivar Decision usando apenas campos aceitos pelo domínio: `tenant_id, project_id, subject, context, options, requested_by`; validar required fields e relações autorizadas.
- **FR-012-03:** atualizar somente campos mutáveis e transições válidas; usar `expected_version` em mutações concorrentes.
- **FR-012-04:** executar operações governadas: createDecisionRequest, approveDecision, rejectDecision, deferDecision, commentDecision.
- **FR-012-05:** preservar ownership, histórico, origem e relacionamentos; nunca permitir vínculo cross-tenant.
- **FR-012-06:** registrar eventos/audit nas mudanças sensíveis e publicar projeções somente após commit.
- **FR-012-07:** respostas e exports aplicam scope e data policy por campo/registro.
- **FR-012-08:** states de loading, empty, validation error, forbidden, conflict e failure são distinguíveis na UI sem revelar dados protegidos.

- **FR-012-09:** Enforce the domain invariant: Approve/Reject/Defer exige ator autorizado, prazo/contexto e histórico append-oriented.

## Requisitos não funcionais

Tenant isolation server-side/RLS; queries bounded e indexadas; idempotência em comandos repetíveis; datas UTC; logs minimizados; erros estáveis conforme `docs/08-api/errors.md`.

## Fora do escopo / decisões pendentes

Custom fields/workflow configurável, quotas comerciais e formatos não definidos pelo PDD permanecem fora do contrato até decisão explícita.

## Rastreabilidade

Invariante e campos desta Spec devem ser mapeados aos documentos correspondentes em `docs/06-data`, `docs/07-security`, `docs/08-api` e `docs/11-testing`.


## Acceptance/test traceability

- `FR-012-01` authorized query → `AC-012-01` → `TC-012-01`.
- `FR-012-02`, `FR-012-04` primary create/command → `AC-012-02` → `TC-012-01/02`.
- `FR-012-03` version/lifecycle → `AC-012-05` → `TC-012-03/05`.
- `FR-012-05` Tenant/source relationship → `AC-012-04` → `TC-012-04/05`.
- `FR-012-06` audit/post-commit → `AC-012-02` → `TC-012-06`.
- `FR-012-07` data policy/export → `AC-012-04` → `TC-012-07`.
- `FR-012-08` UI states/error surfaces → `AC-012-05` → `TC-012-08`; module-specific extensions remain listed in acceptance/tests.


- `FR-012-09` domain invariant → `AC-012-06` → `TC-012-10`.

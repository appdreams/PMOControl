# SPEC-008 — Deliverables — Requirements

**Status:** Draft — domínio especificado; revisão de contrato transversal pendente  
**Spec:** 008

## Objetivo e regra de domínio

Delivered não equivale a Accepted quando aceite formal for exigido; evidência permanece vinculada.

## Requisitos funcionais testáveis

- **FR-008-01:** consultar/listar Deliverables somente dentro de `Project`, com paginação/filtros allowlisted e sem revelar recursos não autorizados.
- **FR-008-02:** criar/derivar Deliverable usando apenas campos aceitos pelo domínio: `tenant_id, project_id, milestone_id, name, owner_id, baseline_date`; validar required fields e relações autorizadas.
- **FR-008-03:** atualizar somente campos mutáveis e transições válidas; usar `expected_version` em mutações concorrentes.
- **FR-008-04:** executar operações governadas: createDeliverable, updateDeliverable, recordDelivery, acceptDeliverable, rejectAcceptance.
- **FR-008-05:** preservar ownership, histórico, origem e relacionamentos; nunca permitir vínculo cross-tenant.
- **FR-008-06:** registrar eventos/audit nas mudanças sensíveis e publicar projeções somente após commit.
- **FR-008-07:** respostas e exports aplicam scope e data policy por campo/registro.
- **FR-008-08:** states de loading, empty, validation error, forbidden, conflict e failure são distinguíveis na UI sem revelar dados protegidos.

- **FR-008-09:** Enforce the domain invariant: Delivered não equivale a Accepted quando aceite formal for exigido; evidência permanece vinculada.

## Requisitos não funcionais

Tenant isolation server-side/RLS; queries bounded e indexadas; idempotência em comandos repetíveis; datas UTC; logs minimizados; erros estáveis conforme `docs/08-api/errors.md`.

## Fora do escopo / decisões pendentes

Custom fields/workflow configurável, quotas comerciais e formatos não definidos pelo PDD permanecem fora do contrato até decisão explícita.

## Rastreabilidade

Invariante e campos desta Spec devem ser mapeados aos documentos correspondentes em `docs/06-data`, `docs/07-security`, `docs/08-api` e `docs/11-testing`.


## Acceptance/test traceability

- `FR-008-01` authorized query → `AC-008-01` → `TC-008-01`.
- `FR-008-02`, `FR-008-04` primary create/command → `AC-008-02` → `TC-008-01/02`.
- `FR-008-03` version/lifecycle → `AC-008-05` → `TC-008-03/05`.
- `FR-008-05` Tenant/source relationship → `AC-008-04` → `TC-008-04/05`.
- `FR-008-06` audit/post-commit → `AC-008-02` → `TC-008-06`.
- `FR-008-07` data policy/export → `AC-008-04` → `TC-008-07`.
- `FR-008-08` UI states/error surfaces → `AC-008-05` → `TC-008-08`; module-specific extensions remain listed in acceptance/tests.


- `FR-008-09` domain invariant → `AC-008-06` → `TC-008-10`.

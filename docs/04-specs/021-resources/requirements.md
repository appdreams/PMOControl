# SPEC-021 — Resources — Requirements

**Status:** Draft — domínio especificado; revisão de contrato transversal pendente  
**Spec:** 021

## Objetivo e regra de domínio

Dados sensíveis; disponibilidade/capacidade não equivale a permission de ver dados pessoais ou financeiros.

## Requisitos funcionais testáveis

- **FR-021-01:** consultar/listar Resources somente dentro de `Tenant/Project/Resource scope`, com paginação/filtros allowlisted e sem revelar recursos não autorizados.
- **FR-021-02:** criar/derivar ResourceAllocation usando apenas campos aceitos pelo domínio: `tenant_id, project_id, person_id, role, skill, capacity`; validar required fields e relações autorizadas.
- **FR-021-03:** atualizar somente campos mutáveis e transições válidas; usar `expected_version` em mutações concorrentes.
- **FR-021-04:** executar operações governadas: listCapacity, allocateResource, updateAllocation, resolveConflict, deallocateResource.
- **FR-021-05:** preservar ownership, histórico, origem e relacionamentos; nunca permitir vínculo cross-tenant.
- **FR-021-06:** registrar eventos/audit nas mudanças sensíveis e publicar projeções somente após commit.
- **FR-021-07:** respostas e exports aplicam scope e data policy por campo/registro.
- **FR-021-08:** states de loading, empty, validation error, forbidden, conflict e failure são distinguíveis na UI sem revelar dados protegidos.

- **FR-021-09:** Enforce the domain invariant: Dados sensíveis; disponibilidade/capacidade não equivale a permission de ver dados pessoais ou financeiros.

## Requisitos não funcionais

Tenant isolation server-side/RLS; queries bounded e indexadas; idempotência em comandos repetíveis; datas UTC; logs minimizados; erros estáveis conforme `docs/08-api/errors.md`.

## Fora do escopo / decisões pendentes

Custom fields/workflow configurável, quotas comerciais e formatos não definidos pelo PDD permanecem fora do contrato até decisão explícita.

## Rastreabilidade

Invariante e campos desta Spec devem ser mapeados aos documentos correspondentes em `docs/06-data`, `docs/07-security`, `docs/08-api` e `docs/11-testing`.


## Acceptance/test traceability

- `FR-021-01` authorized query → `AC-021-01` → `TC-021-01`.
- `FR-021-02`, `FR-021-04` primary create/command → `AC-021-02` → `TC-021-01/02`.
- `FR-021-03` version/lifecycle → `AC-021-05` → `TC-021-03/05`.
- `FR-021-05` Tenant/source relationship → `AC-021-04` → `TC-021-04/05`.
- `FR-021-06` audit/post-commit → `AC-021-02` → `TC-021-06`.
- `FR-021-07` data policy/export → `AC-021-04` → `TC-021-07`.
- `FR-021-08` UI states/error surfaces → `AC-021-05` → `TC-021-08`; module-specific extensions remain listed in acceptance/tests.


- `FR-021-09` domain invariant → `AC-021-06` → `TC-021-10`.

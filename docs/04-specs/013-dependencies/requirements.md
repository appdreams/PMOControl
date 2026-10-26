# SPEC-013 — Dependencies — Requirements

**Status:** Draft — domínio especificado; revisão de contrato transversal pendente  
**Spec:** 013

## Objetivo e regra de domínio

Origem e destino devem estar no mesmo Tenant; ciclos e dependências inválidas são rejeitados ou explicitamente sinalizados.

## Requisitos funcionais testáveis

- **FR-013-01:** consultar/listar Dependencies somente dentro de `Project and linked resource`, com paginação/filtros allowlisted e sem revelar recursos não autorizados.
- **FR-013-02:** criar/derivar Dependency usando apenas campos aceitos pelo domínio: `tenant_id, source_type, source_id, target_type, target_id, dependency_type`; validar required fields e relações autorizadas.
- **FR-013-03:** atualizar somente campos mutáveis e transições válidas; usar `expected_version` em mutações concorrentes.
- **FR-013-04:** executar operações governadas: createDependency, updateDependency, resolveDependency, listImpactedItems.
- **FR-013-05:** preservar ownership, histórico, origem e relacionamentos; nunca permitir vínculo cross-tenant.
- **FR-013-06:** registrar eventos/audit nas mudanças sensíveis e publicar projeções somente após commit.
- **FR-013-07:** respostas e exports aplicam scope e data policy por campo/registro.
- **FR-013-08:** states de loading, empty, validation error, forbidden, conflict e failure são distinguíveis na UI sem revelar dados protegidos.

- **FR-013-09:** Enforce the domain invariant: Origem e destino devem estar no mesmo Tenant; ciclos e dependências inválidas são rejeitados ou explicitamente sinalizados.

## Requisitos não funcionais

Tenant isolation server-side/RLS; queries bounded e indexadas; idempotência em comandos repetíveis; datas UTC; logs minimizados; erros estáveis conforme `docs/08-api/errors.md`.

## Fora do escopo / decisões pendentes

Custom fields/workflow configurável, quotas comerciais e formatos não definidos pelo PDD permanecem fora do contrato até decisão explícita.

## Rastreabilidade

Invariante e campos desta Spec devem ser mapeados aos documentos correspondentes em `docs/06-data`, `docs/07-security`, `docs/08-api` e `docs/11-testing`.


## Acceptance/test traceability

- `FR-013-01` authorized query → `AC-013-01` → `TC-013-01`.
- `FR-013-02`, `FR-013-04` primary create/command → `AC-013-02` → `TC-013-01/02`.
- `FR-013-03` version/lifecycle → `AC-013-05` → `TC-013-03/05`.
- `FR-013-05` Tenant/source relationship → `AC-013-04` → `TC-013-04/05`.
- `FR-013-06` audit/post-commit → `AC-013-02` → `TC-013-06`.
- `FR-013-07` data policy/export → `AC-013-04` → `TC-013-07`.
- `FR-013-08` UI states/error surfaces → `AC-013-05` → `TC-013-08`; module-specific extensions remain listed in acceptance/tests.


- `FR-013-09` domain invariant → `AC-013-06` → `TC-013-10`.

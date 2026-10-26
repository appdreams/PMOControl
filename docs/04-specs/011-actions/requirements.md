# SPEC-011 — Actions — Requirements

**Status:** Draft — domínio especificado; revisão de contrato transversal pendente  
**Spec:** 011

## Objetivo e regra de domínio

Ação derivada mantém source_type/source_id; conclusão exige 100%/data real segundo regra definida.

## Requisitos funcionais testáveis

- **FR-011-01:** consultar/listar Actions somente dentro de `Project`, com paginação/filtros allowlisted e sem revelar recursos não autorizados.
- **FR-011-02:** criar/derivar Action usando apenas campos aceitos pelo domínio: `tenant_id, project_id, source_type, source_id, title, owner_id`; validar required fields e relações autorizadas.
- **FR-011-03:** atualizar somente campos mutáveis e transições válidas; usar `expected_version` em mutações concorrentes.
- **FR-011-04:** executar operações governadas: createAction, updateAction, reassignAction, completeAction, cancelAction.
- **FR-011-05:** preservar ownership, histórico, origem e relacionamentos; nunca permitir vínculo cross-tenant.
- **FR-011-06:** registrar eventos/audit nas mudanças sensíveis e publicar projeções somente após commit.
- **FR-011-07:** respostas e exports aplicam scope e data policy por campo/registro.
- **FR-011-08:** states de loading, empty, validation error, forbidden, conflict e failure são distinguíveis na UI sem revelar dados protegidos.

- **FR-011-09:** Enforce the domain invariant: Ação derivada mantém source_type/source_id; conclusão exige 100%/data real segundo regra definida.

## Requisitos não funcionais

Tenant isolation server-side/RLS; queries bounded e indexadas; idempotência em comandos repetíveis; datas UTC; logs minimizados; erros estáveis conforme `docs/08-api/errors.md`.

## Fora do escopo / decisões pendentes

Custom fields/workflow configurável, quotas comerciais e formatos não definidos pelo PDD permanecem fora do contrato até decisão explícita.

## Rastreabilidade

Invariante e campos desta Spec devem ser mapeados aos documentos correspondentes em `docs/06-data`, `docs/07-security`, `docs/08-api` e `docs/11-testing`.


## Acceptance/test traceability

- `FR-011-01` authorized query → `AC-011-01` → `TC-011-01`.
- `FR-011-02`, `FR-011-04` primary create/command → `AC-011-02` → `TC-011-01/02`.
- `FR-011-03` version/lifecycle → `AC-011-05` → `TC-011-03/05`.
- `FR-011-05` Tenant/source relationship → `AC-011-04` → `TC-011-04/05`.
- `FR-011-06` audit/post-commit → `AC-011-02` → `TC-011-06`.
- `FR-011-07` data policy/export → `AC-011-04` → `TC-011-07`.
- `FR-011-08` UI states/error surfaces → `AC-011-05` → `TC-011-08`; module-specific extensions remain listed in acceptance/tests.


- `FR-011-09` domain invariant → `AC-011-06` → `TC-011-10`.

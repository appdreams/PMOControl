# SPEC-004 — Portfolios — Requirements

**Status:** Draft — domínio especificado; revisão de contrato transversal pendente  
**Spec:** 004

## Objetivo e regra de domínio

Project associado deve pertencer ao mesmo Tenant; projeções derivam dos Projects autorizados.

## Requisitos funcionais testáveis

- **FR-004-01:** consultar/listar Portfolios somente dentro de `Tenant; Portfolio`, com paginação/filtros allowlisted e sem revelar recursos não autorizados.
- **FR-004-02:** criar/derivar Portfolio usando apenas campos aceitos pelo domínio: `tenant_id, name, code, owner_id, sponsor_id, category`; validar required fields e relações autorizadas.
- **FR-004-03:** atualizar somente campos mutáveis e transições válidas; usar `expected_version` em mutações concorrentes.
- **FR-004-04:** executar operações governadas: createPortfolio, updatePortfolio, archivePortfolio, associateProject, removeProject.
- **FR-004-05:** preservar ownership, histórico, origem e relacionamentos; nunca permitir vínculo cross-tenant.
- **FR-004-06:** registrar eventos/audit nas mudanças sensíveis e publicar projeções somente após commit.
- **FR-004-07:** respostas e exports aplicam scope e data policy por campo/registro.
- **FR-004-08:** states de loading, empty, validation error, forbidden, conflict e failure são distinguíveis na UI sem revelar dados protegidos.

- **FR-004-09:** Enforce the domain invariant: Project associado deve pertencer ao mesmo Tenant; projeções derivam dos Projects autorizados.

## Requisitos não funcionais

Tenant isolation server-side/RLS; queries bounded e indexadas; idempotência em comandos repetíveis; datas UTC; logs minimizados; erros estáveis conforme `docs/08-api/errors.md`.

## Fora do escopo / decisões pendentes

Custom fields/workflow configurável, quotas comerciais e formatos não definidos pelo PDD permanecem fora do contrato até decisão explícita.

## Rastreabilidade

Invariante e campos desta Spec devem ser mapeados aos documentos correspondentes em `docs/06-data`, `docs/07-security`, `docs/08-api` e `docs/11-testing`.


## Acceptance/test traceability

- `FR-004-01` authorized query → `AC-004-01` → `TC-004-01`.
- `FR-004-02`, `FR-004-04` primary create/command → `AC-004-02` → `TC-004-01/02`.
- `FR-004-03` version/lifecycle → `AC-004-05` → `TC-004-03/05`.
- `FR-004-05` Tenant/source relationship → `AC-004-04` → `TC-004-04/05`.
- `FR-004-06` audit/post-commit → `AC-004-02` → `TC-004-06`.
- `FR-004-07` data policy/export → `AC-004-04` → `TC-004-07`.
- `FR-004-08` UI states/error surfaces → `AC-004-05` → `TC-004-08`; module-specific extensions remain listed in acceptance/tests.


- `FR-004-09` domain invariant → `AC-004-06` → `TC-004-10`.

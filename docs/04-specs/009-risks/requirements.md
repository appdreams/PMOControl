# SPEC-009 — Risks — Requirements

**Status:** Draft — domínio especificado; revisão de contrato transversal pendente  
**Spec:** 009

## Objetivo e regra de domínio

Risk representa evento futuro incerto; materialização cria/vincula Issue sem apagar histórico do Risk.

## Requisitos funcionais testáveis

- **FR-009-01:** consultar/listar Risks somente dentro de `Project`, com paginação/filtros allowlisted e sem revelar recursos não autorizados.
- **FR-009-02:** criar/derivar Risk usando apenas campos aceitos pelo domínio: `tenant_id, project_id, title, cause, consequence, category`; validar required fields e relações autorizadas.
- **FR-009-03:** atualizar somente campos mutáveis e transições válidas; usar `expected_version` em mutações concorrentes.
- **FR-009-04:** executar operações governadas: createRisk, assessRisk, updateResponse, materializeRisk, closeRisk.
- **FR-009-05:** preservar ownership, histórico, origem e relacionamentos; nunca permitir vínculo cross-tenant.
- **FR-009-06:** registrar eventos/audit nas mudanças sensíveis e publicar projeções somente após commit.
- **FR-009-07:** respostas e exports aplicam scope e data policy por campo/registro.
- **FR-009-08:** states de loading, empty, validation error, forbidden, conflict e failure são distinguíveis na UI sem revelar dados protegidos.

- **FR-009-09:** Enforce the domain invariant: Risk representa evento futuro incerto; materialização cria/vincula Issue sem apagar histórico do Risk.

## Requisitos não funcionais

Tenant isolation server-side/RLS; queries bounded e indexadas; idempotência em comandos repetíveis; datas UTC; logs minimizados; erros estáveis conforme `docs/08-api/errors.md`.

## Fora do escopo / decisões pendentes

Custom fields/workflow configurável, quotas comerciais e formatos não definidos pelo PDD permanecem fora do contrato até decisão explícita.

## Rastreabilidade

Invariante e campos desta Spec devem ser mapeados aos documentos correspondentes em `docs/06-data`, `docs/07-security`, `docs/08-api` e `docs/11-testing`.


## Acceptance/test traceability

- `FR-009-01` authorized query → `AC-009-01` → `TC-009-01`.
- `FR-009-02`, `FR-009-04` primary create/command → `AC-009-02` → `TC-009-01/02`.
- `FR-009-03` version/lifecycle → `AC-009-05` → `TC-009-03/05`.
- `FR-009-05` Tenant/source relationship → `AC-009-04` → `TC-009-04/05`.
- `FR-009-06` audit/post-commit → `AC-009-02` → `TC-009-06`.
- `FR-009-07` data policy/export → `AC-009-04` → `TC-009-07`.
- `FR-009-08` UI states/error surfaces → `AC-009-05` → `TC-009-08`; module-specific extensions remain listed in acceptance/tests.


- `FR-009-09` domain invariant → `AC-009-06` → `TC-009-10`.

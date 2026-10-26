# SPEC-010 — Issues — Requirements

**Status:** Draft — domínio especificado; revisão de contrato transversal pendente  
**Spec:** 010

## Objetivo e regra de domínio

Issue representa problema ocorrido; prioridade segue a escala comum do PDD, `blocker` é um booleano explícito e aging deriva das datas.

## Requisitos funcionais testáveis

- **FR-010-01:** consultar/listar Issues somente dentro de `Project`, com paginação/filtros allowlisted e sem revelar recursos não autorizados.
- **FR-010-02:** criar/derivar Issue usando apenas campos aceitos pelo domínio: `tenant_id, project_id, source_risk_id, description, root_cause, impact`; validar required fields e relações autorizadas.
- **FR-010-03:** atualizar somente campos mutáveis e transições válidas; usar `expected_version` em mutações concorrentes.
- **FR-010-04:** executar operações governadas: createIssue, updateIssue, assignOwner, resolveIssue, closeIssue, linkRisk.
- **FR-010-05:** preservar ownership, histórico, origem e relacionamentos; nunca permitir vínculo cross-tenant.
- **FR-010-06:** registrar eventos/audit nas mudanças sensíveis e publicar projeções somente após commit.
- **FR-010-07:** respostas e exports aplicam scope e data policy por campo/registro.
- **FR-010-08:** states de loading, empty, validation error, forbidden, conflict e failure são distinguíveis na UI sem revelar dados protegidos.

- **FR-010-09:** Enforce the domain invariant: Issue representa problema ocorrido; priority e blocker são explícitos, aging deriva de datas.

## Requisitos não funcionais

Tenant isolation server-side/RLS; queries bounded e indexadas; idempotência em comandos repetíveis; datas UTC; logs minimizados; erros estáveis conforme `docs/08-api/errors.md`.

## Fora do escopo / decisões pendentes

Custom fields/workflow configurável, quotas comerciais e formatos não definidos pelo PDD permanecem fora do contrato até decisão explícita.

## Rastreabilidade

Invariante e campos desta Spec devem ser mapeados aos documentos correspondentes em `docs/06-data`, `docs/07-security`, `docs/08-api` e `docs/11-testing`.


## Acceptance/test traceability

- `FR-010-01` authorized query → `AC-010-01` → `TC-010-01`.
- `FR-010-02`, `FR-010-04` primary create/command → `AC-010-02` → `TC-010-01/02`.
- `FR-010-03` version/lifecycle → `AC-010-05` → `TC-010-03/05`.
- `FR-010-05` Tenant/source relationship → `AC-010-04` → `TC-010-04/05`.
- `FR-010-06` audit/post-commit → `AC-010-02` → `TC-010-06`.
- `FR-010-07` data policy/export → `AC-010-04` → `TC-010-07`.
- `FR-010-08` UI states/error surfaces → `AC-010-05` → `TC-010-08`; module-specific extensions remain listed in acceptance/tests.


- `FR-010-09` domain invariant → `AC-010-06` → `TC-010-10`.

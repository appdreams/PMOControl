# SPEC-005 — Projects — Requirements

**Status:** Draft — domínio especificado; revisão de contrato transversal pendente  
**Spec:** 005

## Objetivo e regra de domínio

Baseline, Forecast e Actual são fatos distintos; Project define scope de autorização.

## Requisitos funcionais testáveis

- **FR-005-01:** consultar/listar Projects somente dentro de `Tenant/Portfolio/Project`, com paginação/filtros allowlisted e sem revelar recursos não autorizados.
- **FR-005-02:** criar/derivar Project usando apenas campos aceitos pelo domínio: `tenant_id, portfolio_id, name, code, sponsor_id, project_manager_id`; validar required fields e relações autorizadas.
- **FR-005-03:** atualizar somente campos mutáveis e transições válidas; usar `expected_version` em mutações concorrentes.
- **FR-005-04:** executar operações governadas: createProject, updateProject, changeBaseline, assignMember, archiveProject.
- **FR-005-05:** preservar ownership, histórico, origem e relacionamentos; nunca permitir vínculo cross-tenant.
- **FR-005-06:** registrar eventos/audit nas mudanças sensíveis e publicar projeções somente após commit.
- **FR-005-07:** respostas e exports aplicam scope e data policy por campo/registro.
- **FR-005-08:** states de loading, empty, validation error, forbidden, conflict e failure são distinguíveis na UI sem revelar dados protegidos.

- **FR-005-09:** Enforce the domain invariant: Baseline, Forecast e Actual são fatos distintos; Project define scope de autorização.
- **FR-005-10:** permitir que Platform Root Admin com grant específico solicite exclusão definitiva de um Project por fluxo administrativo isolado, com prévia de impacto, confirmação explícita, motivo e auditoria; não conceder acesso ao conteúdo de negócio do Tenant.
- **FR-005-11:** no purge do Project, excluir permanentemente registros operacionais elegíveis, preservar registros ainda sujeitos a retenção/legal hold em arquivo histórico isolado e manter identidade mínima/tombstone enquanto houver referência retida; não alterar publicações, snapshots nem audit imutáveis.

## Requisitos não funcionais

Tenant isolation server-side/RLS; queries bounded e indexadas; idempotência em comandos repetíveis; datas UTC; logs minimizados; erros estáveis conforme `docs/08-api/errors.md`.

## Fora do escopo / decisões pendentes

Custom fields/workflow configurável, quotas comerciais e formatos não definidos pelo PDD permanecem fora do contrato até decisão explícita.

## Rastreabilidade

Invariante e campos desta Spec devem ser mapeados aos documentos correspondentes em `docs/06-data`, `docs/07-security`, `docs/08-api` e `docs/11-testing`.


## Acceptance/test traceability

- `FR-005-01` authorized query → `AC-005-01` → `TC-005-01`.
- `FR-005-02`, `FR-005-04` primary create/command → `AC-005-02` → `TC-005-01/02`.
- `FR-005-03` version/lifecycle → `AC-005-05` → `TC-005-03/05`.
- `FR-005-05` Tenant/source relationship → `AC-005-04` → `TC-005-04/05`.
- `FR-005-06` audit/post-commit → `AC-005-02` → `TC-005-06`.
- `FR-005-07` data policy/export → `AC-005-04` → `TC-005-07`.
- `FR-005-08` UI states/error surfaces → `AC-005-05` → `TC-005-08`; module-specific extensions remain listed in acceptance/tests.


- `FR-005-09` domain invariant → `AC-005-06` → `TC-005-10`.
- `FR-005-10/11` privileged purge, retained history and no content access → `AC-005-07/08` → `TC-005-11–14`.

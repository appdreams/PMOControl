# SPEC-024 — Report Builder — Requirements

**Status:** Draft — domínio especificado; revisão de contrato transversal pendente  
**Spec:** 024

## Objetivo e regra de domínio

Relatório declara contexto temporal e aplica autorização/data policy na consulta e no download.

## Requisitos funcionais testáveis

- **FR-024-01:** consultar/listar Report Builder somente dentro de `User + authorized Tenant/Projects`, com paginação/filtros allowlisted e sem revelar recursos não autorizados.
- **FR-024-02:** criar/derivar ReportJob usando apenas campos aceitos pelo domínio: `tenant_id, requested_by, template_id, filters, temporal_mode, as_of`; validar required fields e relações autorizadas.
- **FR-024-03:** atualizar somente campos mutáveis e transições válidas; usar `expected_version` em mutações concorrentes.
- **FR-024-04:** executar operações governadas: listTemplates, previewReport, createReportJob, getReportJob, downloadReport.
- **FR-024-05:** preservar ownership, histórico, origem e relacionamentos; nunca permitir vínculo cross-tenant.
- **FR-024-06:** registrar eventos/audit nas mudanças sensíveis e publicar projeções somente após commit.
- **FR-024-07:** respostas e exports aplicam scope e data policy por campo/registro.
- **FR-024-08:** states de loading, empty, validation error, forbidden, conflict e failure são distinguíveis na UI sem revelar dados protegidos.

- **FR-024-09:** Enforce the domain invariant: Relatório declara contexto temporal e aplica autorização/data policy na consulta e no download.

## Requisitos não funcionais

Tenant isolation server-side/RLS; queries bounded e indexadas; idempotência em comandos repetíveis; datas UTC; logs minimizados; erros estáveis conforme `docs/08-api/errors.md`.

## Fora do escopo / decisões pendentes

Custom fields/workflow configurável, quotas comerciais e formatos não definidos pelo PDD permanecem fora do contrato até decisão explícita.

## Rastreabilidade

Invariante e campos desta Spec devem ser mapeados aos documentos correspondentes em `docs/06-data`, `docs/07-security`, `docs/08-api` e `docs/11-testing`.


## Acceptance/test traceability

- `FR-024-01` authorized query → `AC-024-01` → `TC-024-01`.
- `FR-024-02`, `FR-024-04` primary create/command → `AC-024-02` → `TC-024-01/02`.
- `FR-024-03` version/lifecycle → `AC-024-05` → `TC-024-03/05`.
- `FR-024-05` Tenant/source relationship → `AC-024-04` → `TC-024-04/05`.
- `FR-024-06` audit/post-commit → `AC-024-02` → `TC-024-06`.
- `FR-024-07` data policy/export → `AC-024-04` → `TC-024-07`.
- `FR-024-08` UI states/error surfaces → `AC-024-05` → `TC-024-08`; module-specific extensions remain listed in acceptance/tests.


- `FR-024-09` domain invariant → `AC-024-06` → `TC-024-10`.

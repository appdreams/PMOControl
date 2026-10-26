# SPEC-022 — Documents — Requirements

**Status:** Draft — domínio especificado; revisão de contrato transversal pendente  
**Spec:** 022

## Objetivo e regra de domínio

Binário privado; metadata no banco; download/upload sempre autorizado no servidor e classificação aplicada.

## Requisitos funcionais testáveis

- **FR-022-01:** consultar/listar Documents somente dentro de `Project + Document classification`, com paginação/filtros allowlisted e sem revelar recursos não autorizados.
- **FR-022-02:** criar/derivar Document usando apenas campos aceitos pelo domínio: `tenant_id, project_id, storage_key, filename, mime_type, size_bytes`; validar required fields e relações autorizadas.
- **FR-022-03:** atualizar somente campos mutáveis e transições válidas; usar `expected_version` em mutações concorrentes.
- **FR-022-04:** executar operações governadas: uploadDocument, getMetadata, downloadDocument, createVersion, linkEvidence, archiveDocument.
- **FR-022-05:** preservar ownership, histórico, origem e relacionamentos; nunca permitir vínculo cross-tenant.
- **FR-022-06:** registrar eventos/audit nas mudanças sensíveis e publicar projeções somente após commit.
- **FR-022-07:** respostas e exports aplicam scope e data policy por campo/registro.
- **FR-022-08:** states de loading, empty, validation error, forbidden, conflict e failure são distinguíveis na UI sem revelar dados protegidos.

- **FR-022-09:** Enforce the domain invariant: Binário privado; metadata no banco; download/upload sempre autorizado no servidor e classificação aplicada.

## Requisitos não funcionais

Tenant isolation server-side/RLS; queries bounded e indexadas; idempotência em comandos repetíveis; datas UTC; logs minimizados; erros estáveis conforme `docs/08-api/errors.md`.

## Fora do escopo / decisões pendentes

Custom fields/workflow configurável, quotas comerciais e formatos não definidos pelo PDD permanecem fora do contrato até decisão explícita.

## Rastreabilidade

Invariante e campos desta Spec devem ser mapeados aos documentos correspondentes em `docs/06-data`, `docs/07-security`, `docs/08-api` e `docs/11-testing`.


## Acceptance/test traceability

- `FR-022-01` authorized query → `AC-022-01` → `TC-022-01`.
- `FR-022-02`, `FR-022-04` primary create/command → `AC-022-02` → `TC-022-01/02`.
- `FR-022-03` version/lifecycle → `AC-022-05` → `TC-022-03/05`.
- `FR-022-05` Tenant/source relationship → `AC-022-04` → `TC-022-04/05`.
- `FR-022-06` audit/post-commit → `AC-022-02` → `TC-022-06`.
- `FR-022-07` data policy/export → `AC-022-04` → `TC-022-07`.
- `FR-022-08` UI states/error surfaces → `AC-022-05` → `TC-022-08`; module-specific extensions remain listed in acceptance/tests.


- `FR-022-09` domain invariant → `AC-022-06` → `TC-022-10`.

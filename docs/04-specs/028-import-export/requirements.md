# SPEC-028 — Import & Export — Requirements

**Status:** Draft — domínio especificado; revisão de contrato transversal pendente  
**Spec:** 028

## Objetivo e regra de domínio

Importação genérica segue staging→validate→preview→confirm→apply; project XLSX v1 define exceção de carga inicial quando não há dados ativos, e export revalida permissão/data policy por campo e linha.

## Requisitos funcionais testáveis

- **FR-028-01:** consultar/listar Import & Export somente dentro de `Tenant + authorized entities/fields`, com paginação/filtros allowlisted e sem revelar recursos não autorizados.
- **FR-028-02:** criar/derivar DataJob usando apenas campos aceitos pelo domínio: `tenant_id, actor_id, direction, entity_type, source_file_key, mapping_version`; validar required fields e relações autorizadas.
- **FR-028-03:** atualizar somente campos mutáveis e transições válidas; usar `expected_version` em mutações concorrentes.
- **FR-028-04:** executar operações governadas: listImportableProjects, downloadProjectImportTemplate, createProjectImportJob, validateImport, previewImport, appendProjectData, replaceProjectData, createExportJob, downloadExport.
- **FR-028-05:** preservar ownership, histórico, origem e relacionamentos; nunca permitir vínculo cross-tenant.
- **FR-028-06:** registrar eventos/audit nas mudanças sensíveis e publicar projeções somente após commit.
- **FR-028-07:** respostas e exports aplicam scope e data policy por campo/registro.
- **FR-028-08:** states de loading, empty, validation error, forbidden, conflict e failure são distinguíveis na UI sem revelar dados protegidos.

- **FR-028-09:** Enforce staging→validation→preview before source mutation; existing populated projects require explicit append/replace confirmation, empty v1 project scope follows FR-028-13; export revalida permissão/data policy por campo e linha.
- **FR-028-10 — projeto do Tenant:** usuário com `project.data.import` lista/seleciona somente projetos ativos do Tenant verificado em que possui escopo; `project_id` do arquivo nunca autoriza nem altera o alvo.
- **FR-028-11 — modelos Excel:** oferecer download de modelo `.xlsx` vazio e exemplo `.xlsx` populado, ambos versionados e com exatamente o mesmo schema; template identifica o projeto selecionado, exemplo usa dados sintéticos coerentes e não contém PII real.
- **FR-028-12 — formato e validação:** aceitar somente `project-import-v1` `.xlsx`, abas/cabeçalhos estritos, sem macros, fórmulas, links externos ou colunas desconhecidas; validar escopo, tipos, enums, relações, usuários, IDs externos e limites antes de qualquer escrita.
- **FR-028-13 — carga inicial:** quando não existirem registros operacionais ativos no escopo de entidades v1, não perguntar modo adicionar/reiniciar; depois de upload, validação e preview sem erros, aplicar a carga inicial sem prompt de modo.
- **FR-028-14 — adicionar dados:** quando houver dados ativos, opção “Adicionar dados” somente insere novas entidades; chave externa já existente ou duplicada bloqueia a importação sem sobrescrita implícita.
- **FR-028-15 — reiniciar dados:** quando houver dados ativos, opção “Reiniciar dados do projeto” exige grant separado, resumo/contagens e confirmação digitada; substitui atomicamente os registros operacionais ativos cobertos pelo workbook no projeto selecionado, mantendo audit, publicações, snapshots, holds e histórico imutáveis.
- **FR-028-16 — atomicidade/isolamento:** falha em qualquer linha/regra não produz importação parcial; reinício afeta apenas o alvo e o escopo explicitamente declarado no `project-import-template-v1.md`, preservando integridade de vínculos externos.

## Requisitos não funcionais

Tenant isolation server-side/RLS; queries bounded e indexadas; idempotência em comandos repetíveis; datas UTC; logs minimizados; erros estáveis conforme `docs/08-api/errors.md`.

## Fora do escopo / decisões pendentes

Custom fields/workflow configurável, quotas comerciais e formatos não definidos pelo PDD permanecem fora do contrato até decisão explícita.

## Rastreabilidade

Invariante e campos desta Spec devem ser mapeados aos documentos correspondentes em `docs/06-data`, `docs/07-security`, `docs/08-api` e `docs/11-testing`.


## Acceptance/test traceability

- `FR-028-01` authorized query → `AC-028-01` → `TC-028-01`.
- `FR-028-02`, `FR-028-04` primary create/command → `AC-028-02` → `TC-028-01/02`.
- `FR-028-03` version/lifecycle → `AC-028-05` → `TC-028-03/05`.
- `FR-028-05` Tenant/source relationship → `AC-028-04` → `TC-028-04/05`.
- `FR-028-06` audit/post-commit → `AC-028-02` → `TC-028-06`.
- `FR-028-07` data policy/export → `AC-028-04` → `TC-028-07`.
- `FR-028-08` UI states/error surfaces → `AC-028-05` → `TC-028-08`; module-specific extensions remain listed in acceptance/tests.


- `FR-028-09` domain invariant → `AC-028-06` → `TC-028-10`.
- `FR-028-10` scoped project selection → `AC-028-07` → `TC-028-11/12`.
- `FR-028-11` blank/sample workbook → `AC-028-08` → `TC-028-13`.
- `FR-028-12` strict file/schema/row validation → `AC-028-08/12` → `TC-028-14/15`.
- `FR-028-13` initial empty-project import → `AC-028-09` → `TC-028-16`.
- `FR-028-14` append-only update mode → `AC-028-10` → `TC-028-17/18`.
- `FR-028-15` scoped restart and history retention → `AC-028-11` → `TC-028-19/20/22`.
- `FR-028-16` replacement atomicity and project isolation → `AC-028-12` → `TC-028-21/22`.

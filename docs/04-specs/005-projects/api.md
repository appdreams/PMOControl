# SPEC-005 — Projects — API

**Status:** Draft — logical operations and payload allowlists defined; OpenAPI materialization and implementation alignment pending

## Resource lógico

`/api/v1/projects` — convenção base de `docs/08-api`. Scope: `Tenant/Portfolio/Project`.

## Operações e schemas

Request JSON camelCase; `tenantId`, actor, status, grants, version e valores calculados são server-owned e rejeitados se enviados. Recurso responde `{data:{id,tenantId,status,version,...},meta:{requestId}}`.

| Operação | Rota | Request allowlist | Resultado |
|---|---|---|---|
| Create | `POST /api/v1/projects` | `portfolioId,name,code,sponsorId?,projectManagerId?,priority?,startDate?,targetEndDate?` | `201` Project `planning`, associação ao Portfolio e versão 1 |
| Update | `PATCH /api/v1/projects/{id}` | `name?,code?,sponsorId?,projectManagerId?,priority?,startDate?,targetEndDate?`, `If-Match` obrigatório | `200` Project atualizado |
| Change baseline | `POST /api/v1/projects/{id}/baseline-changes` | `reason`, `proposed:{startDate,targetEndDate,scope?,budget?}`, `Idempotency-Key` e `If-Match` | `202` change request; baseline só altera após aprovação autorizada |
| Assign member | `POST /api/v1/projects/{id}/assignments` | `userId,assignmentRole,startsAt?,expiresAt?,reason?` | `201` assignment no Tenant; não emite autorização além do grant permitido |
| Archive | `POST /api/v1/projects/{id}/archive` | `reason`, `If-Match`, `Idempotency-Key` | `200` mantém estado do Project e define `archivedAt` |
| Purge selector | `GET /api/v1/platform/projects` | `cursor?,limit?,status?` | `200` minimal project/tenant metadata only; requires `platform.projects.purge` |
| Purge preview | `POST /api/v1/platform/projects/{id}/purge-preview` | `If-Match` | `200` somente metadados: identidade do Project, contagens por categoria, retenção/holds, dependências e `confirmationToken` de uso único e curta validade; requer `platform.projects.purge` |
| Request permanent purge | `POST /api/v1/platform/projects/{id}/purge` | `reason`, `confirmationToken`, `typedProjectCode`, `previewVersion`, `Idempotency-Key` | `202` cria/retorna `project_purge_job`; Project torna-se não operacional, histórico retido é preservado e purge elegível roda de forma durável |
| Purge job status | `GET /api/v1/platform/project-purge-jobs/{jobId}` | — | `200` estado, contagens e itens retidos/bloqueados; nunca conteúdo do Tenant |

`GET /api/v1/projects` aceita `cursor,limit,portfolioId,status,projectManagerId,sort`; association/assignment queries revalidam Tenant e grant. Grants: `projects.create|view|edit|archive|assign` e `baseline.change`.

## Contrato comum

JSON; IDs UUID; datas ISO-8601/UTC; paginação por cursor em listas grandes; filtros/sorts allowlisted; `expected_version` em update concorrente; idempotency key em comandos com retry. Cada operação revalida grants server-side.

## Erros

Logical request/response fields and domain constraints are listed above; a compilable OpenAPI contract and implementation alignment remain release gates.

`GET /api/v1/platform/projects` (seletor administrativo) requer `platform.projects.purge` e retorna somente `projectId,projectCode,projectName,tenantDisplayName,status,version` a Platform Root Admin com `platform.projects.purge`. Esse grant não implica `projects.view` nem acesso a conteúdo do Tenant.

# SPEC-005 — Projects — API

**Status:** Partial — list/create/update/archive and Project Manager transfer implemented in DEV; broader member assignments pending

## Resource lógico

Rotas implementadas: `/api/v1/tenants/{tenantId}/projects?portfolioId={portfolioId}`, `/api/v1/tenants/{tenantId}/projects/{projectId}` e `/api/v1/tenants/{tenantId}/projects/{projectId}/archive`. Scope: `Tenant/Portfolio/Project`.

## Operações e schemas

Request JSON camelCase; `tenantId`, actor, status, grants, version e valores calculados são server-owned e rejeitados se enviados. Recurso responde `{data:{id,tenantId,status,version,...},meta:{requestId}}`.

| Operação | Rota | Request allowlist | Resultado |
|---|---|---|---|
| List | `GET /api/v1/tenants/{tenantId}/projects?portfolioId={portfolioId}` | tenant e Portfolio na rota/query | `200` apenas Projects com `project.view` exato e associação ativa; retorna `associationId`, `associationVersion`, `canRemoveAssociation` e `canCreate` calculados no servidor |
| Create | `POST /api/v1/tenants/{tenantId}/projects` | `portfolioId,name,code?,sponsorId?,priority?,scopeSummary?,startDate?,targetEndDate?,reason,idempotencyKey`; gerente é o ator autenticado | `201` Project `planning`, associação ao Portfolio, grant inicial `project_manager` no Project e audit atômico |
| Update | `PATCH /api/v1/tenants/{tenantId}/projects/{projectId}` | `name?,code?,sponsorId?,priority?,scopeSummary?,startDate?,targetEndDate?`, `expectedVersion,reason,idempotencyKey`; gerente/estado usam fluxos próprios | `200` Project atualizado |
| List manager candidates | `GET /api/v1/tenants/{tenantId}/projects/{projectId}/manager` | tenant e Project na rota | `200` nome mínimo do gerente atual e candidatos com membership ativa; exige `project.assign` exato |
| Assign Project Manager | `POST /api/v1/tenants/{tenantId}/projects/{projectId}/manager` | `subjectId,expectedVersion,reason,idempotencyKey` | `200` Project com `projectManagerId` e versão incrementada; papel `project_manager` sincronizado na mesma transação |
| Change baseline | `POST /api/v1/projects/{id}/baseline-changes` | `reason`, `proposed:{startDate,targetEndDate,scope?,budget?}`, `Idempotency-Key` e `If-Match` | `202` change request; baseline só altera após aprovação autorizada |
| Assign member | `POST /api/v1/projects/{id}/assignments` | `userId,assignmentRole,startsAt?,expiresAt?,reason?` | `201` assignment no Tenant; não emite autorização além do grant permitido |
| Archive | `POST /api/v1/tenants/{tenantId}/projects/{projectId}/archive` | `reason,expectedVersion,idempotencyKey` | `200` mantém estado do Project e define `archivedAt` |
| Purge selector | `GET /api/v1/platform/projects` | `cursor?,limit?,status?` | `200` minimal project/tenant metadata only; requires `platform.projects.purge` |
| Purge preview | `POST /api/v1/platform/projects/{id}/purge-preview` | `If-Match` | `200` somente metadados: identidade do Project, contagens por categoria, retenção/holds, dependências e `confirmationToken` de uso único e curta validade; requer `platform.projects.purge` |
| Request permanent purge | `POST /api/v1/platform/projects/{id}/purge` | `reason`, `confirmationToken`, `typedProjectCode`, `previewVersion`, `Idempotency-Key` | `202` cria/retorna `project_purge_job`; Project torna-se não operacional, histórico retido é preservado e purge elegível roda de forma durável |
| Purge job status | `GET /api/v1/platform/project-purge-jobs/{jobId}` | — | `200` estado, contagens e itens retidos/bloqueados; nunca conteúdo do Tenant |

`GET /api/v1/projects` aceita `cursor,limit,portfolioId,status,projectManagerId,sort`; association/assignment queries revalidam Tenant e grant. Grants: `projects.create|view|edit|archive|assign` e `baseline.change`.

## Contrato comum

JSON; IDs UUID; datas ISO-8601/UTC; lista inicial ainda sem paginação; campos desconhecidos são rejeitados. Cada operação revalida membership/grant server-side. Update/archive usam versão esperada, motivo e chave idempotente; alteração de status/gerente continua em fluxos separados.

## Erros

Logical request/response fields and domain constraints are listed above; a compilable OpenAPI contract and implementation alignment remain release gates.

`GET /api/v1/platform/projects` (seletor administrativo) requer `platform.projects.purge` e retorna somente `projectId,projectCode,projectName,tenantDisplayName,status,version` a Platform Root Admin com `platform.projects.purge`. Esse grant não implica `projects.view` nem acesso a conteúdo do Tenant.

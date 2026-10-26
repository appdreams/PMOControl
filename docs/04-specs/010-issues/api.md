# SPEC-010 — Issues — API

**Status:** Draft — logical operations and payload allowlists defined; OpenAPI materialization and implementation alignment pending

## Resource lógico

`/api/v1/issues` — convenção base de `docs/08-api`. Scope: `Project`.

## Operações e schemas

| Operação | Rota | Request allowlist | Resultado |
|---|---|---|---|
| Create | `POST /api/v1/projects/{projectId}/issues` | `description,rootCause?,impact,priority,blocker,ownerId?,dueDate?,sourceRiskId?`; `openedAt` is server timestamp | `201` open + age calculado |
| Update | `PATCH /api/v1/issues/{id}` | `description?,rootCause?,impact?,priority?,blocker?,dueDate?`, `If-Match` | `200`; status/resolução só por comandos |
| Assign | `POST /api/v1/issues/{id}/owner` | `ownerId,reason?`, `If-Match`, `Idempotency-Key` | `200` novo owner |
| Resolve | `POST /api/v1/issues/{id}/resolve` | `resolution`, `If-Match`, `Idempotency-Key`; `resolvedAt` is server timestamp | `200` resolved com timestamp |
| Close | `POST /api/v1/issues/{id}/close` | `reason`, `If-Match`, `Idempotency-Key` | `200` closed; só após resolução |
| Link Risk | `PUT /api/v1/issues/{id}/source-risk` | `riskId`, `If-Match` | `200`; Risk deve ser do mesmo Project/Tenant |

`GET /api/v1/issues` aceita cursor, Project, status, blocker, priority, owner e due range allowlisted. Response retorna `ageDays` calculado, nunca persistido, além de status e versão. Permissions adicionais: `issues.assign`, `issues.resolve`, `issues.close`, `issues.link-risk`.

## Contrato comum

JSON; IDs UUID; datas ISO-8601/UTC; paginação por cursor em listas grandes; filtros/sorts allowlisted; `expected_version` em update concorrente; idempotency key em comandos com retry. Cada operação revalida grants server-side.

## Erros

Logical request/response fields and domain constraints are listed above; a compilable OpenAPI contract and implementation alignment remain release gates.

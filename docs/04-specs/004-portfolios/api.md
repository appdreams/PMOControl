# SPEC-004 — Portfolios — API

**Status:** Draft — logical operations and payload allowlists defined; OpenAPI materialization and implementation alignment pending

## Resource lógico

`/api/v1/portfolios` — convenção base de `docs/08-api`. Scope: `Tenant; Portfolio`.

## Operações e schemas

Todos os bodies são JSON camelCase; não aceitam `tenantId`, actor IDs, version de grant ou campos calculados como autoridade. Resposta de recurso: `{data:{id,tenantId,...,version},meta:{requestId}}`.

| Operação | Rota | Request allowlist | Resultado |
|---|---|---|---|
| Create | `POST /api/v1/portfolios` | `name` (1–160), `code` (1–40; normalizado uppercase), `ownerId`, `sponsorId?`, `category`, `startDate?`, `targetEndDate?` | `201` Portfolio active + version 1 |
| Update | `PATCH /api/v1/portfolios/{id}` | `name?`, `code?`, `ownerId?`, `sponsorId?`, `category?`, `startDate?`, `targetEndDate?`; header `If-Match` obrigatório | `200` resource + versão incrementada |
| Archive | `POST /api/v1/portfolios/{id}/archive` | `reason` (10–1000); `If-Match` obrigatório; `Idempotency-Key` | `200` archived resource; association history preservada |
| Associate Project | `POST /api/v1/portfolios/{id}/projects` | `projectId`; `Idempotency-Key` | `201` association; mesmo Tenant obrigatório |
| Remove association | `DELETE /api/v1/portfolios/{id}/projects/{projectId}` | `If-Match` da association e `reason` | `204`; não apaga Project |

`GET /api/v1/portfolios` aceita `cursor,limit,status,ownerId,sort`; `GET /{id}` retorna escopo não autorizado como 404. Grants: `portfolios.create|view|edit|archive` e `portfolio.projects.associate|remove`, sempre no Tenant/Portfolio scope.

## Contrato comum

JSON; IDs UUID; datas ISO-8601/UTC; paginação por cursor em listas grandes; filtros/sorts allowlisted; `expected_version` em update concorrente; idempotency key em comandos com retry. Cada operação revalida grants server-side.

## Erros

Logical request/response fields and domain constraints are listed above; a compilable OpenAPI contract and implementation alignment remain release gates.

# SPEC-007 — Milestones — API

**Status:** Draft — logical operations and payload allowlists defined; OpenAPI materialization and implementation alignment pending

## Resource lógico

`/api/v1/milestones` — convenção base de `docs/08-api`. Scope: `Project`.

## Operações e schemas

| Operação | Rota | Request allowlist | Resultado |
|---|---|---|---|
| Create | `POST /api/v1/projects/{projectId}/milestones` | `name,type,ownerId?,baselineDate?,criticality?` | `201` status planned, progress 0, versão 1 |
| Update | `PATCH /api/v1/milestones/{id}` | `name?,type?,ownerId?,criticality?`, `If-Match` | `200`; baseline/forecast/actual/status não são editáveis por PATCH |
| Forecast | `POST /api/v1/milestones/{id}/forecast` | `forecastDate,reason?`, `If-Match`, `Idempotency-Key` | `200` nova forecast version; baseline não muda |
| Complete | `POST /api/v1/milestones/{id}/complete` | `actualDate,completionEvidence?`, `If-Match`, `Idempotency-Key` | `200` completed, progress 100, actualDate registrado |
| Baseline change | `POST /api/v1/milestones/{id}/baseline-change-requests` | `proposedBaselineDate,reason`, `Idempotency-Key` | `202` request; baseline só muda via workflow aprovado |

Responses retornam `{data:{id,projectId,status,progress,baselineDate,forecastDate,actualDate,version},meta:{requestId}}`. Listagem aceita `cursor,limit,status,ownerId,dueFrom,dueTo`; grants `milestones.view|create|edit|forecast|complete|baseline.change`.

## Contrato comum

JSON; IDs UUID; datas ISO-8601/UTC; paginação por cursor em listas grandes; filtros/sorts allowlisted; `expected_version` em update concorrente; idempotency key em comandos com retry. Cada operação revalida grants server-side.

## Erros

Logical request/response fields and domain constraints are listed above; a compilable OpenAPI contract and implementation alignment remain release gates.

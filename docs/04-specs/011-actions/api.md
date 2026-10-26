# SPEC-011 — Actions — API

**Status:** Draft — logical operations and payload allowlists defined; OpenAPI materialization and implementation alignment pending

## Resource lógico

`/api/v1/actions` — convenção base de `docs/08-api`. Scope: `Project`.

## Operações e schemas

| Operação | Rota | Request allowlist | Resultado |
|---|---|---|---|
| Create | `POST /api/v1/projects/{projectId}/actions` | `sourceType?,sourceId?,title,description?,ownerId,priority,startDate?,dueDate?` | `201` not_started, progress 0 |
| Update | `PATCH /api/v1/actions/{id}` | `title?,description?,priority?,startDate?,dueDate?`, `If-Match` | `200`; source/status/progress não são editáveis por PATCH |
| Reassign | `POST /api/v1/actions/{id}/assignment` | `ownerId,reason`, `If-Match`, `Idempotency-Key` | `200` owner alterado e auditado |
| Complete | `POST /api/v1/actions/{id}/complete` | `actualCompletedAt?,completionOutcome,evidenceIds[]?`, `If-Match`, `Idempotency-Key` | `200` completed, progress 100 |
| Cancel | `POST /api/v1/actions/{id}/cancel` | `reason`, `If-Match`, `Idempotency-Key` | `200` cancelled; origem preservada |

`GET /api/v1/actions` aceita cursor, Project, source, owner, status, priority e due range allowlisted. Response retorna source ref, status, progress, overdue boolean derivado e version. Permissions adicionais: `actions.reassign`, `actions.complete`, `actions.cancel`.

## Contrato comum

JSON; IDs UUID; datas ISO-8601/UTC; paginação por cursor em listas grandes; filtros/sorts allowlisted; `expected_version` em update concorrente; idempotency key em comandos com retry. Cada operação revalida grants server-side.

## Erros

Logical request/response fields and domain constraints are listed above; a compilable OpenAPI contract and implementation alignment remain release gates.

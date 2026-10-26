# SPEC-013 — Dependencies — API

**Status:** Draft — logical operations and payload allowlists defined; OpenAPI materialization and implementation alignment pending

## Resource lógico

`/api/v1/dependencies` — convenção base de `docs/08-api`. Scope: `Project and linked resource`.

## Operações e schemas

| Operação | Rota | Request allowlist | Resultado |
|---|---|---|---|
| Create | `POST /api/v1/dependencies` | `sourceType,sourceId,targetType,targetId,dependencyType,ownerId?,criticality?,dueDate?,impact?,lagDays?` | `201` active; self-link, ciclo, Tenant/type inválido => `422` |
| Update | `PATCH /api/v1/dependencies/{id}` | `ownerId?,criticality?,dueDate?,impact?,lagDays?`, `If-Match` | `200`; endpoints/type não alteráveis em PATCH |
| Resolve | `POST /api/v1/dependencies/{id}/resolve` | `reason,resolvedAt?`, `If-Match`, `Idempotency-Key` | `200` resolved |
| Impacted items | `GET /api/v1/dependencies/impacted-items` | `type,id,direction=upstream|downstream,cursor,limit` | `200` grafo paginado de endpoints autorizados |

Tipos aceitos: `finish_to_start`, `start_to_start`, `finish_to_finish`, `start_to_finish`; endpoints: `project`, `deliverable`, `milestone`, `area`, `supplier`. Edges cross-project são válidas apenas no mesmo Tenant. Permissions adicionais: `dependencies.resolve` e `dependencies.view-impact`.

## Contrato comum

JSON; IDs UUID; datas ISO-8601/UTC; paginação por cursor em listas grandes; filtros/sorts allowlisted; `expected_version` em update concorrente; idempotency key em comandos com retry. Cada operação revalida grants server-side.

## Erros

Logical request/response fields and domain constraints are listed above; a compilable OpenAPI contract and implementation alignment remain release gates.

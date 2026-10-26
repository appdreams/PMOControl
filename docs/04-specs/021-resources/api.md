# SPEC-021 — Resources — API

**Status:** Draft — logical operations and payload allowlists defined; OpenAPI materialization and implementation alignment pending

## Resource lógico

`/api/v1/projects/{projectId}/resource-allocations` — convenção base de `docs/08-api`. Scope: `Tenant/Project/Resource scope`.

## Operações e schemas

| Operação | Rota | Request allowlist | Resultado |
|---|---|---|---|
| Capacity | `GET /api/v1/projects/{projectId}/resource-allocations/capacity` | `from,to,role?,skill?` | Capacidade disponível/agregada; sem PII/custo sem grant |
| Allocate | `POST /api/v1/projects/{projectId}/resource-allocations` | `resourceId,role,capacityPercent,startDate,endDate?,reason?`, `Idempotency-Key` | `201` allocation; conflito > capacity retorna 409 salvo override autorizado |
| Update | `PATCH /api/v1/resource-allocations/{id}` | `role?,capacityPercent?,startDate?,endDate?`, `If-Match` | `200` allocation versionada |
| Resolve conflict | `POST /api/v1/resource-allocations/{id}/resolve-conflict` | `resolution,reason` (obrigatório), `If-Match` | `200`; override exige grant e audit |
| Deallocate | `POST /api/v1/resource-allocations/{id}/deallocate` | `effectiveAt,reason`, `If-Match`, `Idempotency-Key` | `200` encerra alocação sem apagar histórico |

Responses ocultam campos pessoais/financeiros sem data policy. Query aceita cursor, range, role, skill e status allowlisted. Grants `resources.view|edit` e override separado.

## Contrato comum

JSON; IDs UUID; datas ISO-8601/UTC; paginação por cursor em listas grandes; filtros/sorts allowlisted; `expected_version` em update concorrente; idempotency key em comandos com retry. Cada operação revalida grants server-side.

## Erros

Logical request/response fields and domain constraints are listed above; a compilable OpenAPI contract and implementation alignment remain release gates.

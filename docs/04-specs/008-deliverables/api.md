# SPEC-008 — Deliverables — API

**Status:** Draft — logical operations and payload allowlists defined; OpenAPI materialization and implementation alignment pending

## Resource lógico

`/api/v1/deliverables` — convenção base de `docs/08-api`. Scope: `Project`.

## Operações e schemas

| Operação | Rota | Request allowlist | Resultado |
|---|---|---|---|
| Create | `POST /api/v1/projects/{projectId}/deliverables` | `name,milestoneId?,ownerId?,baselineDate?,acceptanceRequired` | `201` planned, acceptanceStatus `pending` ou `not_required` |
| Update | `PATCH /api/v1/deliverables/{id}` | `name?,milestoneId?,ownerId?,baselineDate?`, `If-Match` | `200`; delivery/acceptance state só por comando |
| Deliver | `POST /api/v1/deliverables/{id}/delivery` | `deliveredAt,evidenceIds[]`, `If-Match`, `Idempotency-Key` | `200` status delivered; evidence links persistidos |
| Accept | `POST /api/v1/deliverables/{id}/acceptance` | `decision=accepted,reason?,evidenceIds[]?`, `If-Match`, `Idempotency-Key` | `200` acceptanceStatus accepted + acceptedAt |
| Reject acceptance | `POST /api/v1/deliverables/{id}/acceptance` | `decision=rejected,reason` (obrigatório), `If-Match`, `Idempotency-Key` | `200` acceptanceStatus rejected; entrega/evidência preservadas |

Response inclui `status,acceptanceStatus,deliveredAt,acceptedAt,evidence[],version`. `GET` aceita `cursor,limit,status,acceptanceStatus,milestoneId,ownerId`. Grants `deliverables.view|create|edit|deliver|accept|reject`.

## Contrato comum

JSON; IDs UUID; datas ISO-8601/UTC; paginação por cursor em listas grandes; filtros/sorts allowlisted; `expected_version` em update concorrente; idempotency key em comandos com retry. Cada operação revalida grants server-side.

## Erros

Logical request/response fields and domain constraints are listed above; a compilable OpenAPI contract and implementation alignment remain release gates.

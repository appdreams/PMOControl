# SPEC-012 — Decisions — API

**Status:** Draft — logical operations and payload allowlists defined; OpenAPI materialization and implementation alignment pending

## Resource lógico

`/api/v1/decisions` — convenção base de `docs/08-api`. Scope: `Project/Decision`.

## Operações e schemas

| Operação | Rota | Request allowlist | Resultado |
|---|---|---|---|
| Request | `POST /api/v1/projects/{projectId}/decisions` | `subject,context,options[]:{label,description?},decisionMakerId?,dueDate,impact,evidenceIds[]?` | `201` pending; requester derivado da sessão |
| Approve | `POST /api/v1/decisions/{id}/approve` | `outcome,reason,evidenceIds[]?`, `If-Match`, `Idempotency-Key` | `200` approved + decision maker/date |
| Reject | `POST /api/v1/decisions/{id}/reject` | `reason,outcome?`, `If-Match`, `Idempotency-Key` | `200` rejected + histórico |
| Defer | `POST /api/v1/decisions/{id}/defer` | `reason,newDueDate`, `If-Match`, `Idempotency-Key` | `200` deferred; decisão permanece aberta para decisão posterior |
| Comment | `POST /api/v1/decisions/{id}/comments` | `body` (1–4000), `evidenceIds[]?`, `Idempotency-Key` | `201` comentário append-only |

`GET /api/v1/decisions` aceita cursor, Project, status, decisionMakerId, requestedBy e due range. Approve/reject/defer exigem grants `decision.approve|reject|defer`, `expected_version` e histórico append-only. Comment exige `decision.comment` e grava em `decision_comments` append-only.

## Contrato comum

JSON; IDs UUID; datas ISO-8601/UTC; paginação por cursor em listas grandes; filtros/sorts allowlisted; `expected_version` em update concorrente; idempotency key em comandos com retry. Cada operação revalida grants server-side.

## Erros

Logical request/response fields and domain constraints are listed above; a compilable OpenAPI contract and implementation alignment remain release gates.

# SPEC-009 — Risks — API

**Status:** Draft — logical operations and payload allowlists defined; OpenAPI materialization and implementation alignment pending

## Resource lógico

`/api/v1/risks` — convenção base de `docs/08-api`. Scope: `Project`.

## Operações e schemas

| Operação | Rota | Request allowlist | Resultado |
|---|---|---|---|
| Create | `POST /api/v1/projects/{projectId}/risks` | `title,description,cause,consequence,category,ownerId?,dueDate?` | `201` identified + versão 1 |
| Assess | `POST /api/v1/risks/{id}/assessments` | `probability,impact,assessedAt?`, `If-Match`, `Idempotency-Key` | `201` avaliação imutável; score = probability × impact (escala 1–5) |
| Response | `PUT /api/v1/risks/{id}/response` | `mitigation,contingency?,ownerId,dueDate,status`, `If-Match` | `200` risk response versionada |
| Materialize | `POST /api/v1/risks/{id}/materialize` | `issue:{description,rootCause,impact,priority,ownerId?,dueDate?}`, `If-Match`, `Idempotency-Key` | `201` Issue vinculada; Risk passa a materialized sem apagar assessments |
| Close | `POST /api/v1/risks/{id}/close` | `reason`, `If-Match`, `Idempotency-Key` | `200` closed; avaliação e resposta preservadas |

`GET /api/v1/risks` aceita cursor, Project, status, owner, category e due range allowlisted. Response inclui assessment atual e histórico paginado. Permissions adicionais: `risks.assess`, `risks.respond`, `risks.materialize`, `risks.close`.

## Contrato comum

JSON; IDs UUID; datas ISO-8601/UTC; paginação por cursor em listas grandes; filtros/sorts allowlisted; `expected_version` em update concorrente; idempotency key em comandos com retry. Cada operação revalida grants server-side.

## Erros

Logical request/response fields and domain constraints are listed above; a compilable OpenAPI contract and implementation alignment remain release gates.

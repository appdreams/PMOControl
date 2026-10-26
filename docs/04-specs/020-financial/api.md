# SPEC-020 — Financial — API

**Status:** Draft — logical operations and payload allowlists defined; OpenAPI materialization and implementation alignment pending

## Resource lógico

`/api/v1/projects/{projectId}/financials` — convenção base de `docs/08-api`. Scope: `Project + Financial permission`.

## Operações e schemas

| Operação | Rota | Request allowlist | Resultado |
|---|---|---|---|
| Read | `GET /api/v1/projects/{projectId}/financials` | `period?`; `financial.view` obrigatório | Campos permitidos, moeda ISO-4217 e N/A com motivo quando denominador ausente |
| Commitment | `POST /api/v1/projects/{projectId}/financials/commitments` | `amount,currency,reference,committedAt?`, `Idempotency-Key` | `201` commitment versionado |
| Actual | `POST /api/v1/projects/{projectId}/financials/actuals` | `amount,currency,period,reference`, `Idempotency-Key` | `201` actual persistido com audit |
| Forecast | `PUT /api/v1/projects/{projectId}/financials/forecast` | `forecastAtCompletion,currency,asOf,reason`, `If-Match` | `200` forecast atualizado; approved budget não muda |
| Baseline change | `POST /api/v1/projects/{projectId}/financials/budget-change-requests` | `proposedBudget,currency,reason`, `Idempotency-Key` | `202` solicitação; orçamento aprovado muda só após aprovação autorizada |

Valores monetários são strings decimais na API, nunca float; currency deve coincidir com a moeda do Project. Listas são period-filtered e grants `financial.view|edit|export` são independentes.

## Contrato comum

JSON; IDs UUID; datas ISO-8601/UTC; paginação por cursor em listas grandes; filtros/sorts allowlisted; `expected_version` em update concorrente; idempotency key em comandos com retry. Cada operação revalida grants server-side.

## Erros

Logical request/response fields and domain constraints are listed above; a compilable OpenAPI contract and implementation alignment remain release gates.

# SPEC-015 — RAG Engine — API

**Status:** Draft — comandos e payload de `rag-v1` definidos; revisão OpenAPI pendente

## Resource lógico

`/api/v1/projects/{projectId}/rag-evaluations` — convenção base de `docs/08-api`. Scope: `Project`.

## Operações

- `evaluateRag`: valida sessão, Tenant/scope, permission, payload e regras de RagEvaluation.
- `getRagHistory`: valida sessão, Tenant/scope, permission, payload e regras de RagEvaluation.
- `overrideRag`: valida sessão, Tenant/scope, permission, payload e regras de RagEvaluation.
- `revokeOverride`: valida sessão, Tenant/scope, permission, payload e regras de RagEvaluation.

`evaluateRag` input: `{as_of, rule_set_version?}`; fontes de cálculo são carregadas pelo servidor, não aceitas do cliente. Response inclui `{evaluation_id, evaluation_status, calculated_rag, effective_rag, rule_set_version, as_of, indicators[], inputs_hash}`. `overrideRag` input: `{new_effective_rag, reason, expires_at?}` com reason >= 10 chars. `revokeOverride` exige override ativo e registra actor/time.

## Contrato comum

JSON; IDs UUID; datas ISO-8601/UTC; paginação por cursor em listas grandes; filtros/sorts allowlisted; `expected_version` em update concorrente; idempotency key em comandos com retry. Cada operação revalida grants server-side.

## Erros

Logical request/response fields and domain constraints are listed above; a compilable OpenAPI contract and implementation alignment remain release gates.

# SPEC-025 — PMO Copilot — API

**Status:** Draft — logical operations and payload allowlists defined; OpenAPI materialization and implementation alignment pending

## Resource lógico

`/api/v1/copilot` — convenção base de `docs/08-api`. Scope: `Actor + authorized sources`.

## Operações e schemas

| Operação | Rota | Request allowlist | Resultado |
|---|---|---|---|
| Ask | `POST /api/v1/copilot/requests` | `question,requestedScope?,conversationId?`; scope rederivado/limitado pelo server | `202` request ID; output classificado Fact/Inference/Recommendation + citations |
| Sources | `GET /api/v1/copilot/requests/{id}/sources` | cursor,limit | Fontes autorizadas com IDs, versão/as-of e trechos minimizados |
| Propose | `POST /api/v1/copilot/requests/{id}/proposals` | `actionType,resourceRef,payload` | Proposal pendente com payload hash, expiração e resumo mostrado ao usuário |
| Confirm | `POST /api/v1/copilot/proposals/{id}/confirm` | `payloadHash,confirmation=true`, `Idempotency-Key` | Reautorização + validação de domínio + audit antes do comando; retorna resultado ou conflict |
| Read AI config | `GET /api/v1/tenants/{tenantId}/ai/config` | none | Provider/model mappings/status/version; secret value omitted, only masked presence/status |
| Save AI config | `PUT /api/v1/tenants/{tenantId}/ai/config/{provider}` | `credential,models.low,models.medium,models.high,endpointId?,expectedVersion`; `provider` allowlist: `openai|google_gemini|anthropic_claude|meta_llama|deepseek|openrouter`; credential accepted only on write and stored in secret manager | Validates provider credential, approved endpoint when needed and model availability; returns redacted config/version; never echoes credential. Endpoint ID must resolve through platform adapter registry; arbitrary URLs are rejected |
| Validate config | `POST /api/v1/tenants/{tenantId}/ai/config/{provider}/validate` | `expectedVersion`; uses stored secret | provider/model capability status and audit correlation; no secret/ref returned |
| Rotate config credential | `POST /api/v1/tenants/{tenantId}/ai/config/{provider}/credential` | write-only `credential,expectedVersion,reason` | rotated version/status and audit correlation; old secret revoked, no credential/ref returned |
| Disable config | `POST /api/v1/tenants/{tenantId}/ai/config/{provider}/disable` | `reason,expectedVersion` | disabled status/version; new calls denied, in-flight request retains resolved version |
| AI usage/costs | `GET /api/v1/tenants/{tenantId}/ai/usage` | `from,to,groupBy=day|provider|model|useCase|complexity,status?,cursor?,limit?` | Tenant-scoped usage/tokens and provider-reported vs rate-estimated costs with measurement status and currency |
| Export AI costs | `POST /api/v1/tenants/{tenantId}/ai/usage/exports` | `from,to,format=csv|json,groupBy[]` | async export job; field/scope policy and expiry rechecked at download |

Every `askCopilot` response/usage record includes `complexity`, `routerRuleVersion`, selected model and a non-sensitive reason code. The server classifies automatically; client input cannot select complexity or provider credentials used for another Tenant. Cost aggregates distinguish provider-reported usage charges from local estimates and never claim to be the provider invoice.

Responses nunca persistem prompt/grounding cru por padrão; citações não ultrapassam contexto autorizado. Proposal expirada ou com hash alterado não pode ser confirmada.

## Contrato comum

JSON; IDs UUID; datas ISO-8601/UTC; paginação por cursor em listas grandes; filtros/sorts allowlisted; `expected_version` em update concorrente; idempotency key em comandos com retry. Cada operação revalida grants server-side.

## Erros

Logical request/response fields and domain constraints are listed above; a compilable OpenAPI contract and implementation alignment remain release gates.

# SPEC-029 — Settings — API

**Status:** Draft — logical operations and payload allowlists defined; OpenAPI materialization and implementation alignment pending

## Resource lógico

`/api/v1/tenants/{tenantId}/settings` — convenção base de `docs/08-api`. Scope: `Tenant + settings permission`.

## Operações e schemas

| Operação | Rota | Request allowlist | Resultado |
|---|---|---|---|
| Read | `GET /api/v1/tenants/{tenantId}/settings` | `keys[]?`; actor precisa membership/admin grant no Tenant | Values conforme data policy; secret values redacted |
| Update | `PUT /api/v1/tenants/{tenantId}/settings/{key}` | `valueSchemaVersion,value,reason`, `If-Match`, `Idempotency-Key` | `200` versão incrementada; schema validado no servidor |
| Reset | `POST /api/v1/tenants/{tenantId}/settings/{key}/reset` | `reason`, `If-Match`, `Idempotency-Key` | `200` retorna default versionado e audit |
| Rotate secret ref | `POST /api/v1/tenants/{tenantId}/settings/{key}/rotate-secret-reference` | `providerSecretRef,reason`, `If-Match` | `200` somente referência; valor secreto nunca transita/retorna |

Tenant ID da rota é validado contra membership/grant e nunca define contexto sozinho. Mudanças de chaves sensíveis exigem `tenant.settings.edit` e audit sem value/secret.

## Contrato comum

JSON; IDs UUID; datas ISO-8601/UTC; paginação por cursor em listas grandes; filtros/sorts allowlisted; `expected_version` em update concorrente; idempotency key em comandos com retry. Cada operação revalida grants server-side.

## Erros

Logical request/response fields and domain constraints are listed above; a compilable OpenAPI contract and implementation alignment remain release gates.

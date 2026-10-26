# SPEC-026 — Notifications — API

**Status:** Draft — logical operations and payload allowlists defined; OpenAPI materialization and implementation alignment pending

## Resource lógico

`/api/v1/notifications` — convenção base de `docs/08-api`. Scope: `Recipient/Tenant`.

## Operações e schemas

| Operação | Rota | Request allowlist | Resultado |
|---|---|---|---|
| Inbox | `GET /api/v1/notifications` | `cursor,limit,read,createdAfter?` | Somente notifications do recipient autenticado |
| Mark read | `POST /api/v1/notifications/{id}/read` | `read=true`, `Idempotency-Key` | `200`; só o recipient pode alterar read state |
| Preferences | `GET/PUT /api/v1/notification-preferences` | `channels:{inApp,email},eventTypes[]`; chaves allowlisted | Preferências do ator atual, versionadas |
| Enqueue | Interno via committed event/outbox | Não há endpoint público | Worker cria delivery idempotente por canal |
| Retry | Operação interna restrita | `deliveryId,reason` via worker/admin grant | Retry bounded; não repete comando fonte |

Response minimiza payload e aponta para recurso somente após checagem de acesso. O ator não escolhe recipient de enqueue.

## Contrato comum

JSON; IDs UUID; datas ISO-8601/UTC; paginação por cursor em listas grandes; filtros/sorts allowlisted; `expected_version` em update concorrente; idempotency key em comandos com retry. Cada operação revalida grants server-side.

## Erros

Logical request/response fields and domain constraints are listed above; a compilable OpenAPI contract and implementation alignment remain release gates.

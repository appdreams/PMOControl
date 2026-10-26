# SPEC-022 — Documents — API

**Status:** Draft — logical operations and payload allowlists defined; OpenAPI materialization and implementation alignment pending

## Resource lógico

`/api/v1/projects/{projectId}/documents` — convenção base de `docs/08-api`. Scope: `Project + Document classification`.

## Operações e schemas

| Operação | Rota | Request allowlist | Resultado |
|---|---|---|---|
| Upload | `POST /api/v1/projects/{projectId}/documents` | `filename,mimeType,sizeBytes,classification`; retorna URL temporária de upload | `201` metadata pending; storage key gerada pelo servidor |
| Metadata | `GET /api/v1/documents/{id}` | sem body | Metadados autorizados e versão atual |
| Download | `POST /api/v1/documents/{id}/download-url` | `versionId?` | URL assinada curta após revalidar grants/classificação |
| New version | `POST /api/v1/documents/{id}/versions` | `filename,mimeType,sizeBytes`; upload URL temporária | `201` versão imutável com checksum server-side |
| Link evidence | `POST /api/v1/documents/{id}/evidence-links` | `resourceType,resourceId,relationship` | `201` link same-Tenant; resource authorized |
| Archive | `POST /api/v1/documents/{id}/archive` | `reason`, `If-Match`, `Idempotency-Key` | `200` archived; binário segue retenção |

Listagem aceita cursor, classification, mimeType e resource filter allowlisted. Nunca aceita storage key escolhida pelo cliente nem retorna bucket path. Content type é validado pelo servidor.

## Contrato comum

JSON; IDs UUID; datas ISO-8601/UTC; paginação por cursor em listas grandes; filtros/sorts allowlisted; `expected_version` em update concorrente; idempotency key em comandos com retry. Cada operação revalida grants server-side.

## Erros

Logical request/response fields and domain constraints are listed above; a compilable OpenAPI contract and implementation alignment remain release gates.

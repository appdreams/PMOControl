# SPEC-024 — Report Builder — API

**Status:** Draft — logical operations and payload allowlists defined; OpenAPI materialization and implementation alignment pending

## Resource lógico

`/api/v1/reports` — convenção base de `docs/08-api`. Scope: `User + authorized Tenant/Projects`.

## Operações e schemas

| Operação | Rota | Request allowlist | Resultado |
|---|---|---|---|
| Templates | `GET /api/v1/reports/templates` | `cursor,limit,category?` | Somente templates visíveis ao scope |
| Preview | `POST /api/v1/reports/preview` | `templateId,filters,temporalMode,asOf?,outputFormat` | `200` preview sem artefato, autorização aplicada por linha/campo |
| Create job | `POST /api/v1/reports` | `templateId,filters,temporalMode,asOf?,outputFormat`, `Idempotency-Key` | `202` `{jobId,status,expiresAt}` |
| Get job | `GET /api/v1/reports/{jobId}` | sem body | Estado, progresso, erro estável e checksum quando pronto |
| Download | `POST /api/v1/reports/{jobId}/download-url` | sem body | URL assinada curta após revalidação de permissão e expiry |

Outputs aceitos `csv|xlsx|pdf`; temporal mode `current|published`. Filter/fields são allowlisted por template; resposta nunca confirma registros fora do scope.

## Contrato comum

JSON; IDs UUID; datas ISO-8601/UTC; paginação por cursor em listas grandes; filtros/sorts allowlisted; `expected_version` em update concorrente; idempotency key em comandos com retry. Cada operação revalida grants server-side.

## Erros

Logical request/response fields and domain constraints are listed above; a compilable OpenAPI contract and implementation alignment remain release gates.

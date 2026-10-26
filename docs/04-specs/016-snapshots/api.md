# SPEC-016 — Snapshots — API

**Status:** Draft — queries e payload snapshot-v1 definidos; revisão OpenAPI pendente

## Resource lógico

`/api/v1/projects/{projectId}/snapshots` — convenção base de `docs/08-api`. Scope: `Project/Snapshot`.

## Operações

- `getSnapshot`: valida sessão, Tenant/scope, permission, payload e regras de Snapshot.
- `listSnapshots`: valida sessão, Tenant/scope, permission, payload e regras de Snapshot.
- `compareSnapshots`: compara dois snapshots autorizados sem reconstruir tabelas atuais.
- `verifySnapshotHash`: valida sessão, Tenant/scope, permission, payload e regras de Snapshot.

`createSnapshot` é uma operação interna, atômica com `status.update.publish`/`status.update.correct` (Spec 014); não expor endpoint que permita publicar payload arbitrário.

## Contrato comum

JSON; IDs UUID; datas ISO-8601/UTC; paginação por cursor em listas grandes; filtros/sorts allowlisted; `expected_version` em update concorrente; idempotency key em comandos com retry. Cada operação revalida grants server-side.

## Erros

Logical request/response fields and domain constraints are listed above; a compilable OpenAPI contract and implementation alignment remain release gates.

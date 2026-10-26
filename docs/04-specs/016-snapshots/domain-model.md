# SPEC-016 — Snapshots — Domain Model

**Status:** Draft — entidades e ownership definidos em nível lógico

## Entidade principal

`Snapshot`

Campos de domínio e payload exatos: `docs/04-specs/016-snapshots/database.md`. O snapshot é criado apenas por `status.update.publish` ou `status.update.correct` dentro da transação Spec 014; não existe criação ad hoc por cliente.

## Ownership e relações

Tenant-owned; scope primário: `Project/Snapshot`. Recursos relacionados devem compartilhar `tenant_id`; Project/Portfolio/Actor IDs são referências, nunca prova de autorização.

## Invariantes

1. Snapshot publicado é imutável; criação ocorre junto à publicação autoritativa e payload versionado.
2. Ownership e assignment não substituem permission.
3. Current operational state é distinto de published/historical state quando módulo consome snapshot.
4. Fechamento/arquivamento preserva referência de origem e trilha de auditoria.

## Lifecycle

Operações: getSnapshot, listSnapshots, compareSnapshots, verifySnapshotHash. Snapshot não possui transição de estado nem update/delete ordinário. Correção cria novo par Publication/Snapshot sucessor.

# SPEC-016 — Snapshots — Permissions

**Status:** Draft — permission keys propostas; role grants finais na Spec 003

## Permissions

- `projects.{projectId}.snapshots.view`: consulta no scope `Project/Snapshot`.
- `projects.{projectId}.snapshots.verify`: recalcula hash e registra divergência de integridade.
- `projects.{projectId}.snapshots.export`: exporta somente campos permitidos por data policy, quando aplicável.

Snapshot é criado somente pelo comando autorizado `status.update.publish`/`status.update.correct` da Spec 014, dentro da mesma transação; não há grant de criação ou edição independente. `getSnapshot`, `listSnapshots`, `compareSnapshots` exigem `view`; `verifySnapshotHash` exige `verify`. Toda permission é server-side, tenant/scope-bound e deny-by-default. Project membership não implica acesso Finance/Resources/Confidential. Permission keys finais devem ser reconciliadas com `docs/00-foundation/permission-model.md` e Spec 003.

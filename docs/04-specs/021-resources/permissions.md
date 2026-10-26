# SPEC-021 — Resources — Permissions

**Status:** Draft — permission keys propostas; role grants finais na Spec 003

## Permissions

- `projects.{projectId}.resource-allocations.view`: consulta no scope `Tenant/Project/Resource scope`.
- `projects.{projectId}.resource-allocations.create`: cria/deriva quando a entidade é gravável.
- `projects.{projectId}.resource-allocations.edit`: altera campos mutáveis em estado permitido.
- `projects.{projectId}.resource-allocations.archive`: arquiva/fecha sem hard delete.
- `projects.{projectId}.resource-allocations.export`: exporta somente campos permitidos por data policy, quando aplicável.

Comandos específicos: listCapacity, allocateResource, updateAllocation, resolveConflict, deallocateResource; aprovações/overrides/outcomes exigem grants próprios definidos pelo domínio. Toda permission é server-side, tenant/scope-bound e deny-by-default. Project membership não implica acesso Finance/Resources/Confidential. Permission keys finais devem ser reconciliadas com `docs/00-foundation/permission-model.md` e Spec 003.

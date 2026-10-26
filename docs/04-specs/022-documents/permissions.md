# SPEC-022 — Documents — Permissions

**Status:** Draft — permission keys propostas; role grants finais na Spec 003

## Permissions

- `projects.{projectId}.documents.view`: consulta no scope `Project + Document classification`.
- `projects.{projectId}.documents.create`: cria/deriva quando a entidade é gravável.
- `projects.{projectId}.documents.edit`: altera campos mutáveis em estado permitido.
- `projects.{projectId}.documents.archive`: arquiva/fecha sem hard delete.
- `projects.{projectId}.documents.export`: exporta somente campos permitidos por data policy, quando aplicável.

Comandos específicos: uploadDocument, getMetadata, downloadDocument, createVersion, linkEvidence, archiveDocument; aprovações/overrides/outcomes exigem grants próprios definidos pelo domínio. Toda permission é server-side, tenant/scope-bound e deny-by-default. Project membership não implica acesso Finance/Resources/Confidential. Permission keys finais devem ser reconciliadas com `docs/00-foundation/permission-model.md` e Spec 003.

# SPEC-024 — Report Builder — Permissions

**Status:** Draft — permission keys propostas; role grants finais na Spec 003

## Permissions

- `reports.view`: consulta no scope `User + authorized Tenant/Projects`.
- `reports.create`: cria/deriva quando a entidade é gravável.
- `reports.edit`: altera campos mutáveis em estado permitido.
- `reports.archive`: arquiva/fecha sem hard delete.
- `reports.export`: exporta somente campos permitidos por data policy, quando aplicável.

Comandos específicos: listTemplates, previewReport, createReportJob, getReportJob, downloadReport; aprovações/overrides/outcomes exigem grants próprios definidos pelo domínio. Toda permission é server-side, tenant/scope-bound e deny-by-default. Project membership não implica acesso Finance/Resources/Confidential. Permission keys finais devem ser reconciliadas com `docs/00-foundation/permission-model.md` e Spec 003.

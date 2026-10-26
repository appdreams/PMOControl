# SPEC-020 — Financial — Permissions

**Status:** Draft — permission keys propostas; role grants finais na Spec 003

## Permissions

- `projects.{projectId}.financials.view`: consulta no scope `Project + Financial permission`.
- `projects.{projectId}.financials.create`: cria/deriva quando a entidade é gravável.
- `projects.{projectId}.financials.edit`: altera campos mutáveis em estado permitido.
- `projects.{projectId}.financials.archive`: arquiva/fecha sem hard delete.
- `projects.{projectId}.financials.export`: exporta somente campos permitidos por data policy, quando aplicável.

Comandos específicos: readFinancials, recordCommitment, recordActual, updateForecast, requestBudgetBaselineChange; aprovações/overrides/outcomes exigem grants próprios definidos pelo domínio. Toda permission é server-side, tenant/scope-bound e deny-by-default. Project membership não implica acesso Finance/Resources/Confidential. Permission keys finais devem ser reconciliadas com `docs/00-foundation/permission-model.md` e Spec 003.

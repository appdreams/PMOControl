# SPEC-007 — Milestones — Permissions

**Status:** Draft — permission keys propostas; role grants finais na Spec 003

## Permissions

- `milestones.view`: consulta no scope `Project`.
- `milestones.create`: cria/deriva quando a entidade é gravável.
- `milestones.edit`: altera campos mutáveis em estado permitido.
- `milestones.archive`: arquiva/fecha sem hard delete.
- `milestones.export`: exporta somente campos permitidos por data policy, quando aplicável.
- `milestone.forecast`, `milestone.complete` e `baseline.change` são grants separados; baseline change requer aprovação governada e não pode ser executada por PATCH.

Comandos específicos: createMilestone, updateMilestone, changeForecast, completeMilestone, requestBaselineChange; aprovações/overrides/outcomes exigem grants próprios definidos pelo domínio. Toda permission é server-side, tenant/scope-bound e deny-by-default. Project membership não implica acesso Finance/Resources/Confidential. Permission keys finais devem ser reconciliadas com `docs/00-foundation/permission-model.md` e Spec 003.

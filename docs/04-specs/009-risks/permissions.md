# SPEC-009 — Risks — Permissions

**Status:** Draft — permission keys propostas; role grants finais na Spec 003

## Permissions

- `risks.view`: consulta no scope `Project`.
- `risks.create`: cria/deriva quando a entidade é gravável.
- `risks.edit`: altera campos mutáveis em estado permitido.
- `risks.archive`: arquiva/fecha sem hard delete.
- `risks.export`: exporta somente campos permitidos por data policy, quando aplicável.
- `risk.assess`, `risk.respond`, `risk.materialize` e `risk.close` são grants de comando separados; materializar exige também `issues.create` no mesmo Project.

Comandos específicos: createRisk, assessRisk, updateResponse, materializeRisk, closeRisk; aprovações/overrides/outcomes exigem grants próprios definidos pelo domínio. Toda permission é server-side, tenant/scope-bound e deny-by-default. Project membership não implica acesso Finance/Resources/Confidential. Permission keys finais devem ser reconciliadas com `docs/00-foundation/permission-model.md` e Spec 003.

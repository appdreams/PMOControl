# SPEC-012 — Decisions — Permissions

**Status:** Draft — permission keys propostas; role grants finais na Spec 003

## Permissions

- `decisions.view`: consulta no scope `Project/Decision`.
- `decisions.create`: cria/deriva quando a entidade é gravável.
- `decisions.edit`: altera campos mutáveis em estado permitido.
- `decisions.archive`: arquiva/fecha sem hard delete.
- `decisions.export`: exporta somente campos permitidos por data policy, quando aplicável.
- `decision.approve`, `decision.reject`, `decision.defer` e `decision.comment` são grants separados; decisão só pode ser tomada pelo decisor atribuído ou por delegado explícito.

Comandos específicos: createDecisionRequest, approveDecision, rejectDecision, deferDecision, commentDecision; aprovações/overrides/outcomes exigem grants próprios definidos pelo domínio. Toda permission é server-side, tenant/scope-bound e deny-by-default. Project membership não implica acesso Finance/Resources/Confidential. Permission keys finais devem ser reconciliadas com `docs/00-foundation/permission-model.md` e Spec 003.

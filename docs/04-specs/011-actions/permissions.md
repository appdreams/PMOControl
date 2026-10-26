# SPEC-011 — Actions — Permissions

**Status:** Draft — permission keys propostas; role grants finais na Spec 003

## Permissions

- `actions.view`: consulta no scope `Project`.
- `actions.create`: cria/deriva quando a entidade é gravável.
- `actions.edit`: altera campos mutáveis em estado permitido.
- `actions.archive`: arquiva/fecha sem hard delete.
- `actions.export`: exporta somente campos permitidos por data policy, quando aplicável.
- `action.reassign`, `action.complete` e `action.cancel` são grants separados; completion exige evidência/outcome conforme política e nunca altera source.

Comandos específicos: createAction, updateAction, reassignAction, completeAction, cancelAction; aprovações/overrides/outcomes exigem grants próprios definidos pelo domínio. Toda permission é server-side, tenant/scope-bound e deny-by-default. Project membership não implica acesso Finance/Resources/Confidential. Permission keys finais devem ser reconciliadas com `docs/00-foundation/permission-model.md` e Spec 003.

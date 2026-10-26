# SPEC-026 — Notifications — Permissions

**Status:** Draft — permission keys propostas; role grants finais na Spec 003

## Permissions

- `notifications.view`: consulta no scope `Recipient/Tenant`.
- `notifications.create`: cria/deriva quando a entidade é gravável.
- `notifications.edit`: altera campos mutáveis em estado permitido.
- `notifications.archive`: arquiva/fecha sem hard delete.
- `notifications.export`: exporta somente campos permitidos por data policy, quando aplicável.

Comandos específicos: listInbox, markRead, updatePreferences, enqueueDelivery, retryDelivery; aprovações/overrides/outcomes exigem grants próprios definidos pelo domínio. Toda permission é server-side, tenant/scope-bound e deny-by-default. Project membership não implica acesso Finance/Resources/Confidential. Permission keys finais devem ser reconciliadas com `docs/00-foundation/permission-model.md` e Spec 003.

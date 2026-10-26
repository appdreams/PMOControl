# SPEC-029 — Settings — Permissions

**Status:** Draft — permission keys propostas; role grants finais na Spec 003

## Permissions

- `tenants.{tenantId}.settings.view`: consulta no scope `Tenant + settings permission`.
- `tenants.{tenantId}.settings.create`: cria/deriva quando a entidade é gravável.
- `tenants.{tenantId}.settings.edit`: altera campos mutáveis em estado permitido.
- `tenants.{tenantId}.settings.archive`: arquiva/fecha sem hard delete.
- `tenants.{tenantId}.settings.export`: exporta somente campos permitidos por data policy, quando aplicável.

Comandos específicos: getSettings, updateSetting, resetSetting, rotateSecretReference; aprovações/overrides/outcomes exigem grants próprios definidos pelo domínio. Toda permission é server-side, tenant/scope-bound e deny-by-default. Project membership não implica acesso Finance/Resources/Confidential. Permission keys finais devem ser reconciliadas com `docs/00-foundation/permission-model.md` e Spec 003.

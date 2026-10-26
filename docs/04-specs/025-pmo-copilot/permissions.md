# SPEC-025 — PMO Copilot — Permissions

**Status:** Draft — permission keys propostas; role grants finais na Spec 003

## Permissions

- `copilot.view`: consulta no scope `Actor + authorized sources`.
- `copilot.create`: cria/deriva quando a entidade é gravável.
- `copilot.edit`: altera campos mutáveis em estado permitido.
- `copilot.archive`: arquiva/fecha sem hard delete.
- `copilot.export`: exporta somente campos permitidos por data policy, quando aplicável.
- `ai.config.view`: lê estado não secreto da configuração BYOK do próprio Tenant.
- `ai.config.manage`: cria/valida/atualiza/desabilita/rotaciona provider e mapeamentos de modelos no Tenant; somente Tenant Admin ou delegado explicitamente autorizado.
- `ai.cost.view`: consulta agregados e detalhes de uso/custo do próprio Tenant.
- `ai.cost.export`: exporta ledger/agregados financeiros de IA do próprio Tenant.

Comandos específicos: askCopilot, getSources, proposeAction, confirmAction; aprovações/overrides/outcomes exigem grants próprios definidos pelo domínio. Toda permission é server-side, tenant/scope-bound e deny-by-default. Project membership não implica acesso Finance/Resources/Confidential. Permission keys finais devem ser reconciliadas com `docs/00-foundation/permission-model.md` e Spec 003.

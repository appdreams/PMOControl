# SPEC-004 — Portfolios — Permissions

**Status:** Draft — permission keys propostas; role grants finais na Spec 003

## Permissions

- `portfolios.view`: consulta no scope `Tenant; Portfolio`.
- `portfolios.create`: cria/deriva quando a entidade é gravável.
- `portfolios.edit`: altera campos mutáveis em estado permitido.
- `portfolios.archive`: arquiva/fecha sem hard delete.
- `portfolios.export`: exporta somente campos permitidos por data policy, quando aplicável.
- A associação e remoção de Project exigem `portfolio.projects.associate` e `portfolio.projects.remove`, além de validação same-Tenant; rotas podem expor aliases plurais normalizados pelo middleware.

Comandos específicos: createPortfolio, updatePortfolio, archivePortfolio, associateProject, removeProject; aprovações/overrides/outcomes exigem grants próprios definidos pelo domínio. Toda permission é server-side, tenant/scope-bound e deny-by-default. Project membership não implica acesso Finance/Resources/Confidential. Permission keys finais devem ser reconciliadas com `docs/00-foundation/permission-model.md` e Spec 003.

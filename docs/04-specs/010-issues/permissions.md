# SPEC-010 — Issues — Permissions

**Status:** Draft — permission keys propostas; role grants finais na Spec 003

## Permissions

- `issues.view`: consulta no scope `Project`.
- `issues.create`: cria/deriva quando a entidade é gravável.
- `issues.edit`: altera campos mutáveis em estado permitido.
- `issues.archive`: arquiva/fecha sem hard delete.
- `issues.export`: exporta somente campos permitidos por data policy, quando aplicável.
- `issue.assign`, `issue.resolve`, `issue.close` e `issue.link-risk` são grants separados; fechar exige estado resolved e link exige Risk no mesmo Project/Tenant.

Comandos específicos: createIssue, updateIssue, assignOwner, resolveIssue, closeIssue, linkRisk; aprovações/overrides/outcomes exigem grants próprios definidos pelo domínio. Toda permission é server-side, tenant/scope-bound e deny-by-default. Project membership não implica acesso Finance/Resources/Confidential. Permission keys finais devem ser reconciliadas com `docs/00-foundation/permission-model.md` e Spec 003.

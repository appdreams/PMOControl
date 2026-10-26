# SPEC-013 — Dependencies — Permissions

**Status:** Draft — permission keys propostas; role grants finais na Spec 003

## Permissions

- `dependencies.view`: consulta no scope `Project and linked resource`.
- `dependencies.create`: cria/deriva quando a entidade é gravável.
- `dependencies.edit`: altera campos mutáveis em estado permitido.
- `dependencies.archive`: arquiva/fecha sem hard delete.
- `dependencies.export`: exporta somente campos permitidos por data policy, quando aplicável.
- `dependency.resolve` e `dependency.view-impact` são grants separados; leitura do grafo só retorna endpoints que o ator pode visualizar.

Comandos específicos: createDependency, updateDependency, resolveDependency, listImpactedItems; aprovações/overrides/outcomes exigem grants próprios definidos pelo domínio. Toda permission é server-side, tenant/scope-bound e deny-by-default. Project membership não implica acesso Finance/Resources/Confidential. Permission keys finais devem ser reconciliadas com `docs/00-foundation/permission-model.md` e Spec 003.

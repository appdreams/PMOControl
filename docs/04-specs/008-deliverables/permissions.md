# SPEC-008 — Deliverables — Permissions

**Status:** Draft — permission keys propostas; role grants finais na Spec 003

## Permissions

- `deliverables.view`: consulta no scope `Project`.
- `deliverables.create`: cria/deriva quando a entidade é gravável.
- `deliverables.edit`: altera campos mutáveis em estado permitido.
- `deliverables.archive`: arquiva/fecha sem hard delete.
- `deliverables.export`: exporta somente campos permitidos por data policy, quando aplicável.
- `deliverable.deliver`, `deliverable.accept` e `deliverable.reject` são grants separados; o decisor do aceite deve ser autorizado e o resultado fica auditado.

Comandos específicos: createDeliverable, updateDeliverable, recordDelivery, acceptDeliverable, rejectAcceptance; aprovações/overrides/outcomes exigem grants próprios definidos pelo domínio. Toda permission é server-side, tenant/scope-bound e deny-by-default. Project membership não implica acesso Finance/Resources/Confidential. Permission keys finais devem ser reconciliadas com `docs/00-foundation/permission-model.md` e Spec 003.

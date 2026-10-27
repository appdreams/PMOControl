# SPEC-005 — Projects — Permissions

**Status:** Draft — permission keys propostas; role grants finais na Spec 003

## Permissions

- `projects.view`: consulta no scope `Tenant/Portfolio/Project`.
- `projects.create`: cria/deriva quando a entidade é gravável.
- `projects.edit`: altera campos mutáveis em estado permitido.
- `projects.archive`: arquiva/fecha sem hard delete.
- `projects.export`: exporta somente campos permitidos por data policy, quando aplicável.
- `project.assign` autoriza trocar o gerente ou atribuir membership/assignment no Project; a troca revalida membro ativo, mantém o grant `project_manager` sincronizado e exige motivo/versão/audit. `baseline.change` é grant sensível separado e requer workflow aprovado.

Comandos específicos: createProject, updateProject, changeBaseline, assignMember, archiveProject; aprovações/overrides/outcomes exigem grants próprios definidos pelo domínio. Toda permission é server-side, tenant/scope-bound e deny-by-default. Project membership não implica acesso Finance/Resources/Confidential. Permission keys finais devem ser reconciliadas com `docs/00-foundation/permission-model.md` e Spec 003.

- `platform.projects.purge`: concede ao Platform Root Admin o comando administrativo de purgar definitivamente um Project, sem direito de ler seu conteúdo operacional. Requer confirmação, motivo, preview fresco e audit; não pode ser delegado por Tenant/Portfolio/Project Admin.

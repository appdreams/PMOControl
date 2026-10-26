# SPEC-028 — Import & Export — Permissions

**Status:** Draft — permission keys propostas; role grants finais na Spec 003

## Permissions

- `data-jobs.view`: consulta no scope `Tenant + authorized entities/fields`.
- `data-jobs.create`: cria/deriva quando a entidade é gravável.
- `data-jobs.edit`: altera campos mutáveis em estado permitido.
- `data-jobs.archive`: arquiva/fecha sem hard delete.
- `data-jobs.export`: exporta somente campos permitidos por data policy, quando aplicável.
- `project.data.import`: lista projetos ativos do Tenant no escopo autorizado, baixa os templates e importa dados no projeto escolhido.
- `project.data.import.replace`: grant sensível separado para reiniciar/substituir dados operacionais v1; nunca concedido implicitamente por `data-jobs.create` ou `project.data.import`.

Comandos específicos: listImportableProjects, downloadProjectImportTemplate, createProjectImportJob, validateImport, previewImport, appendProjectData, replaceProjectData, createExportJob, downloadExport; replace exige grant específico, motivo, resumo de impacto e confirmação digitada. Toda permission é server-side, tenant/project-scope-bound e deny-by-default. Project membership não implica acesso Finance/Resources/Confidential. Permission keys finais devem ser reconciliadas com `docs/00-foundation/permission-model.md` e Spec 003.

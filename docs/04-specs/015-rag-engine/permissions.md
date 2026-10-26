# SPEC-015 — RAG Engine — Permissions

**Status:** Draft — permission keys propostas; role grants finais na Spec 003

## Permissions

- `projects.{projectId}.rag-evaluations.view`: consulta no scope `Project`.
- `projects.{projectId}.rag-evaluations.evaluate`: executar/repetir cálculo determinístico.
- `projects.{projectId}.rag-evaluations.override`: definir/revogar Effective RAG; grant separado e auditado.
- `projects.{projectId}.rag-rules.manage`: criar nova versão de thresholds, restrito a Tenant Admin/PMO Admin autorizado.
- `projects.{projectId}.rag-evaluations.export`: exporta somente campos permitidos por data policy, quando aplicável.

Comandos: `evaluateRag` usa `evaluate`; `overrideRag`/`revokeOverride` usam `override`; `getRagHistory` usa `view`. Read-only dashboards e projections nunca executam mutação. Toda permission é server-side, tenant/scope-bound e deny-by-default. Project membership não implica acesso Finance/Resources/Confidential. Permission keys finais devem ser reconciliadas com `docs/00-foundation/permission-model.md` e Spec 003.

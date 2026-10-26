# SPEC-003 — RBAC & Contextual Authorization — Permission Matrix

**Status:** Draft — recommended MVP defaults; customer role grants remain configurable only by platform policy

| Role | Default scope | Allowed capabilities | Explicitly excluded by default |
|---|---|---|---|
| Platform Admin | Platform | create/suspend/terminate tenant; quotas/platform health | tenant business content, financial, documents |
| Tenant Admin | Tenant | memberships/invitations, tenant settings, taxonomy/config | automatic project edit, financial, confidential export |
| PMO Admin | Assigned Tenant/Portfolio | portfolio/project governance, grants within delegation, reports; may receive sensitive grants | cross-tenant access, implicit financial access |
| PMO | Assigned Portfolio/Projects | operational read/write, follow-up, status preparation/publication when granted | platform lifecycle, implicit baseline/RAG override |
| Project Manager | Assigned Project | execution/governance, project docs; `status.update.publish` default grant at assigned Project | other Projects, financial edit, RAG override/baseline change unless granted |
| Contributor | Assigned item/Project subset | update assigned actions/deliverables, comments/evidence | publish, approve, financial, access administration |
| Executive | Assigned Portfolio/Project | authorized dashboards/read; decisions explicitly assigned | unassigned project, operational mutation, sensitive export absent grant |
| Viewer | Explicit scope | authorized read-only fields | all mutations/approval/publish; export absent separate grant |

## Permission families

- `ai.config.view|manage`, `ai.cost.view|export`: configuração BYOK/modelos e consumo do próprio Tenant; management apenas Tenant Admin ou delegado com teto explícito; custo não é concedido implicitamente por acesso ao Copilot.
- `project.data.import`: importar ao Project ativo e autorizado; `project.data.import.replace`: grant elevado separado para reinício, com motivo/audit/impacto/typed confirmation obrigatórios.

- `tenant.lifecycle.create|suspend|terminate`: platform team only.
- `membership.invite|revoke`: Tenant Admin/PMO Admin within Tenant and delegation ceiling.
- `portfolio.view|create|edit|archive`; `project.view|create|edit|archive|assign` within explicit scope.
- Module-specific `.view|create|edit|archive`; sensitive actions separately named.
- `portfolio.projects.associate|remove`, `project.assign`, `milestone.forecast|complete`, `deliverable.deliver|accept|reject`, `risk.assess|respond|materialize|close`, `issue.assign|resolve|close|link-risk`, `action.reassign|complete|cancel`, `decision.approve|reject|defer|comment`, `dependency.resolve|view-impact` are command-specific grants with the resource's exact project scope.
- `status.update.publish`: Project scope for assigned PM/authorized PMO; direct publish, no second approver in MVP.
- `status.update.correct`: PMO Admin or Project Manager explicitly granted; reason required, creates successor.
- `projects.{projectId}.rag-evaluations.evaluate`: calculate deterministic RAG for an authorized Project.
- `projects.{projectId}.rag-evaluations.override`: change/revoke effective value with reason and audit; separate sensitive grant.
- `projects.{projectId}.snapshots.view|verify`: read authorized immutable history or verify integrity; creation is internal to status publish/correct only.
- `financial.view|edit|export`, `resources.view|edit`, `documents.confidential.view`, `decision.approve`, `baseline.change`, `projects.{projectId}.rag-evaluations.override`, `audit.view|export`, `report.export`, `support.access`: separate sensitive grants.

All access requires active membership, Tenant, scope and data policy. Explicit deny wins. No role grants cross-tenant access.

## Effective MVP grants by role

Role names are presets; every grant remains a persisted scoped assignment. The following presets never bypass tenant membership, data policy, workflow state or explicit deny.

| Role preset | Default allow | Always denied by preset; separate grant required |
|---|---|---|
| Platform Admin | Tenant create/suspend/terminate; quota and platform health | Tenant business content, financials, project documents, impersonation/support content |
| Tenant Admin | Membership/invitation and tenant configuration within own Tenant | Platform lifecycle, project execution, publication, financial/confidential data |
| PMO Admin | Portfolio/project governance and grant administration within delegation ceiling | Cross-tenant; financial/export, confidential docs, support or RAG override absent specific grant |
| PMO | Read/write in assigned portfolio/projects; prepare status; publish only with `status.update.publish` | Platform/tenant lifecycle, correction, baseline change, RAG override and sensitive export absent grant |
| Project Manager | Execution/governance in assigned Project; default eligible publish grant for assigned Project | Other projects, `status.update.correct` unless explicitly granted, financial edit, baseline change, RAG override |
| Contributor | Assigned actions/deliverables, comments/evidence | Publish/correct status, approve decisions, access administration, financial/confidential data |
| Executive | Read assigned portfolio/project dashboards; decide only assigned decisions | Operational mutation, unassigned Project data, export, sensitive fields absent grant |
| Viewer | Read allowlisted fields in exact assigned scope | All mutations, publication, decisions, export absent separate grant |

Sensitive grants (`financial.*`, `resources.*`, `documents.confidential.view`, `decision.approve`, `baseline.change`, `rag-evaluations.override`, `audit.*`, `report.export`, `support.access`) must be separate records with issuer, scope, effective time, expiry where applicable and revocation metadata. `status.update.correct` also remains distinct from publish.

## Entitlement de Platform Root Admin

`platform.projects.purge` é uma capability de plataforma separada dos oito role presets de Tenant. Só Platform Root Admin com atribuição explícita pode operá-la; Platform Admin comum não a recebe implicitamente. O entitlement permite somente consultar identificadores mínimos, pré-visualizar impacto, confirmar e acompanhar purge. Não concede `projects.view`, support access, impersonation, acesso financeiro/documental ou conteúdo do Tenant. Não pode ser delegado por Tenant/Portfolio/Project Admin; origem, escopo, validade, revogação e ator são auditados.

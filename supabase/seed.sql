-- rbac-v1: application-owned permission catalog and platform role presets.
-- Tenant role presets are materialized per tenant by the onboarding flow, not seeded without a tenant.
BEGIN;

INSERT INTO public.permissions (key, resource_type, action, data_classification, is_sensitive)
VALUES
  ('tenant.lifecycle.create', 'tenant', 'create', 'restricted', true),
  ('tenant.lifecycle.suspend', 'tenant', 'suspend', 'restricted', true),
  ('tenant.lifecycle.reactivate', 'tenant', 'reactivate', 'restricted', true),
  ('tenant.lifecycle.terminate', 'tenant', 'terminate', 'restricted', true),
  ('platform.quotas.view', 'platform.quotas', 'view', 'internal', false),
  ('platform.health.view', 'platform.health', 'view', 'internal', false),
  ('platform.projects.purge', 'platform.projects', 'purge', 'restricted', true),
  ('tenant.export.request', 'tenant.export', 'request', 'restricted', true),
  ('tenant.export.download', 'tenant.export', 'download', 'restricted', true),
  ('tenant.export.validate', 'tenant.export', 'validate', 'restricted', true),
  ('tenant.export.dispute', 'tenant.export', 'dispute', 'restricted', true),
  ('tenant.export.dispute.resolve', 'tenant.export.dispute', 'resolve', 'restricted', true),
  ('tenant.admin.transfer.request', 'tenant.admin.transfer', 'request', 'restricted', true),
  ('tenant.admin.transfer.confirm', 'tenant.admin.transfer', 'confirm', 'restricted', true),
  ('membership.view', 'membership', 'view', 'internal', false),
  ('membership.manage', 'membership', 'manage', 'confidential', true),
  ('membership.invite', 'membership', 'invite', 'confidential', true),
  ('membership.revoke', 'membership', 'revoke', 'confidential', true),
  ('membership.grant', 'membership', 'grant', 'confidential', true),
  ('tenant.settings.view', 'tenant.settings', 'view', 'internal', false),
  ('tenant.settings.edit', 'tenant.settings', 'edit', 'confidential', true),
  ('portfolio.view', 'portfolio', 'view', 'internal', false),
  ('portfolio.create', 'portfolio', 'create', 'internal', false),
  ('portfolio.edit', 'portfolio', 'edit', 'internal', false),
  ('portfolio.archive', 'portfolio', 'archive', 'confidential', true),
  ('portfolio.projects.associate', 'portfolio.projects', 'associate', 'confidential', true),
  ('portfolio.projects.remove', 'portfolio.projects', 'remove', 'confidential', true),
  ('project.view', 'project', 'view', 'internal', false),
  ('project.create', 'project', 'create', 'internal', false),
  ('project.edit', 'project', 'edit', 'internal', false),
  ('project.archive', 'project', 'archive', 'confidential', true),
  ('project.assign', 'project', 'assign', 'confidential', true),
  ('milestone.view', 'milestone', 'view', 'internal', false),
  ('milestone.create', 'milestone', 'create', 'internal', false),
  ('milestone.edit', 'milestone', 'edit', 'internal', false),
  ('milestone.forecast', 'milestone', 'forecast', 'internal', false),
  ('milestone.complete', 'milestone', 'complete', 'internal', false),
  ('deliverable.view', 'deliverable', 'view', 'internal', false),
  ('deliverable.create', 'deliverable', 'create', 'internal', false),
  ('deliverable.edit', 'deliverable', 'edit', 'internal', false),
  ('deliverable.deliver', 'deliverable', 'deliver', 'internal', false),
  ('deliverable.accept', 'deliverable', 'accept', 'confidential', true),
  ('deliverable.reject', 'deliverable', 'reject', 'confidential', true),
  ('risk.view', 'risk', 'view', 'internal', false),
  ('risk.create', 'risk', 'create', 'internal', false),
  ('risk.edit', 'risk', 'edit', 'internal', false),
  ('risk.assess', 'risk', 'assess', 'internal', false),
  ('risk.respond', 'risk', 'respond', 'internal', false),
  ('risk.materialize', 'risk', 'materialize', 'confidential', true),
  ('risk.close', 'risk', 'close', 'confidential', true),
  ('issue.view', 'issue', 'view', 'internal', false),
  ('issue.create', 'issue', 'create', 'internal', false),
  ('issue.edit', 'issue', 'edit', 'internal', false),
  ('issue.assign', 'issue', 'assign', 'internal', false),
  ('issue.resolve', 'issue', 'resolve', 'internal', false),
  ('issue.close', 'issue', 'close', 'confidential', true),
  ('issue.link-risk', 'issue', 'link-risk', 'internal', false),
  ('action.view', 'action', 'view', 'internal', false),
  ('action.create', 'action', 'create', 'internal', false),
  ('action.edit', 'action', 'edit', 'internal', false),
  ('action.reassign', 'action', 'reassign', 'confidential', true),
  ('action.complete', 'action', 'complete', 'internal', false),
  ('action.cancel', 'action', 'cancel', 'confidential', true),
  ('decision.view', 'decision', 'view', 'internal', false),
  ('decision.create', 'decision', 'create', 'internal', false),
  ('decision.edit', 'decision', 'edit', 'internal', false),
  ('decision.approve', 'decision', 'approve', 'confidential', true),
  ('decision.reject', 'decision', 'reject', 'confidential', true),
  ('decision.defer', 'decision', 'defer', 'internal', false),
  ('decision.comment', 'decision', 'comment', 'internal', false),
  ('dependency.view', 'dependency', 'view', 'internal', false),
  ('dependency.create', 'dependency', 'create', 'internal', false),
  ('dependency.edit', 'dependency', 'edit', 'internal', false),
  ('dependency.resolve', 'dependency', 'resolve', 'internal', false),
  ('dependency.view-impact', 'dependency', 'view-impact', 'internal', false),
  ('status.update.view', 'status.update', 'view', 'internal', false),
  ('status.update.draft', 'status.update', 'draft', 'internal', false),
  ('status.update.publish', 'status.update', 'publish', 'confidential', true),
  ('status.update.correct', 'status.update', 'correct', 'confidential', true),
  ('projects.{projectid}.rag-evaluations.evaluate', 'rag-evaluation', 'evaluate', 'internal', false),
  ('projects.{projectid}.rag-evaluations.override', 'rag-evaluation', 'override', 'confidential', true),
  ('projects.{projectid}.snapshots.view', 'snapshot', 'view', 'internal', false),
  ('projects.{projectid}.snapshots.verify', 'snapshot', 'verify', 'internal', false),
  ('financial.view', 'financial', 'view', 'confidential', true),
  ('financial.edit', 'financial', 'edit', 'restricted', true),
  ('financial.export', 'financial', 'export', 'restricted', true),
  ('resources.view', 'resources', 'view', 'confidential', true),
  ('resources.edit', 'resources', 'edit', 'confidential', true),
  ('documents.view', 'documents', 'view', 'internal', false),
  ('documents.confidential.view', 'documents', 'confidential-view', 'restricted', true),
  ('baseline.change', 'baseline', 'change', 'restricted', true),
  ('project.data.import', 'project.data', 'import', 'confidential', true),
  ('project.data.import.replace', 'project.data', 'import-replace', 'restricted', true),
  ('audit.view', 'audit', 'view', 'confidential', true),
  ('audit.export', 'audit', 'export', 'restricted', true),
  ('report.export', 'report', 'export', 'restricted', true),
  ('support.access', 'support', 'access', 'restricted', true),
  ('ai.config.view', 'ai.config', 'view', 'internal', false),
  ('ai.config.manage', 'ai.config', 'manage', 'confidential', true),
  ('ai.cost.view', 'ai.cost', 'view', 'confidential', true),
  ('ai.cost.export', 'ai.cost', 'export', 'restricted', true)
ON CONFLICT (key) DO UPDATE SET
  resource_type = EXCLUDED.resource_type,
  action = EXCLUDED.action,
  data_classification = EXCLUDED.data_classification,
  is_sensitive = EXCLUDED.is_sensitive;

INSERT INTO public.roles (tenant_id, key, name, scope_type, is_system, status)
VALUES
  (NULL, 'platform_admin', 'Platform Admin', 'platform', TRUE, 'active'),
  (NULL, 'platform_root_admin', 'Platform Root Admin', 'platform', TRUE, 'active')
ON CONFLICT (tenant_id, key) DO UPDATE SET
  name = EXCLUDED.name,
  scope_type = EXCLUDED.scope_type,
  is_system = EXCLUDED.is_system,
  status = EXCLUDED.status;

INSERT INTO public.role_permissions (role_id, permission_key)
SELECT role.id, desired.permission_key
FROM (VALUES
  ('platform_admin', 'tenant.lifecycle.create'),
  ('platform_admin', 'tenant.lifecycle.suspend'),
  ('platform_admin', 'tenant.lifecycle.reactivate'),
  ('platform_admin', 'tenant.lifecycle.terminate'),
  ('platform_admin', 'platform.quotas.view'),
  ('platform_admin', 'platform.health.view'),
  ('platform_root_admin', 'platform.projects.purge')
) AS desired(role_key, permission_key)
JOIN public.roles AS role
  ON role.tenant_id IS NULL
 AND role.key = desired.role_key
 AND role.scope_type = 'platform'
 AND role.is_system
ON CONFLICT (role_id, permission_key) DO NOTHING;

COMMIT;

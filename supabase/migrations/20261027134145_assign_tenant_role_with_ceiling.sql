-- F1-05 / F1-06: a narrow role-grant RPC with same-Tenant and exact-scope
-- delegation checks. Until Portfolio/Project tables and their trusted scope
-- resolvers exist, this operation supports the Tenant scope only.

CREATE TABLE private.permission_scope_catalog (
  catalog_version TEXT NOT NULL,
  permission_key TEXT NOT NULL,
  scope_types TEXT[] NOT NULL,
  CONSTRAINT permission_scope_catalog_version_nonempty CHECK (char_length(btrim(catalog_version)) BETWEEN 1 AND 40),
  CONSTRAINT permission_scope_catalog_key_nonempty CHECK (char_length(btrim(permission_key)) BETWEEN 2 AND 160),
  CONSTRAINT permission_scope_catalog_scopes_nonempty CHECK (cardinality(scope_types) > 0),
  CONSTRAINT permission_scope_catalog_scopes_allowed CHECK (
    scope_types <@ ARRAY['platform','tenant','portfolio','project','resource','item']::TEXT[]
  ),
  PRIMARY KEY (catalog_version, permission_key)
);

CREATE INDEX permission_scope_catalog_permission_idx
  ON private.permission_scope_catalog (permission_key, catalog_version);
ALTER TABLE private.permission_scope_catalog ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE private.permission_scope_catalog FROM PUBLIC, anon, authenticated, service_role;
COMMENT ON TABLE private.permission_scope_catalog IS
  'Versioned scope compatibility copied from the application-owned permission catalog; private RPCs only.';

INSERT INTO private.permission_scope_catalog (catalog_version, permission_key, scope_types)
VALUES
  ('rbac-v1','tenant.lifecycle.create',ARRAY['platform']::TEXT[]),
  ('rbac-v1','tenant.lifecycle.suspend',ARRAY['platform']::TEXT[]),
  ('rbac-v1','tenant.lifecycle.reactivate',ARRAY['platform']::TEXT[]),
  ('rbac-v1','tenant.lifecycle.terminate',ARRAY['platform']::TEXT[]),
  ('rbac-v1','platform.quotas.view',ARRAY['platform']::TEXT[]),
  ('rbac-v1','platform.health.view',ARRAY['platform']::TEXT[]),
  ('rbac-v1','platform.projects.purge',ARRAY['platform']::TEXT[]),
  ('rbac-v1','tenant.export.request',ARRAY['platform','tenant']::TEXT[]),
  ('rbac-v1','tenant.export.download',ARRAY['platform','tenant']::TEXT[]),
  ('rbac-v1','tenant.export.validate',ARRAY['platform','tenant']::TEXT[]),
  ('rbac-v1','tenant.export.dispute',ARRAY['tenant']::TEXT[]),
  ('rbac-v1','tenant.export.dispute.resolve',ARRAY['platform']::TEXT[]),
  ('rbac-v1','tenant.admin.transfer.request',ARRAY['tenant']::TEXT[]),
  ('rbac-v1','tenant.admin.transfer.confirm',ARRAY['tenant']::TEXT[]),
  ('rbac-v1','membership.view',ARRAY['tenant']::TEXT[]),
  ('rbac-v1','membership.invite',ARRAY['tenant']::TEXT[]),
  ('rbac-v1','membership.revoke',ARRAY['tenant']::TEXT[]),
  ('rbac-v1','tenant.settings.view',ARRAY['tenant']::TEXT[]),
  ('rbac-v1','tenant.settings.edit',ARRAY['tenant']::TEXT[]),
  ('rbac-v1','portfolio.view',ARRAY['portfolio']::TEXT[]),
  ('rbac-v1','portfolio.create',ARRAY['tenant']::TEXT[]),
  ('rbac-v1','portfolio.edit',ARRAY['portfolio']::TEXT[]),
  ('rbac-v1','portfolio.archive',ARRAY['portfolio']::TEXT[]),
  ('rbac-v1','portfolio.projects.associate',ARRAY['portfolio']::TEXT[]),
  ('rbac-v1','portfolio.projects.remove',ARRAY['portfolio']::TEXT[]),
  ('rbac-v1','project.view',ARRAY['project']::TEXT[]),
  ('rbac-v1','project.create',ARRAY['portfolio']::TEXT[]),
  ('rbac-v1','project.edit',ARRAY['project']::TEXT[]),
  ('rbac-v1','project.archive',ARRAY['project']::TEXT[]),
  ('rbac-v1','project.assign',ARRAY['project']::TEXT[]),
  ('rbac-v1','milestone.view',ARRAY['project']::TEXT[]),
  ('rbac-v1','milestone.create',ARRAY['project']::TEXT[]),
  ('rbac-v1','milestone.edit',ARRAY['project']::TEXT[]),
  ('rbac-v1','milestone.forecast',ARRAY['project']::TEXT[]),
  ('rbac-v1','milestone.complete',ARRAY['project']::TEXT[]),
  ('rbac-v1','deliverable.view',ARRAY['project']::TEXT[]),
  ('rbac-v1','deliverable.create',ARRAY['project']::TEXT[]),
  ('rbac-v1','deliverable.edit',ARRAY['project']::TEXT[]),
  ('rbac-v1','deliverable.deliver',ARRAY['project']::TEXT[]),
  ('rbac-v1','deliverable.accept',ARRAY['project']::TEXT[]),
  ('rbac-v1','deliverable.reject',ARRAY['project']::TEXT[]),
  ('rbac-v1','risk.view',ARRAY['project']::TEXT[]),
  ('rbac-v1','risk.create',ARRAY['project']::TEXT[]),
  ('rbac-v1','risk.edit',ARRAY['project']::TEXT[]),
  ('rbac-v1','risk.assess',ARRAY['project']::TEXT[]),
  ('rbac-v1','risk.respond',ARRAY['project']::TEXT[]),
  ('rbac-v1','risk.materialize',ARRAY['project']::TEXT[]),
  ('rbac-v1','risk.close',ARRAY['project']::TEXT[]),
  ('rbac-v1','issue.view',ARRAY['project']::TEXT[]),
  ('rbac-v1','issue.create',ARRAY['project']::TEXT[]),
  ('rbac-v1','issue.edit',ARRAY['project']::TEXT[]),
  ('rbac-v1','issue.assign',ARRAY['project']::TEXT[]),
  ('rbac-v1','issue.resolve',ARRAY['project']::TEXT[]),
  ('rbac-v1','issue.close',ARRAY['project']::TEXT[]),
  ('rbac-v1','issue.link-risk',ARRAY['project']::TEXT[]),
  ('rbac-v1','action.view',ARRAY['project','item']::TEXT[]),
  ('rbac-v1','action.create',ARRAY['project']::TEXT[]),
  ('rbac-v1','action.edit',ARRAY['project','item']::TEXT[]),
  ('rbac-v1','action.reassign',ARRAY['project','item']::TEXT[]),
  ('rbac-v1','action.complete',ARRAY['project','item']::TEXT[]),
  ('rbac-v1','action.cancel',ARRAY['project','item']::TEXT[]),
  ('rbac-v1','decision.view',ARRAY['project']::TEXT[]),
  ('rbac-v1','decision.create',ARRAY['project']::TEXT[]),
  ('rbac-v1','decision.edit',ARRAY['project','item']::TEXT[]),
  ('rbac-v1','decision.approve',ARRAY['project','item']::TEXT[]),
  ('rbac-v1','decision.reject',ARRAY['project','item']::TEXT[]),
  ('rbac-v1','decision.defer',ARRAY['project','item']::TEXT[]),
  ('rbac-v1','decision.comment',ARRAY['project','item']::TEXT[]),
  ('rbac-v1','dependency.view',ARRAY['project']::TEXT[]),
  ('rbac-v1','dependency.create',ARRAY['project']::TEXT[]),
  ('rbac-v1','dependency.edit',ARRAY['project']::TEXT[]),
  ('rbac-v1','dependency.resolve',ARRAY['project']::TEXT[]),
  ('rbac-v1','dependency.view-impact',ARRAY['project']::TEXT[]),
  ('rbac-v1','status.update.view',ARRAY['project']::TEXT[]),
  ('rbac-v1','status.update.draft',ARRAY['project']::TEXT[]),
  ('rbac-v1','status.update.publish',ARRAY['project']::TEXT[]),
  ('rbac-v1','status.update.correct',ARRAY['project']::TEXT[]),
  ('rbac-v1','projects.{projectid}.rag-evaluations.evaluate',ARRAY['project']::TEXT[]),
  ('rbac-v1','projects.{projectid}.rag-evaluations.override',ARRAY['project']::TEXT[]),
  ('rbac-v1','projects.{projectid}.snapshots.view',ARRAY['project']::TEXT[]),
  ('rbac-v1','projects.{projectid}.snapshots.verify',ARRAY['project']::TEXT[]),
  ('rbac-v1','financial.view',ARRAY['project']::TEXT[]),
  ('rbac-v1','financial.edit',ARRAY['project']::TEXT[]),
  ('rbac-v1','financial.export',ARRAY['project']::TEXT[]),
  ('rbac-v1','resources.view',ARRAY['project']::TEXT[]),
  ('rbac-v1','resources.edit',ARRAY['project']::TEXT[]),
  ('rbac-v1','documents.view',ARRAY['project']::TEXT[]),
  ('rbac-v1','documents.confidential.view',ARRAY['project']::TEXT[]),
  ('rbac-v1','baseline.change',ARRAY['project']::TEXT[]),
  ('rbac-v1','project.data.import',ARRAY['project']::TEXT[]),
  ('rbac-v1','project.data.import.replace',ARRAY['project']::TEXT[]),
  ('rbac-v1','audit.view',ARRAY['tenant']::TEXT[]),
  ('rbac-v1','audit.export',ARRAY['tenant']::TEXT[]),
  ('rbac-v1','report.export',ARRAY['platform','tenant','portfolio','project']::TEXT[]),
  ('rbac-v1','support.access',ARRAY['platform']::TEXT[]),
  ('rbac-v1','ai.config.view',ARRAY['tenant']::TEXT[]),
  ('rbac-v1','ai.config.manage',ARRAY['tenant']::TEXT[]),
  ('rbac-v1','ai.cost.view',ARRAY['tenant']::TEXT[]),
  ('rbac-v1','ai.cost.export',ARRAY['tenant']::TEXT[]);

CREATE OR REPLACE FUNCTION private.assign_tenant_role(
  p_tenant_id UUID,
  p_subject_id UUID,
  p_role_key TEXT,
  p_reason TEXT,
  p_idempotency_key UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  v_actor UUID := auth.uid();
  v_now TIMESTAMPTZ := pg_catalog.now();
  v_tenant public.tenants%ROWTYPE;
  v_role public.roles%ROWTYPE;
  v_grant_id UUID;
  v_correlation_id UUID := gen_random_uuid();
  v_after JSONB;
  v_existing public.audit_events%ROWTYPE;
  v_existing_grant public.access_grants%ROWTYPE;
BEGIN
  IF v_actor IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;
  IF p_tenant_id IS NULL OR p_subject_id IS NULL OR p_role_key IS NULL
     OR p_role_key !~ '^[a-z][a-z0-9_.-]{1,79}$'
     OR p_reason IS NULL OR p_reason <> pg_catalog.btrim(p_reason)
     OR p_idempotency_key IS NULL
     OR pg_catalog.char_length(p_reason) NOT BETWEEN 1 AND 1000 THEN
    RAISE EXCEPTION 'Invalid role assignment' USING ERRCODE = '22023';
  END IF;
  IF p_subject_id = v_actor THEN
    RAISE EXCEPTION 'Self role assignment is not permitted' USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_tenant FROM public.tenants WHERE id = p_tenant_id FOR UPDATE;
  IF NOT FOUND OR v_tenant.status <> 'active' THEN
    RAISE EXCEPTION 'Tenant is unavailable' USING ERRCODE = '42501';
  END IF;

  PERFORM 1 FROM public.memberships
  WHERE tenant_id = p_tenant_id AND user_id = v_actor AND status = 'active'
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Active membership required' USING ERRCODE = '42501';
  END IF;
  PERFORM 1 FROM public.memberships
  WHERE tenant_id = p_tenant_id AND user_id = p_subject_id AND status = 'active'
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Target member is unavailable' USING ERRCODE = '42501';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.access_grants AS g
    JOIN public.roles AS r ON r.id = g.role_id
      AND r.scope_type = 'tenant' AND r.tenant_id = p_tenant_id AND r.status = 'active'
    JOIN public.role_permissions AS rp ON rp.role_id = r.id
      AND rp.permission_key = 'membership.invite'
    WHERE g.subject_id = v_actor AND g.tenant_id = p_tenant_id
      AND g.role_scope_type = 'tenant' AND g.role_tenant_id = p_tenant_id
      AND g.scope_type = 'tenant' AND g.scope_id = p_tenant_id::TEXT
      AND g.effect = 'allow' AND g.revoked_at IS NULL
      AND g.starts_at <= v_now AND (g.expires_at IS NULL OR g.expires_at > v_now)
  ) OR EXISTS (
    SELECT 1
    FROM public.access_grants AS g
    JOIN public.roles AS r ON r.id = g.role_id
      AND r.scope_type = 'tenant' AND r.tenant_id = p_tenant_id AND r.status = 'active'
    JOIN public.role_permissions AS rp ON rp.role_id = r.id
      AND rp.permission_key = 'membership.invite'
    WHERE g.subject_id = v_actor AND g.tenant_id = p_tenant_id
      AND g.role_scope_type = 'tenant' AND g.role_tenant_id = p_tenant_id
      AND g.scope_type = 'tenant' AND g.scope_id = p_tenant_id::TEXT
      AND g.effect = 'deny' AND g.revoked_at IS NULL
      AND g.starts_at <= v_now AND (g.expires_at IS NULL OR g.expires_at > v_now)
  ) THEN
    RAISE EXCEPTION 'Membership invitation permission required' USING ERRCODE = '42501';
  END IF;

  v_after := pg_catalog.jsonb_build_object(
    'roleKey', p_role_key,
    'scopeType', 'tenant',
    'scopeId', p_tenant_id,
    'subjectId', p_subject_id
  );
  SELECT * INTO v_existing FROM public.audit_events
  WHERE tenant_id = p_tenant_id
    AND source = 'access-grant-assignment'
    AND idempotency_key = 'assign:' || p_idempotency_key::TEXT
  FOR UPDATE;
  IF FOUND THEN
    IF v_existing.actor_id <> v_actor OR v_existing.reason <> p_reason OR v_existing.after_redacted <> v_after THEN
      RAISE EXCEPTION 'Idempotency key payload mismatch' USING ERRCODE = '23505';
    END IF;
    SELECT * INTO v_existing_grant FROM public.access_grants
    WHERE id = v_existing.resource_id AND tenant_id = p_tenant_id;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Stored grant result is unavailable' USING ERRCODE = '22023';
    END IF;
    RETURN pg_catalog.jsonb_build_object(
      'grantId', v_existing_grant.id,
      'tenantId', p_tenant_id,
      'subjectId', p_subject_id,
      'roleKey', p_role_key,
      'scopeType', 'tenant',
      'scopeId', p_tenant_id,
      'correlationId', v_existing.correlation_id,
      'idempotentReplay', TRUE
    );
  END IF;

  SELECT * INTO v_role FROM public.roles
  WHERE tenant_id = p_tenant_id AND key = p_role_key
    AND scope_type = 'tenant' AND is_system AND status = 'active';
  IF NOT FOUND OR NOT EXISTS (
    SELECT 1 FROM public.role_permissions WHERE role_id = v_role.id
  ) OR EXISTS (
    SELECT 1
    FROM public.role_permissions AS target_permission
    WHERE target_permission.role_id = v_role.id
      AND NOT EXISTS (
        SELECT 1 FROM private.permission_scope_catalog AS scope_catalog
        WHERE scope_catalog.catalog_version = 'rbac-v1'
          AND scope_catalog.permission_key = target_permission.permission_key
          AND scope_catalog.scope_types @> ARRAY['tenant']::TEXT[]
      )
  ) THEN
    RAISE EXCEPTION 'Role or scope is unavailable' USING ERRCODE = '22023';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM public.role_permissions AS target_permission
    WHERE target_permission.role_id = v_role.id
      AND NOT EXISTS (
        SELECT 1
        FROM public.access_grants AS issuer_grant
        JOIN public.roles AS issuer_role ON issuer_role.id = issuer_grant.role_id
          AND issuer_role.scope_type = 'tenant'
          AND issuer_role.tenant_id = p_tenant_id
          AND issuer_role.status = 'active'
        JOIN public.role_permissions AS issuer_permission
          ON issuer_permission.role_id = issuer_role.id
          AND issuer_permission.permission_key = target_permission.permission_key
        WHERE issuer_grant.subject_id = v_actor
          AND issuer_grant.tenant_id = p_tenant_id
          AND issuer_grant.role_scope_type = 'tenant'
          AND issuer_grant.role_tenant_id = p_tenant_id
          AND issuer_grant.scope_type = 'tenant'
          AND issuer_grant.scope_id = p_tenant_id::TEXT
          AND issuer_grant.effect = 'allow'
          AND issuer_grant.revoked_at IS NULL
          AND issuer_grant.starts_at <= v_now
          AND (issuer_grant.expires_at IS NULL OR issuer_grant.expires_at > v_now)
          AND NOT EXISTS (
            SELECT 1
            FROM public.access_grants AS deny_grant
            JOIN public.roles AS deny_role ON deny_role.id = deny_grant.role_id
              AND deny_role.scope_type = 'tenant'
              AND deny_role.tenant_id = p_tenant_id
              AND deny_role.status = 'active'
            JOIN public.role_permissions AS denied_permission
              ON denied_permission.role_id = deny_role.id
              AND denied_permission.permission_key = target_permission.permission_key
            WHERE deny_grant.subject_id = v_actor
              AND deny_grant.tenant_id = p_tenant_id
              AND deny_grant.role_scope_type = 'tenant'
              AND deny_grant.role_tenant_id = p_tenant_id
              AND deny_grant.scope_type = 'tenant'
              AND deny_grant.scope_id = p_tenant_id::TEXT
              AND deny_grant.effect = 'deny'
              AND deny_grant.revoked_at IS NULL
              AND deny_grant.starts_at <= v_now
              AND (deny_grant.expires_at IS NULL OR deny_grant.expires_at > v_now)
          )
      )
  ) THEN
    RAISE EXCEPTION 'Role exceeds the issuer delegation ceiling' USING ERRCODE = '42501';
  END IF;

  INSERT INTO public.access_grants (
    tenant_id, subject_id, role_id, role_scope_type, role_tenant_id,
    scope_type, scope_id, effect, granted_by, reason
  ) VALUES (
    p_tenant_id, p_subject_id, v_role.id, 'tenant', p_tenant_id,
    'tenant', p_tenant_id::TEXT, 'allow', v_actor, p_reason
  ) RETURNING id INTO v_grant_id;

  INSERT INTO public.audit_events (
    tenant_id, actor_id, actor_type, action, resource_type, resource_id,
    correlation_id, reason, after_redacted, source, schema_version, idempotency_key
  ) VALUES (
    p_tenant_id, v_actor, 'user', 'access_grant.create', 'access_grant', v_grant_id,
    v_correlation_id, p_reason, v_after,
    'access-grant-assignment', '1', 'assign:' || p_idempotency_key::TEXT
  );

  RETURN pg_catalog.jsonb_build_object(
    'grantId', v_grant_id,
    'tenantId', p_tenant_id,
    'subjectId', p_subject_id,
    'roleKey', v_role.key,
    'scopeType', 'tenant',
    'scopeId', p_tenant_id,
    'correlationId', v_correlation_id,
    'idempotentReplay', FALSE
  );
END;
$function$;

REVOKE ALL ON FUNCTION private.assign_tenant_role(UUID, UUID, TEXT, TEXT, UUID) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION private.assign_tenant_role(UUID, UUID, TEXT, TEXT, UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.assign_tenant_role(
  p_tenant_id UUID,
  p_subject_id UUID,
  p_role_key TEXT,
  p_reason TEXT,
  p_idempotency_key UUID
)
RETURNS JSONB
LANGUAGE SQL
SECURITY INVOKER
SET search_path = ''
AS $function$
  SELECT private.assign_tenant_role(p_tenant_id, p_subject_id, p_role_key, p_reason, p_idempotency_key);
$function$;

REVOKE ALL ON FUNCTION public.assign_tenant_role(UUID, UUID, TEXT, TEXT, UUID) FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.assign_tenant_role(UUID, UUID, TEXT, TEXT, UUID) TO authenticated;

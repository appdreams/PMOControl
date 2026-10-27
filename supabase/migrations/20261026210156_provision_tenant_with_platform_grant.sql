-- F1-06: platform-authorized Tenant provisioning with atomic presets and audit.
CREATE SCHEMA IF NOT EXISTS private;
REVOKE ALL ON SCHEMA private FROM PUBLIC, anon, authenticated, service_role;
GRANT USAGE ON SCHEMA private TO authenticated;

CREATE TABLE private.tenant_role_preset_permissions (
  catalog_version TEXT NOT NULL,
  role_key TEXT NOT NULL,
  role_name TEXT NOT NULL,
  permission_key TEXT NOT NULL REFERENCES public.permissions (key) ON DELETE RESTRICT,
  PRIMARY KEY (catalog_version, role_key, permission_key),
  CONSTRAINT tenant_role_preset_catalog_version CHECK (catalog_version = 'rbac-v1'),
  CONSTRAINT tenant_role_preset_role_key CHECK (role_key IN (
    'tenant_admin', 'pmo_admin', 'pmo', 'project_manager', 'contributor', 'executive', 'viewer'
  ))
);
ALTER TABLE private.tenant_role_preset_permissions ENABLE ROW LEVEL SECURITY;
REVOKE ALL PRIVILEGES ON TABLE private.tenant_role_preset_permissions FROM PUBLIC, anon, authenticated, service_role;

INSERT INTO private.tenant_role_preset_permissions (catalog_version, role_key, role_name, permission_key)
SELECT p.catalog_version, p.role_key, p.role_name, permission_key
FROM (VALUES
  ('rbac-v1','tenant_admin','Tenant Admin',ARRAY['membership.view','membership.invite','membership.revoke','tenant.settings.view','tenant.settings.edit']::text[]),
  ('rbac-v1','pmo_admin','PMO Admin',ARRAY['portfolio.view','portfolio.create','portfolio.edit','portfolio.archive','project.view','project.create','project.edit','project.archive','project.assign','membership.view','membership.invite','membership.revoke','status.update.view','status.update.draft','audit.view']::text[]),
  ('rbac-v1','pmo','PMO',ARRAY['portfolio.view','project.view','project.create','project.edit','milestone.view','milestone.create','milestone.edit','deliverable.view','deliverable.create','deliverable.edit','risk.view','risk.create','risk.edit','issue.view','issue.create','issue.edit','action.view','action.create','action.edit','decision.view','decision.create','dependency.view','dependency.create','dependency.edit','status.update.view','status.update.draft']::text[]),
  ('rbac-v1','project_manager','Project Manager',ARRAY['project.view','project.edit','milestone.view','milestone.create','milestone.edit','milestone.forecast','milestone.complete','deliverable.view','deliverable.create','deliverable.edit','deliverable.deliver','risk.view','risk.create','risk.edit','risk.assess','risk.respond','issue.view','issue.create','issue.edit','issue.assign','issue.resolve','action.view','action.create','action.edit','action.reassign','action.complete','decision.view','decision.create','decision.edit','decision.comment','dependency.view','dependency.create','dependency.edit','dependency.resolve','status.update.view','status.update.draft','status.update.publish']::text[]),
  ('rbac-v1','contributor','Contributor',ARRAY['project.view','milestone.view','deliverable.view','deliverable.deliver','action.view','action.edit','action.complete','decision.view','decision.comment']::text[]),
  ('rbac-v1','executive','Executive',ARRAY['portfolio.view','project.view','status.update.view','projects.{projectid}.snapshots.view']::text[]),
  ('rbac-v1','viewer','Viewer',ARRAY['portfolio.view','project.view','milestone.view','deliverable.view','risk.view','issue.view','action.view','decision.view','dependency.view','status.update.view','projects.{projectid}.snapshots.view']::text[])
) AS p(catalog_version, role_key, role_name, permission_keys)
CROSS JOIN LATERAL unnest(p.permission_keys) AS permission_key;

CREATE OR REPLACE FUNCTION private.provision_tenant(
  p_slug TEXT, p_display_name TEXT, p_reason TEXT, p_idempotency_key UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  v_actor UUID := auth.uid();
  v_now TIMESTAMPTZ := pg_catalog.now();
  v_existing public.audit_events%ROWTYPE;
  v_request JSONB;
  v_tenant_id UUID;
  v_correlation_id UUID := gen_random_uuid();
BEGIN
  IF v_actor IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;
  IF p_slug IS NULL OR p_slug <> pg_catalog.btrim(p_slug)
     OR p_slug <> pg_catalog.lower(p_slug)
     OR pg_catalog.char_length(p_slug) NOT BETWEEN 3 AND 63
     OR p_slug !~ '^[a-z0-9]+([a-z0-9-]*[a-z0-9])?$'
     OR p_display_name IS NULL OR p_display_name <> pg_catalog.btrim(p_display_name)
     OR pg_catalog.char_length(p_display_name) NOT BETWEEN 1 AND 160
     OR p_reason IS NULL OR p_reason <> pg_catalog.btrim(p_reason)
     OR pg_catalog.char_length(p_reason) NOT BETWEEN 1 AND 1000
     OR p_idempotency_key IS NULL THEN
    RAISE EXCEPTION 'Invalid provisioning request' USING ERRCODE = '22023';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.access_grants AS g
    JOIN public.roles AS r ON r.id = g.role_id
      AND r.scope_type = 'platform' AND r.tenant_id IS NULL AND r.status = 'active'
    JOIN public.role_permissions AS rp ON rp.role_id = r.id
    WHERE g.subject_id = v_actor AND g.tenant_id IS NULL
      AND g.role_scope_type = 'platform' AND g.role_tenant_id IS NULL
      AND g.scope_type = 'platform' AND g.scope_id = 'platform'
      AND g.effect = 'allow' AND g.revoked_at IS NULL
      AND g.starts_at <= v_now AND (g.expires_at IS NULL OR g.expires_at > v_now)
      AND rp.permission_key = 'tenant.lifecycle.create'
  ) OR EXISTS (
    SELECT 1 FROM public.access_grants AS g
    JOIN public.roles AS r ON r.id = g.role_id
      AND r.scope_type = 'platform' AND r.tenant_id IS NULL AND r.status = 'active'
    JOIN public.role_permissions AS rp ON rp.role_id = r.id
    WHERE g.subject_id = v_actor AND g.tenant_id IS NULL
      AND g.role_scope_type = 'platform' AND g.role_tenant_id IS NULL
      AND g.scope_type = 'platform' AND g.scope_id = 'platform'
      AND g.effect = 'deny' AND g.revoked_at IS NULL
      AND g.starts_at <= v_now AND (g.expires_at IS NULL OR g.expires_at > v_now)
      AND rp.permission_key = 'tenant.lifecycle.create'
  ) THEN
    RAISE EXCEPTION 'Platform permission required' USING ERRCODE = '42501';
  END IF;

  PERFORM pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended('tenant-provisioning:' || p_idempotency_key::TEXT, 0)
  );
  v_request := pg_catalog.jsonb_build_object(
    'slug', p_slug, 'displayName', p_display_name, 'reason', p_reason, 'catalogVersion', 'rbac-v1'
  );

  SELECT * INTO v_existing FROM public.audit_events
  WHERE tenant_id IS NULL AND source = 'tenant-provisioning'
    AND idempotency_key = p_idempotency_key::TEXT
  FOR UPDATE;
  IF FOUND THEN
    IF v_existing.actor_id <> v_actor OR v_existing.after_redacted IS DISTINCT FROM v_request THEN
      RAISE EXCEPTION 'Idempotency key conflicts with another request' USING ERRCODE = '23505';
    END IF;
    RETURN pg_catalog.jsonb_build_object(
      'tenantId', v_existing.resource_id, 'correlationId', v_existing.correlation_id
    );
  END IF;

  INSERT INTO public.tenants (slug, display_name, status, created_by)
  VALUES (p_slug, p_display_name, 'active', v_actor) RETURNING id INTO v_tenant_id;

  INSERT INTO public.roles (tenant_id, key, name, scope_type, is_system, status)
  SELECT v_tenant_id, p.role_key, p.role_name, 'tenant', TRUE, 'active'
  FROM (
    SELECT DISTINCT role_key, role_name
    FROM private.tenant_role_preset_permissions WHERE catalog_version = 'rbac-v1'
  ) AS p;

  INSERT INTO public.role_permissions (role_id, permission_key)
  SELECT r.id, preset.permission_key
  FROM public.roles AS r
  JOIN private.tenant_role_preset_permissions AS preset
    ON preset.catalog_version = 'rbac-v1' AND preset.role_key = r.key
  WHERE r.tenant_id = v_tenant_id AND r.scope_type = 'tenant';

  INSERT INTO public.audit_events (
    tenant_id, actor_id, actor_type, action, resource_type, resource_id,
    correlation_id, reason, after_redacted, source, schema_version, idempotency_key
  ) VALUES (
    NULL, v_actor, 'user', 'tenant.lifecycle.create', 'tenant', v_tenant_id,
    v_correlation_id, p_reason, v_request, 'tenant-provisioning', '1', p_idempotency_key::TEXT
  );

  RETURN pg_catalog.jsonb_build_object('tenantId', v_tenant_id, 'correlationId', v_correlation_id);
END;
$function$;

REVOKE ALL ON FUNCTION private.provision_tenant(TEXT, TEXT, TEXT, UUID) FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION private.provision_tenant(TEXT, TEXT, TEXT, UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.provision_tenant(
  p_slug TEXT, p_display_name TEXT, p_reason TEXT, p_idempotency_key UUID
)
RETURNS JSONB
LANGUAGE SQL
SECURITY INVOKER
SET search_path = ''
AS $function$
  SELECT private.provision_tenant(p_slug, p_display_name, p_reason, p_idempotency_key);
$function$;

REVOKE ALL ON FUNCTION public.provision_tenant(TEXT, TEXT, TEXT, UUID) FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.provision_tenant(TEXT, TEXT, TEXT, UUID) TO authenticated;

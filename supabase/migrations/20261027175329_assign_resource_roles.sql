-- F1-06/F1-10: allow Tenant administrators to assign resource roles to other
-- active Tenant members, with same-Tenant resource resolution and atomic audit.

INSERT INTO public.permissions (key, resource_type, action, data_classification, is_sensitive)
VALUES ('membership.grant', 'membership', 'grant', 'confidential', TRUE)
ON CONFLICT (key) DO NOTHING;

INSERT INTO private.permission_scope_catalog (catalog_version, permission_key, scope_types)
VALUES ('rbac-v1', 'membership.grant', ARRAY['tenant']::TEXT[])
ON CONFLICT (catalog_version, permission_key) DO NOTHING;

INSERT INTO private.tenant_role_preset_permissions (catalog_version, role_key, role_name, permission_key)
VALUES
  ('rbac-v1', 'tenant_admin', 'Tenant Admin', 'membership.grant'),
  ('rbac-v1', 'pmo_admin', 'PMO Admin', 'membership.grant')
ON CONFLICT (catalog_version, role_key, permission_key) DO NOTHING;

INSERT INTO public.role_permissions (role_id, permission_key)
SELECT r.id, 'membership.grant'
FROM public.roles AS r
WHERE r.scope_type = 'tenant' AND r.status = 'active'
  AND r.key IN ('tenant_admin', 'pmo_admin')
ON CONFLICT (role_id, permission_key) DO NOTHING;

CREATE OR REPLACE FUNCTION private.assign_resource_role(
  p_tenant_id UUID,
  p_subject_id UUID,
  p_role_key TEXT,
  p_scope_type TEXT,
  p_scope_id UUID,
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
  v_role public.roles%ROWTYPE;
  v_grant_id UUID;
  v_correlation_id UUID := gen_random_uuid();
  v_after JSONB;
  v_existing public.audit_events%ROWTYPE;
BEGIN
  IF v_actor IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;
  IF p_tenant_id IS NULL OR p_subject_id IS NULL OR p_subject_id = v_actor
     OR p_role_key IS NULL OR p_role_key !~ '^[a-z][a-z0-9_.-]{1,79}$'
     OR p_scope_type IS NULL OR p_scope_type NOT IN ('portfolio', 'project') OR p_scope_id IS NULL
     OR p_reason IS NULL OR p_reason <> pg_catalog.btrim(p_reason)
     OR pg_catalog.char_length(p_reason) NOT BETWEEN 1 AND 1000
     OR p_idempotency_key IS NULL THEN
    RAISE EXCEPTION 'Invalid resource role assignment' USING ERRCODE = '22023';
  END IF;

  PERFORM 1 FROM public.tenants AS t
  WHERE t.id = p_tenant_id AND t.status = 'active'
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Tenant is unavailable' USING ERRCODE = '42501';
  END IF;

  PERFORM 1 FROM public.memberships AS m
  WHERE m.tenant_id = p_tenant_id AND m.user_id IN (v_actor, p_subject_id)
  ORDER BY m.user_id FOR UPDATE;
  IF (SELECT pg_catalog.count(*) FROM public.memberships AS m
      WHERE m.tenant_id = p_tenant_id AND m.user_id = v_actor AND m.status = 'active') <> 1
     OR (SELECT pg_catalog.count(*) FROM public.memberships AS m
         WHERE m.tenant_id = p_tenant_id AND m.user_id = p_subject_id AND m.status = 'active') <> 1 THEN
    RAISE EXCEPTION 'Active Tenant membership required' USING ERRCODE = '42501';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.access_grants AS g
    JOIN public.roles AS r ON r.id = g.role_id AND r.status = 'active'
      AND r.scope_type = 'tenant' AND r.tenant_id = p_tenant_id
    JOIN public.role_permissions AS rp ON rp.role_id = r.id
      AND rp.permission_key = 'membership.grant'
    WHERE g.subject_id = v_actor AND g.tenant_id = p_tenant_id
      AND g.role_scope_type = 'tenant' AND g.role_tenant_id = p_tenant_id
      AND g.scope_type = 'tenant' AND g.scope_id = p_tenant_id::TEXT
      AND g.effect = 'allow' AND g.revoked_at IS NULL
      AND g.starts_at <= v_now AND (g.expires_at IS NULL OR g.expires_at > v_now)
  ) OR EXISTS (
    SELECT 1 FROM public.access_grants AS g
    JOIN public.roles AS r ON r.id = g.role_id AND r.status = 'active'
      AND r.scope_type = 'tenant' AND r.tenant_id = p_tenant_id
    JOIN public.role_permissions AS rp ON rp.role_id = r.id
      AND rp.permission_key = 'membership.grant'
    WHERE g.subject_id = v_actor AND g.tenant_id = p_tenant_id
      AND g.role_scope_type = 'tenant' AND g.role_tenant_id = p_tenant_id
      AND g.scope_type = 'tenant' AND g.scope_id = p_tenant_id::TEXT
      AND g.effect = 'deny' AND g.revoked_at IS NULL
      AND g.starts_at <= v_now AND (g.expires_at IS NULL OR g.expires_at > v_now)
  ) THEN
    RAISE EXCEPTION 'Resource role assignment permission required' USING ERRCODE = '42501';
  END IF;

  IF p_scope_type = 'portfolio' THEN
    PERFORM 1 FROM public.portfolios AS p
    WHERE p.tenant_id = p_tenant_id AND p.id = p_scope_id
      AND p.status = 'active' AND p.archived_at IS NULL
    FOR UPDATE;
  ELSE
    PERFORM 1 FROM public.projects AS p
    WHERE p.tenant_id = p_tenant_id AND p.id = p_scope_id
      AND p.status NOT IN ('completed', 'cancelled') AND p.archived_at IS NULL
    FOR UPDATE;
  END IF;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Resource is unavailable' USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_role FROM public.roles AS r
  WHERE r.tenant_id = p_tenant_id AND r.key = p_role_key
    AND r.scope_type = 'tenant' AND r.is_system AND r.status = 'active'
    AND r.key <> 'tenant_admin';
  IF NOT FOUND
     OR NOT EXISTS (SELECT 1 FROM public.role_permissions AS rp WHERE rp.role_id = v_role.id)
     OR NOT EXISTS (
       SELECT 1 FROM public.role_permissions AS rp
       JOIN private.permission_scope_catalog AS sc
         ON sc.catalog_version = 'rbac-v1' AND sc.permission_key = rp.permission_key
         AND sc.scope_types @> ARRAY[p_scope_type]::TEXT[]
       WHERE rp.role_id = v_role.id
     )
     OR EXISTS (
       SELECT 1 FROM public.role_permissions AS rp
       WHERE rp.role_id = v_role.id
         AND NOT EXISTS (SELECT 1 FROM private.permission_scope_catalog AS sc
                         WHERE sc.catalog_version = 'rbac-v1' AND sc.permission_key = rp.permission_key)
     ) THEN
    RAISE EXCEPTION 'Role is unavailable for this resource scope' USING ERRCODE = '22023';
  END IF;

  v_after := pg_catalog.jsonb_build_object(
    'subjectId', p_subject_id, 'roleKey', v_role.key,
    'scopeType', p_scope_type, 'scopeId', p_scope_id
  );
  SELECT * INTO v_existing FROM public.audit_events AS a
  WHERE a.tenant_id = p_tenant_id AND a.source = 'resource-access-grant'
    AND a.idempotency_key = 'assign:' || p_idempotency_key::TEXT
  FOR UPDATE;
  IF FOUND THEN
    IF v_existing.actor_id <> v_actor OR v_existing.reason <> p_reason
       OR v_existing.after_redacted <> v_after THEN
      RAISE EXCEPTION 'Idempotency key payload mismatch' USING ERRCODE = '23505';
    END IF;
    RETURN pg_catalog.jsonb_build_object(
      'grantId', v_existing.resource_id, 'tenantId', p_tenant_id,
      'subjectId', p_subject_id, 'roleKey', v_role.key,
      'scopeType', p_scope_type, 'scopeId', p_scope_id,
      'correlationId', v_existing.correlation_id, 'idempotentReplay', TRUE
    );
  END IF;

  INSERT INTO public.access_grants (
    tenant_id, subject_id, role_id, role_scope_type, role_tenant_id,
    scope_type, scope_id, effect, granted_by, reason
  ) VALUES (
    p_tenant_id, p_subject_id, v_role.id, 'tenant', p_tenant_id,
    p_scope_type, p_scope_id::TEXT, 'allow', v_actor, p_reason
  ) RETURNING id INTO v_grant_id;

  INSERT INTO public.audit_events (
    tenant_id, actor_id, actor_type, action, resource_type, resource_id,
    correlation_id, reason, after_redacted, source, schema_version, idempotency_key
  ) VALUES (
    p_tenant_id, v_actor, 'user', 'access_grant.create', 'access_grant', v_grant_id,
    v_correlation_id, p_reason, v_after, 'resource-access-grant', '1',
    'assign:' || p_idempotency_key::TEXT
  );

  RETURN pg_catalog.jsonb_build_object(
    'grantId', v_grant_id, 'tenantId', p_tenant_id,
    'subjectId', p_subject_id, 'roleKey', v_role.key,
    'scopeType', p_scope_type, 'scopeId', p_scope_id,
    'correlationId', v_correlation_id, 'idempotentReplay', FALSE
  );
END;
$function$;

REVOKE ALL ON FUNCTION private.assign_resource_role(UUID, UUID, TEXT, TEXT, UUID, TEXT, UUID)
  FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION private.assign_resource_role(UUID, UUID, TEXT, TEXT, UUID, TEXT, UUID)
  TO authenticated;

CREATE OR REPLACE FUNCTION public.assign_resource_role(
  p_tenant_id UUID, p_subject_id UUID, p_role_key TEXT,
  p_scope_type TEXT, p_scope_id UUID, p_reason TEXT, p_idempotency_key UUID
)
RETURNS JSONB
LANGUAGE SQL
SECURITY INVOKER
SET search_path = ''
AS $function$
  SELECT private.assign_resource_role(
    p_tenant_id, p_subject_id, p_role_key, p_scope_type,
    p_scope_id, p_reason, p_idempotency_key
  );
$function$;

REVOKE ALL ON FUNCTION public.assign_resource_role(UUID, UUID, TEXT, TEXT, UUID, TEXT, UUID)
  FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.assign_resource_role(UUID, UUID, TEXT, TEXT, UUID, TEXT, UUID)
  TO authenticated;

-- F1-05 / F1-10: allow Tenant administrators to suspend/reactivate memberships
-- without revoking their grants; each versioned transition is audited atomically.

INSERT INTO public.permissions (key, resource_type, action, data_classification, is_sensitive)
VALUES ('membership.manage', 'membership', 'manage', 'confidential', TRUE)
ON CONFLICT (key) DO NOTHING;

INSERT INTO private.permission_scope_catalog (catalog_version, permission_key, scope_types)
VALUES ('rbac-v1', 'membership.manage', ARRAY['tenant']::TEXT[])
ON CONFLICT (catalog_version, permission_key) DO NOTHING;

INSERT INTO private.tenant_role_preset_permissions (catalog_version, role_key, role_name, permission_key)
VALUES
  ('rbac-v1', 'tenant_admin', 'Tenant Admin', 'membership.manage'),
  ('rbac-v1', 'pmo_admin', 'PMO Admin', 'membership.manage')
ON CONFLICT (catalog_version, role_key, permission_key) DO NOTHING;

INSERT INTO public.role_permissions (role_id, permission_key)
SELECT r.id, 'membership.manage'
FROM public.roles AS r
WHERE r.scope_type = 'tenant'
  AND r.status = 'active'
  AND r.key IN ('tenant_admin', 'pmo_admin')
ON CONFLICT (role_id, permission_key) DO NOTHING;

CREATE OR REPLACE FUNCTION private.transition_tenant_membership(
  p_tenant_id UUID,
  p_membership_id UUID,
  p_transition TEXT,
  p_reason TEXT,
  p_expected_version BIGINT,
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
  v_target public.memberships%ROWTYPE;
  v_existing public.audit_events%ROWTYPE;
  v_permission TEXT;
  v_expected_status TEXT;
  v_next_status TEXT;
  v_before JSONB;
  v_after JSONB;
  v_correlation_id UUID := gen_random_uuid();
BEGIN
  IF v_actor IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;
  IF p_tenant_id IS NULL OR p_membership_id IS NULL
     OR p_transition NOT IN ('suspend', 'reactivate')
     OR p_expected_version IS NULL OR p_expected_version < 1
     OR p_idempotency_key IS NULL
     OR p_reason IS NULL OR p_reason <> pg_catalog.btrim(p_reason)
     OR pg_catalog.char_length(p_reason) NOT BETWEEN 1 AND 1000 THEN
    RAISE EXCEPTION 'Invalid membership transition' USING ERRCODE = '22023';
  END IF;

  v_permission := CASE p_transition
    WHEN 'suspend' THEN 'membership.manage'
    WHEN 'reactivate' THEN 'membership.manage'
  END;
  v_expected_status := CASE p_transition
    WHEN 'suspend' THEN 'active'
    WHEN 'reactivate' THEN 'suspended'
  END;
  v_next_status := CASE p_transition
    WHEN 'suspend' THEN 'suspended'
    WHEN 'reactivate' THEN 'active'
  END;

  SELECT * INTO v_tenant
  FROM public.tenants
  WHERE id = p_tenant_id
  FOR UPDATE;
  IF NOT FOUND OR v_tenant.status <> 'active' THEN
    RAISE EXCEPTION 'Tenant is unavailable' USING ERRCODE = '42501';
  END IF;

  -- Keep the same lock order as invitation, grant and revocation RPCs.
  PERFORM m.id
  FROM public.memberships AS m
  WHERE m.tenant_id = p_tenant_id
  ORDER BY m.id
  FOR UPDATE;

  IF NOT EXISTS (
    SELECT 1 FROM public.memberships
    WHERE tenant_id = p_tenant_id AND user_id = v_actor AND status = 'active'
  ) THEN
    RAISE EXCEPTION 'Active membership required' USING ERRCODE = '42501';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.access_grants AS g
    JOIN public.roles AS r ON r.id = g.role_id
      AND r.scope_type = 'tenant' AND r.tenant_id = p_tenant_id AND r.status = 'active'
    JOIN public.role_permissions AS rp ON rp.role_id = r.id
      AND rp.permission_key = v_permission
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
      AND rp.permission_key = v_permission
    WHERE g.subject_id = v_actor AND g.tenant_id = p_tenant_id
      AND g.role_scope_type = 'tenant' AND g.role_tenant_id = p_tenant_id
      AND g.scope_type = 'tenant' AND g.scope_id = p_tenant_id::TEXT
      AND g.effect = 'deny' AND g.revoked_at IS NULL
      AND g.starts_at <= v_now AND (g.expires_at IS NULL OR g.expires_at > v_now)
  ) THEN
    RAISE EXCEPTION 'Membership management permission required' USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_target
  FROM public.memberships
  WHERE id = p_membership_id AND tenant_id = p_tenant_id;
  IF NOT FOUND OR v_target.user_id = v_actor THEN
    RAISE EXCEPTION 'Target membership is unavailable' USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_existing
  FROM public.audit_events
  WHERE tenant_id = p_tenant_id
    AND source = 'tenant-membership-lifecycle'
    AND idempotency_key = 'membership-' || p_transition || ':' || p_idempotency_key::TEXT
  FOR UPDATE;
  IF FOUND THEN
    IF v_existing.actor_id <> v_actor OR v_existing.resource_id <> p_membership_id
       OR v_existing.reason <> p_reason
       OR v_existing.before_redacted ->> 'version' <> p_expected_version::TEXT
       OR v_existing.after_redacted ->> 'status' <> v_next_status THEN
      RAISE EXCEPTION 'Idempotency key payload mismatch' USING ERRCODE = '23505';
    END IF;
    RETURN pg_catalog.jsonb_build_object(
      'membershipId', p_membership_id,
      'status', v_next_status,
      'version', v_existing.after_redacted ->> 'version',
      'correlationId', v_existing.correlation_id,
      'idempotentReplay', TRUE
    );
  END IF;

  IF v_target.status <> v_expected_status THEN
    RAISE EXCEPTION 'Membership transition is invalid' USING ERRCODE = '22023';
  END IF;
  IF v_target.version <> p_expected_version THEN
    RAISE EXCEPTION 'Membership version is stale' USING ERRCODE = '40001';
  END IF;

  IF p_transition = 'suspend' AND EXISTS (
    SELECT 1
    FROM public.access_grants AS target_grant
    JOIN public.roles AS target_role ON target_role.id = target_grant.role_id
      AND target_role.tenant_id = p_tenant_id AND target_role.scope_type = 'tenant'
      AND target_role.key = 'tenant_admin' AND target_role.status = 'active'
    WHERE target_grant.subject_id = v_target.user_id
      AND target_grant.tenant_id = p_tenant_id
      AND target_grant.role_scope_type = 'tenant' AND target_grant.role_tenant_id = p_tenant_id
      AND target_grant.scope_type = 'tenant' AND target_grant.scope_id = p_tenant_id::TEXT
      AND target_grant.effect = 'allow' AND target_grant.revoked_at IS NULL
      AND target_grant.starts_at <= v_now
      AND (target_grant.expires_at IS NULL OR target_grant.expires_at > v_now)
  ) AND NOT EXISTS (
    SELECT 1
    FROM public.memberships AS other_membership
    JOIN public.access_grants AS other_grant ON other_grant.subject_id = other_membership.user_id
      AND other_grant.tenant_id = p_tenant_id
      AND other_grant.role_scope_type = 'tenant' AND other_grant.role_tenant_id = p_tenant_id
      AND other_grant.scope_type = 'tenant' AND other_grant.scope_id = p_tenant_id::TEXT
      AND other_grant.effect = 'allow' AND other_grant.revoked_at IS NULL
      AND other_grant.starts_at <= v_now
      AND (other_grant.expires_at IS NULL OR other_grant.expires_at > v_now)
    JOIN public.roles AS other_role ON other_role.id = other_grant.role_id
      AND other_role.tenant_id = p_tenant_id AND other_role.scope_type = 'tenant'
      AND other_role.key = 'tenant_admin' AND other_role.status = 'active'
    WHERE other_membership.tenant_id = p_tenant_id
      AND other_membership.status = 'active'
      AND other_membership.user_id <> v_target.user_id
  ) THEN
    RAISE EXCEPTION 'The last active Tenant Admin cannot be suspended' USING ERRCODE = '23514';
  END IF;

  v_before := pg_catalog.jsonb_build_object('status', v_target.status, 'version', v_target.version::TEXT);
  UPDATE public.memberships
  SET status = v_next_status,
      suspended_at = CASE WHEN p_transition = 'suspend' THEN v_now ELSE NULL END,
      version = version + 1
  WHERE id = p_membership_id AND tenant_id = p_tenant_id AND version = p_expected_version
  RETURNING * INTO v_target;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Membership version is stale' USING ERRCODE = '40001';
  END IF;

  v_after := pg_catalog.jsonb_build_object('status', v_target.status, 'version', v_target.version::TEXT);
  INSERT INTO public.audit_events (
    tenant_id, actor_id, actor_type, action, resource_type, resource_id,
    correlation_id, reason, before_redacted, after_redacted, source, schema_version, idempotency_key
  ) VALUES (
    p_tenant_id, v_actor, 'user', 'membership.' || p_transition, 'membership', p_membership_id,
    v_correlation_id, p_reason, v_before, v_after,
    'tenant-membership-lifecycle', '1', 'membership-' || p_transition || ':' || p_idempotency_key::TEXT
  );

  RETURN pg_catalog.jsonb_build_object(
    'membershipId', p_membership_id,
    'status', v_target.status,
    'version', v_target.version::TEXT,
    'correlationId', v_correlation_id,
    'idempotentReplay', FALSE
  );
END;
$function$;

REVOKE ALL ON FUNCTION private.transition_tenant_membership(UUID, UUID, TEXT, TEXT, BIGINT, UUID) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION private.transition_tenant_membership(UUID, UUID, TEXT, TEXT, BIGINT, UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.transition_tenant_membership(
  p_tenant_id UUID,
  p_membership_id UUID,
  p_transition TEXT,
  p_reason TEXT,
  p_expected_version BIGINT,
  p_idempotency_key UUID
)
RETURNS JSONB
LANGUAGE SQL
SECURITY INVOKER
SET search_path = ''
AS $function$
  SELECT private.transition_tenant_membership(
    p_tenant_id, p_membership_id, p_transition, p_reason, p_expected_version, p_idempotency_key
  );
$function$;

REVOKE ALL ON FUNCTION public.transition_tenant_membership(UUID, UUID, TEXT, TEXT, BIGINT, UUID) FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.transition_tenant_membership(UUID, UUID, TEXT, TEXT, BIGINT, UUID) TO authenticated;

-- F1-05 / F1-10: revoke a Tenant membership and all grants in that Tenant as
-- one authorized, serialized and audited state transition.

CREATE OR REPLACE FUNCTION private.list_tenant_members_with_version(p_tenant_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  v_directory JSONB;
  v_members JSONB;
BEGIN
  -- The existing directory RPC performs the exact-scope membership.view and
  -- deny checks. This wrapper only adds the optimistic concurrency token.
  v_directory := private.list_tenant_members(p_tenant_id);

  SELECT COALESCE(
    pg_catalog.jsonb_agg(
      pg_catalog.jsonb_set(item.member, '{version}', pg_catalog.to_jsonb(m.version::TEXT), TRUE)
      ORDER BY m.created_at, m.id
    ),
    '[]'::JSONB
  )
  INTO v_members
  FROM pg_catalog.jsonb_array_elements(v_directory -> 'members') AS item(member)
  JOIN public.memberships AS m
    ON m.id = (item.member ->> 'membershipId')::UUID
    AND m.tenant_id = p_tenant_id;

  RETURN pg_catalog.jsonb_build_object('members', v_members);
END;
$function$;

REVOKE ALL ON FUNCTION private.list_tenant_members_with_version(UUID) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION private.list_tenant_members_with_version(UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.list_tenant_members(p_tenant_id UUID)
RETURNS JSONB
LANGUAGE SQL
SECURITY INVOKER
SET search_path = ''
AS $function$
  SELECT private.list_tenant_members_with_version(p_tenant_id);
$function$;

REVOKE ALL ON FUNCTION public.list_tenant_members(UUID) FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.list_tenant_members(UUID) TO authenticated;

CREATE OR REPLACE FUNCTION private.revoke_tenant_membership(
  p_tenant_id UUID,
  p_membership_id UUID,
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
  v_actor_membership public.memberships%ROWTYPE;
  v_target public.memberships%ROWTYPE;
  v_existing public.audit_events%ROWTYPE;
  v_before JSONB;
  v_after JSONB;
  v_correlation_id UUID := gen_random_uuid();
BEGIN
  IF v_actor IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;
  IF p_tenant_id IS NULL OR p_membership_id IS NULL OR p_expected_version IS NULL
     OR p_expected_version < 1 OR p_idempotency_key IS NULL
     OR p_reason IS NULL OR p_reason <> pg_catalog.btrim(p_reason)
     OR pg_catalog.char_length(p_reason) NOT BETWEEN 1 AND 1000 THEN
    RAISE EXCEPTION 'Invalid membership revocation' USING ERRCODE = '22023';
  END IF;

  SELECT * INTO v_tenant
  FROM public.tenants
  WHERE id = p_tenant_id
  FOR UPDATE;
  IF NOT FOUND OR v_tenant.status <> 'active' THEN
    RAISE EXCEPTION 'Tenant is unavailable' USING ERRCODE = '42501';
  END IF;

  -- Serialize access changes in the Tenant and use a stable lock order. This
  -- also protects the last-administrator invariant from concurrent revokes.
  PERFORM m.id
  FROM public.memberships AS m
  WHERE m.tenant_id = p_tenant_id
  ORDER BY m.id
  FOR UPDATE;

  SELECT * INTO v_actor_membership
  FROM public.memberships
  WHERE tenant_id = p_tenant_id AND user_id = v_actor AND status = 'active';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Active membership required' USING ERRCODE = '42501';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.access_grants AS g
    JOIN public.roles AS r ON r.id = g.role_id
      AND r.scope_type = 'tenant' AND r.tenant_id = p_tenant_id AND r.status = 'active'
    JOIN public.role_permissions AS rp ON rp.role_id = r.id
      AND rp.permission_key = 'membership.revoke'
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
      AND rp.permission_key = 'membership.revoke'
    WHERE g.subject_id = v_actor AND g.tenant_id = p_tenant_id
      AND g.role_scope_type = 'tenant' AND g.role_tenant_id = p_tenant_id
      AND g.scope_type = 'tenant' AND g.scope_id = p_tenant_id::TEXT
      AND g.effect = 'deny' AND g.revoked_at IS NULL
      AND g.starts_at <= v_now AND (g.expires_at IS NULL OR g.expires_at > v_now)
  ) THEN
    RAISE EXCEPTION 'Membership revocation permission required' USING ERRCODE = '42501';
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
    AND source = 'tenant-membership-revocation'
    AND idempotency_key = 'membership-revoke:' || p_idempotency_key::TEXT
  FOR UPDATE;
  IF FOUND THEN
    IF v_existing.actor_id <> v_actor OR v_existing.resource_id <> p_membership_id
       OR v_existing.reason <> p_reason
       OR v_existing.before_redacted ->> 'version' <> p_expected_version::TEXT THEN
      RAISE EXCEPTION 'Idempotency key payload mismatch' USING ERRCODE = '23505';
    END IF;
    RETURN pg_catalog.jsonb_build_object(
      'membershipId', p_membership_id,
      'status', 'revoked',
      'version', v_existing.after_redacted ->> 'version',
      'correlationId', v_existing.correlation_id,
      'idempotentReplay', TRUE
    );
  END IF;

  IF v_target.status NOT IN ('active', 'suspended') THEN
    RAISE EXCEPTION 'Membership transition is invalid' USING ERRCODE = '22023';
  END IF;
  IF v_target.version <> p_expected_version THEN
    RAISE EXCEPTION 'Membership version is stale' USING ERRCODE = '40001';
  END IF;

  IF v_target.status = 'active' AND EXISTS (
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
    RAISE EXCEPTION 'The last active Tenant Admin cannot be revoked' USING ERRCODE = '23514';
  END IF;

  v_before := pg_catalog.jsonb_build_object('status', v_target.status, 'version', v_target.version::TEXT);
  UPDATE public.memberships
  SET status = 'revoked', suspended_at = NULL, revoked_at = v_now, version = version + 1
  WHERE id = p_membership_id AND tenant_id = p_tenant_id AND version = p_expected_version
  RETURNING * INTO v_target;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Membership version is stale' USING ERRCODE = '40001';
  END IF;

  UPDATE public.access_grants
  SET revoked_at = v_now, revoked_by = v_actor, revocation_reason = p_reason, version = version + 1
  WHERE tenant_id = p_tenant_id AND subject_id = v_target.user_id AND revoked_at IS NULL;

  v_after := pg_catalog.jsonb_build_object('status', 'revoked', 'version', v_target.version::TEXT);
  INSERT INTO public.audit_events (
    tenant_id, actor_id, actor_type, action, resource_type, resource_id,
    correlation_id, reason, before_redacted, after_redacted, source, schema_version, idempotency_key
  ) VALUES (
    p_tenant_id, v_actor, 'user', 'membership.revoke', 'membership', p_membership_id,
    v_correlation_id, p_reason, v_before, v_after,
    'tenant-membership-revocation', '1', 'membership-revoke:' || p_idempotency_key::TEXT
  );

  RETURN pg_catalog.jsonb_build_object(
    'membershipId', p_membership_id,
    'status', 'revoked',
    'version', v_target.version::TEXT,
    'correlationId', v_correlation_id,
    'idempotentReplay', FALSE
  );
END;
$function$;

REVOKE ALL ON FUNCTION private.revoke_tenant_membership(UUID, UUID, TEXT, BIGINT, UUID) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION private.revoke_tenant_membership(UUID, UUID, TEXT, BIGINT, UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.revoke_tenant_membership(
  p_tenant_id UUID,
  p_membership_id UUID,
  p_reason TEXT,
  p_expected_version BIGINT,
  p_idempotency_key UUID
)
RETURNS JSONB
LANGUAGE SQL
SECURITY INVOKER
SET search_path = ''
AS $function$
  SELECT private.revoke_tenant_membership(
    p_tenant_id, p_membership_id, p_reason, p_expected_version, p_idempotency_key
  );
$function$;

REVOKE ALL ON FUNCTION public.revoke_tenant_membership(UUID, UUID, TEXT, BIGINT, UUID) FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.revoke_tenant_membership(UUID, UUID, TEXT, BIGINT, UUID) TO authenticated;

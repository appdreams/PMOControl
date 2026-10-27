-- Distinguish the bootstrap first-admin invite from future ordinary member invitations.
ALTER TABLE public.tenant_invitations
  ADD COLUMN invitation_kind TEXT NOT NULL DEFAULT 'tenant_member',
  ADD CONSTRAINT tenant_invitations_kind_allowed CHECK (invitation_kind IN ('tenant_member', 'first_admin'));

-- Keep bootstrap issuance isolated from generic invitation rows.
CREATE OR REPLACE FUNCTION private.create_first_tenant_admin_invitation(
  p_tenant_id UUID,
  p_email TEXT,
  p_token_hash BYTEA,
  p_reason TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  v_actor UUID := auth.uid();
  v_now TIMESTAMPTZ := pg_catalog.now();
  v_email TEXT := pg_catalog.lower(pg_catalog.btrim(p_email));
  v_tenant public.tenants%ROWTYPE;
  v_role_id UUID;
  v_invitation_id UUID;
  v_correlation_id UUID := gen_random_uuid();
  v_old public.tenant_invitations%ROWTYPE;
BEGIN
  IF v_actor IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;
  IF p_tenant_id IS NULL OR p_token_hash IS NULL OR pg_catalog.octet_length(p_token_hash) <> 32
     OR v_email IS NULL OR v_email !~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'
     OR pg_catalog.char_length(v_email) > 320
     OR p_reason IS NULL OR p_reason <> pg_catalog.btrim(p_reason)
     OR pg_catalog.char_length(p_reason) NOT BETWEEN 1 AND 1000 THEN
    RAISE EXCEPTION 'Invalid invitation request' USING ERRCODE = '22023';
  END IF;

  SELECT * INTO v_tenant FROM public.tenants WHERE id = p_tenant_id FOR UPDATE;
  IF NOT FOUND OR v_tenant.created_by <> v_actor OR v_tenant.status <> 'active' THEN
    RAISE EXCEPTION 'Invitation is not permitted' USING ERRCODE = '42501';
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

  IF EXISTS (SELECT 1 FROM public.memberships WHERE tenant_id = p_tenant_id AND status = 'active')
     OR EXISTS (
       SELECT 1 FROM public.tenant_invitations
       WHERE tenant_id = p_tenant_id AND invitation_kind = 'first_admin' AND accepted_at IS NOT NULL
     ) THEN
    RAISE EXCEPTION 'The first administrator has already been activated' USING ERRCODE = '23505';
  END IF;

  SELECT id INTO v_role_id FROM public.roles
  WHERE tenant_id = p_tenant_id AND key = 'tenant_admin'
    AND scope_type = 'tenant' AND status = 'active';
  IF v_role_id IS NULL THEN
    RAISE EXCEPTION 'Tenant administrator role is unavailable' USING ERRCODE = '22023';
  END IF;

  FOR v_old IN
    UPDATE public.tenant_invitations
    SET revoked_at = v_now, version = version + 1
    WHERE tenant_id = p_tenant_id AND invitation_kind = 'first_admin' AND accepted_at IS NULL AND revoked_at IS NULL
    RETURNING *
  LOOP
    INSERT INTO public.audit_events (
      tenant_id, actor_id, actor_type, action, resource_type, resource_id,
      correlation_id, reason, after_redacted, source, schema_version, idempotency_key
    ) VALUES (
      p_tenant_id, v_actor, 'user', 'tenant.invitation.revoke', 'tenant_invitation', v_old.id,
      v_correlation_id, p_reason, pg_catalog.jsonb_build_object('state', 'revoked', 'firstAdministrator', TRUE),
      'first-admin-invitation', '1', 'revoke:' || v_old.id::TEXT
    );
  END LOOP;

  INSERT INTO public.tenant_invitations (
    tenant_id, invitation_kind, email_normalized, grant_payload, token_hash, expires_at, created_by
  ) VALUES (
    p_tenant_id, 'first_admin', v_email,
    pg_catalog.jsonb_build_object('schema_version', '1', 'grants', pg_catalog.jsonb_build_array(
      pg_catalog.jsonb_build_object('role_id', v_role_id, 'scope_type', 'tenant', 'scope_id', p_tenant_id::TEXT)
    )),
    p_token_hash, v_now + INTERVAL '7 days', v_actor
  ) RETURNING id INTO v_invitation_id;

  INSERT INTO public.audit_events (
    tenant_id, actor_id, actor_type, action, resource_type, resource_id,
    correlation_id, reason, after_redacted, source, schema_version, idempotency_key
  ) VALUES (
    p_tenant_id, v_actor, 'user', 'tenant.invitation.create', 'tenant_invitation', v_invitation_id,
    v_correlation_id, p_reason,
    pg_catalog.jsonb_build_object('roleKey', 'tenant_admin', 'expiresAt', v_now + INTERVAL '7 days'),
    'first-admin-invitation', '1', 'create:' || v_invitation_id::TEXT
  );

  RETURN pg_catalog.jsonb_build_object(
    'invitationId', v_invitation_id,
    'tenantId', p_tenant_id,
    'expiresAt', v_now + INTERVAL '7 days',
    'correlationId', v_correlation_id
  );
END;
$function$;

-- Only bootstrap invitations are accepted by the first-administrator endpoint.
CREATE OR REPLACE FUNCTION private.accept_tenant_invitation(p_token_hash BYTEA)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  v_actor UUID := auth.uid();
  v_now TIMESTAMPTZ := pg_catalog.now();
  v_email TEXT;
  v_invitation public.tenant_invitations%ROWTYPE;
  v_tenant public.tenants%ROWTYPE;
  v_role_id UUID;
  v_membership_id UUID;
  v_membership_status TEXT;
  v_correlation_id UUID := gen_random_uuid();
BEGIN
  IF v_actor IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;
  IF p_token_hash IS NULL OR pg_catalog.octet_length(p_token_hash) <> 32 THEN
    RAISE EXCEPTION 'Invalid invitation' USING ERRCODE = '22023';
  END IF;

  SELECT pg_catalog.lower(pg_catalog.btrim(u.email)) INTO v_email
  FROM auth.users AS u
  WHERE u.id = v_actor AND u.email_confirmed_at IS NOT NULL;
  IF v_email IS NULL THEN
    RAISE EXCEPTION 'Verified email required' USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_invitation FROM public.tenant_invitations
  WHERE token_hash = p_token_hash AND invitation_kind = 'first_admin' FOR UPDATE;
  IF NOT FOUND OR v_invitation.accepted_at IS NOT NULL OR v_invitation.revoked_at IS NOT NULL
     OR v_invitation.expires_at <= v_now OR v_invitation.email_normalized <> v_email THEN
    RAISE EXCEPTION 'Invitation is invalid or unavailable' USING ERRCODE = '22023';
  END IF;

  SELECT * INTO v_tenant FROM public.tenants WHERE id = v_invitation.tenant_id FOR UPDATE;
  IF NOT FOUND OR v_tenant.status <> 'active' OR v_tenant.created_by <> v_invitation.created_by THEN
    RAISE EXCEPTION 'Invitation is invalid or unavailable' USING ERRCODE = '22023';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.access_grants AS g
    JOIN public.roles AS r ON r.id = g.role_id
      AND r.scope_type = 'platform' AND r.tenant_id IS NULL AND r.status = 'active'
    JOIN public.role_permissions AS rp ON rp.role_id = r.id
    WHERE g.subject_id = v_invitation.created_by AND g.tenant_id IS NULL
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
    WHERE g.subject_id = v_invitation.created_by AND g.tenant_id IS NULL
      AND g.role_scope_type = 'platform' AND g.role_tenant_id IS NULL
      AND g.scope_type = 'platform' AND g.scope_id = 'platform'
      AND g.effect = 'deny' AND g.revoked_at IS NULL
      AND g.starts_at <= v_now AND (g.expires_at IS NULL OR g.expires_at > v_now)
      AND rp.permission_key = 'tenant.lifecycle.create'
  ) THEN
    RAISE EXCEPTION 'Invitation issuer is no longer authorized' USING ERRCODE = '42501';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.memberships
    WHERE tenant_id = v_invitation.tenant_id AND status = 'active' AND user_id <> v_actor
  ) THEN
    RAISE EXCEPTION 'The first administrator has already been activated' USING ERRCODE = '23505';
  END IF;

  SELECT r.id INTO v_role_id FROM public.roles AS r
  WHERE r.tenant_id = v_invitation.tenant_id AND r.key = 'tenant_admin'
    AND r.scope_type = 'tenant' AND r.status = 'active'
    AND v_invitation.grant_payload -> 'grants' -> 0 ->> 'role_id' = r.id::TEXT
    AND v_invitation.grant_payload -> 'grants' -> 0 ->> 'scope_type' = 'tenant'
    AND v_invitation.grant_payload -> 'grants' -> 0 ->> 'scope_id' = v_invitation.tenant_id::TEXT;
  IF v_role_id IS NULL THEN
    RAISE EXCEPTION 'Invitation role is invalid' USING ERRCODE = '22023';
  END IF;

  SELECT id, status INTO v_membership_id, v_membership_status FROM public.memberships
  WHERE tenant_id = v_invitation.tenant_id AND user_id = v_actor FOR UPDATE;
  IF v_membership_status = 'active' THEN
    RAISE EXCEPTION 'Membership is already active' USING ERRCODE = '23505';
  ELSIF v_membership_status = 'suspended' THEN
    RAISE EXCEPTION 'A suspended membership cannot be reactivated by invitation' USING ERRCODE = '42501';
  ELSIF v_membership_status = 'revoked' THEN
    UPDATE public.memberships SET status = 'active', activated_at = v_now,
      suspended_at = NULL, revoked_at = NULL, version = version + 1
    WHERE id = v_membership_id RETURNING id INTO v_membership_id;
  ELSE
    INSERT INTO public.memberships (tenant_id, user_id, status, activated_at)
    VALUES (v_invitation.tenant_id, v_actor, 'active', v_now)
    RETURNING id INTO v_membership_id;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.access_grants AS g
    WHERE g.tenant_id = v_invitation.tenant_id AND g.subject_id = v_actor
      AND g.role_id = v_role_id AND g.scope_type = 'tenant'
      AND g.scope_id = v_invitation.tenant_id::TEXT AND g.effect = 'allow'
      AND g.revoked_at IS NULL AND (g.expires_at IS NULL OR g.expires_at > v_now)
  ) THEN
    INSERT INTO public.access_grants (
      tenant_id, subject_id, role_id, role_scope_type, role_tenant_id,
      scope_type, scope_id, effect, granted_by, reason
    ) VALUES (
      v_invitation.tenant_id, v_actor, v_role_id, 'tenant', v_invitation.tenant_id,
      'tenant', v_invitation.tenant_id::TEXT, 'allow', v_invitation.created_by,
      'First Tenant administrator invitation accepted'
    );
  END IF;

  UPDATE public.tenant_invitations SET accepted_at = v_now, accepted_by = v_actor, version = version + 1
  WHERE id = v_invitation.id;

  INSERT INTO public.audit_events (
    tenant_id, actor_id, actor_type, action, resource_type, resource_id,
    correlation_id, reason, after_redacted, source, schema_version, idempotency_key
  ) VALUES (
    v_invitation.tenant_id, v_actor, 'user', 'membership.grant', 'membership', v_membership_id,
    v_correlation_id, 'First Tenant administrator invitation accepted',
    pg_catalog.jsonb_build_object('invitationId', v_invitation.id, 'roleKey', 'tenant_admin'),
    'tenant-invitation-acceptance', '1', v_invitation.id::TEXT
  );

  RETURN pg_catalog.jsonb_build_object(
    'tenantId', v_invitation.tenant_id,
    'tenantName', v_tenant.display_name,
    'membershipId', v_membership_id,
    'correlationId', v_correlation_id
  );
END;
$function$;


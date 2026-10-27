-- Ordinary Tenant-member invitations use the existing hash-only token table.
-- Both issuance and acceptance revalidate delegation inside the database.

CREATE OR REPLACE FUNCTION private.create_tenant_member_invitation(
  p_tenant_id UUID,
  p_email TEXT,
  p_role_key TEXT,
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
  v_role public.roles%ROWTYPE;
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
     OR p_role_key IS NULL OR p_role_key !~ '^[a-z][a-z0-9_.-]{1,79}$'
     OR p_reason IS NULL OR p_reason <> pg_catalog.btrim(p_reason)
     OR pg_catalog.char_length(p_reason) NOT BETWEEN 1 AND 1000 THEN
    RAISE EXCEPTION 'Invalid invitation request' USING ERRCODE = '22023';
  END IF;

  IF EXISTS (
    SELECT 1 FROM auth.users AS u
    WHERE u.id = v_actor AND u.email_confirmed_at IS NOT NULL
      AND pg_catalog.lower(pg_catalog.btrim(u.email)) = v_email
  ) THEN
    RAISE EXCEPTION 'Self invitation is not permitted' USING ERRCODE = '22023';
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

  IF NOT EXISTS (
    SELECT 1 FROM public.access_grants AS g
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
    SELECT 1 FROM public.access_grants AS g
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

  SELECT * INTO v_role FROM public.roles
  WHERE tenant_id = p_tenant_id AND key = p_role_key
    AND scope_type = 'tenant' AND is_system AND status = 'active';
  IF NOT FOUND OR NOT EXISTS (
    SELECT 1 FROM public.role_permissions WHERE role_id = v_role.id
  ) OR EXISTS (
    SELECT 1 FROM public.role_permissions AS target_permission
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
    SELECT 1 FROM public.role_permissions AS target_permission
    WHERE target_permission.role_id = v_role.id
      AND NOT EXISTS (
        SELECT 1
        FROM public.access_grants AS issuer_grant
        JOIN public.roles AS issuer_role ON issuer_role.id = issuer_grant.role_id
          AND issuer_role.scope_type = 'tenant' AND issuer_role.tenant_id = p_tenant_id
          AND issuer_role.status = 'active'
        JOIN public.role_permissions AS issuer_permission
          ON issuer_permission.role_id = issuer_role.id
          AND issuer_permission.permission_key = target_permission.permission_key
        WHERE issuer_grant.subject_id = v_actor AND issuer_grant.tenant_id = p_tenant_id
          AND issuer_grant.role_scope_type = 'tenant' AND issuer_grant.role_tenant_id = p_tenant_id
          AND issuer_grant.scope_type = 'tenant' AND issuer_grant.scope_id = p_tenant_id::TEXT
          AND issuer_grant.effect = 'allow' AND issuer_grant.revoked_at IS NULL
          AND issuer_grant.starts_at <= v_now
          AND (issuer_grant.expires_at IS NULL OR issuer_grant.expires_at > v_now)
          AND NOT EXISTS (
            SELECT 1 FROM public.access_grants AS deny_grant
            JOIN public.roles AS deny_role ON deny_role.id = deny_grant.role_id
              AND deny_role.scope_type = 'tenant' AND deny_role.tenant_id = p_tenant_id
              AND deny_role.status = 'active'
            JOIN public.role_permissions AS denied_permission
              ON denied_permission.role_id = deny_role.id
              AND denied_permission.permission_key = target_permission.permission_key
            WHERE deny_grant.subject_id = v_actor AND deny_grant.tenant_id = p_tenant_id
              AND deny_grant.role_scope_type = 'tenant' AND deny_grant.role_tenant_id = p_tenant_id
              AND deny_grant.scope_type = 'tenant' AND deny_grant.scope_id = p_tenant_id::TEXT
              AND deny_grant.effect = 'deny' AND deny_grant.revoked_at IS NULL
              AND deny_grant.starts_at <= v_now
              AND (deny_grant.expires_at IS NULL OR deny_grant.expires_at > v_now)
          )
      )
  ) THEN
    RAISE EXCEPTION 'Role exceeds the issuer delegation ceiling' USING ERRCODE = '42501';
  END IF;

  FOR v_old IN
    SELECT * FROM public.tenant_invitations
    WHERE tenant_id = p_tenant_id AND invitation_kind = 'tenant_member'
      AND email_normalized = v_email AND accepted_at IS NULL AND revoked_at IS NULL
    ORDER BY id FOR UPDATE
  LOOP
    UPDATE public.tenant_invitations SET revoked_at = v_now, version = version + 1
    WHERE id = v_old.id;
    INSERT INTO public.audit_events (
      tenant_id, actor_id, actor_type, action, resource_type, resource_id,
      correlation_id, reason, after_redacted, source, schema_version, idempotency_key
    ) VALUES (
      p_tenant_id, v_actor, 'user', 'tenant.invitation.revoke', 'tenant_invitation', v_old.id,
      v_correlation_id, p_reason, pg_catalog.jsonb_build_object('state', 'revoked'),
      'tenant-member-invitation', '1', 'revoke:' || v_old.id::TEXT
    );
  END LOOP;

  INSERT INTO public.tenant_invitations (
    tenant_id, invitation_kind, email_normalized, grant_payload, token_hash, expires_at, created_by
  ) VALUES (
    p_tenant_id, 'tenant_member', v_email,
    pg_catalog.jsonb_build_object('schema_version', '1', 'grants', pg_catalog.jsonb_build_array(
      pg_catalog.jsonb_build_object('role_id', v_role.id, 'scope_type', 'tenant', 'scope_id', p_tenant_id::TEXT)
    )),
    p_token_hash, v_now + INTERVAL '7 days', v_actor
  ) RETURNING id INTO v_invitation_id;

  INSERT INTO public.audit_events (
    tenant_id, actor_id, actor_type, action, resource_type, resource_id,
    correlation_id, reason, after_redacted, source, schema_version, idempotency_key
  ) VALUES (
    p_tenant_id, v_actor, 'user', 'tenant.invitation.create', 'tenant_invitation', v_invitation_id,
    v_correlation_id, p_reason,
    pg_catalog.jsonb_build_object('roleKey', v_role.key, 'expiresAt', v_now + INTERVAL '7 days'),
    'tenant-member-invitation', '1', 'create:' || v_invitation_id::TEXT
  );

  RETURN pg_catalog.jsonb_build_object(
    'invitationId', v_invitation_id,
    'tenantId', p_tenant_id,
    'roleKey', v_role.key,
    'expiresAt', v_now + INTERVAL '7 days',
    'correlationId', v_correlation_id
  );
END;
$function$;

CREATE OR REPLACE FUNCTION private.accept_tenant_member_invitation(p_token_hash BYTEA)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  v_actor UUID := auth.uid();
  v_now TIMESTAMPTZ := pg_catalog.now();
  v_email TEXT;
  v_invitation_id UUID;
  v_tenant_id UUID;
  v_issuer_id UUID;
  v_tenant public.tenants%ROWTYPE;
  v_invitation public.tenant_invitations%ROWTYPE;
  v_role public.roles%ROWTYPE;
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
  FROM auth.users AS u WHERE u.id = v_actor AND u.email_confirmed_at IS NOT NULL;
  IF v_email IS NULL THEN
    RAISE EXCEPTION 'Verified email required' USING ERRCODE = '42501';
  END IF;

  SELECT id, tenant_id, created_by INTO v_invitation_id, v_tenant_id, v_issuer_id
  FROM public.tenant_invitations
  WHERE token_hash = p_token_hash AND invitation_kind = 'tenant_member';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Invitation is invalid or unavailable' USING ERRCODE = '22023';
  END IF;

  SELECT * INTO v_tenant FROM public.tenants WHERE id = v_tenant_id FOR UPDATE;
  IF NOT FOUND OR v_tenant.status <> 'active' THEN
    RAISE EXCEPTION 'Invitation is invalid or unavailable' USING ERRCODE = '22023';
  END IF;

  PERFORM 1 FROM public.memberships
  WHERE tenant_id = v_tenant_id AND user_id = v_issuer_id AND status = 'active'
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Invitation issuer is no longer authorized' USING ERRCODE = '42501';
  END IF;
  PERFORM 1 FROM public.memberships
  WHERE tenant_id = v_tenant_id AND user_id = v_actor
  FOR UPDATE;

  SELECT * INTO v_invitation FROM public.tenant_invitations
  WHERE id = v_invitation_id AND token_hash = p_token_hash
    AND invitation_kind = 'tenant_member' FOR UPDATE;
  IF NOT FOUND OR v_invitation.created_by <> v_issuer_id
     OR v_invitation.accepted_at IS NOT NULL OR v_invitation.revoked_at IS NOT NULL
     OR v_invitation.expires_at <= v_now OR v_invitation.email_normalized <> v_email THEN
    RAISE EXCEPTION 'Invitation is invalid or unavailable' USING ERRCODE = '22023';
  END IF;

  IF v_invitation.grant_payload ->> 'schema_version' <> '1'
     OR pg_catalog.jsonb_typeof(v_invitation.grant_payload -> 'grants') <> 'array'
     OR pg_catalog.jsonb_array_length(v_invitation.grant_payload -> 'grants') <> 1
     OR pg_catalog.jsonb_object_length(v_invitation.grant_payload -> 'grants' -> 0) <> 3
     OR v_invitation.grant_payload -> 'grants' -> 0 ->> 'scope_type' <> 'tenant'
     OR v_invitation.grant_payload -> 'grants' -> 0 ->> 'scope_id' <> v_tenant_id::TEXT
     OR coalesce(v_invitation.grant_payload -> 'grants' -> 0 ->> 'role_id', '')
       !~ '^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$' THEN
    RAISE EXCEPTION 'Invitation role is invalid' USING ERRCODE = '22023';
  END IF;
  v_role_id := (v_invitation.grant_payload -> 'grants' -> 0 ->> 'role_id')::UUID;

  IF NOT EXISTS (
    SELECT 1 FROM public.access_grants AS g
    JOIN public.roles AS r ON r.id = g.role_id AND r.tenant_id = v_tenant_id
      AND r.scope_type = 'tenant' AND r.status = 'active'
    JOIN public.role_permissions AS rp ON rp.role_id = r.id AND rp.permission_key = 'membership.invite'
    WHERE g.subject_id = v_issuer_id AND g.tenant_id = v_tenant_id
      AND g.role_scope_type = 'tenant' AND g.role_tenant_id = v_tenant_id
      AND g.scope_type = 'tenant' AND g.scope_id = v_tenant_id::TEXT
      AND g.effect = 'allow' AND g.revoked_at IS NULL AND g.starts_at <= v_now
      AND (g.expires_at IS NULL OR g.expires_at > v_now)
  ) OR EXISTS (
    SELECT 1 FROM public.access_grants AS g
    JOIN public.roles AS r ON r.id = g.role_id AND r.tenant_id = v_tenant_id
      AND r.scope_type = 'tenant' AND r.status = 'active'
    JOIN public.role_permissions AS rp ON rp.role_id = r.id AND rp.permission_key = 'membership.invite'
    WHERE g.subject_id = v_issuer_id AND g.tenant_id = v_tenant_id
      AND g.role_scope_type = 'tenant' AND g.role_tenant_id = v_tenant_id
      AND g.scope_type = 'tenant' AND g.scope_id = v_tenant_id::TEXT
      AND g.effect = 'deny' AND g.revoked_at IS NULL AND g.starts_at <= v_now
      AND (g.expires_at IS NULL OR g.expires_at > v_now)
  ) THEN
    RAISE EXCEPTION 'Invitation issuer is no longer authorized' USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_role FROM public.roles
  WHERE id = v_role_id AND tenant_id = v_tenant_id AND scope_type = 'tenant'
    AND is_system AND status = 'active';
  IF NOT FOUND OR NOT EXISTS (
    SELECT 1 FROM public.role_permissions WHERE role_id = v_role_id
  ) OR EXISTS (
    SELECT 1 FROM public.role_permissions AS target_permission
    WHERE target_permission.role_id = v_role_id
      AND NOT EXISTS (
        SELECT 1 FROM private.permission_scope_catalog AS scope_catalog
        WHERE scope_catalog.catalog_version = 'rbac-v1'
          AND scope_catalog.permission_key = target_permission.permission_key
          AND scope_catalog.scope_types @> ARRAY['tenant']::TEXT[]
      )
  ) OR EXISTS (
    SELECT 1 FROM public.role_permissions AS target_permission
    WHERE target_permission.role_id = v_role_id
      AND NOT EXISTS (
        SELECT 1 FROM public.access_grants AS issuer_grant
        JOIN public.roles AS issuer_role ON issuer_role.id = issuer_grant.role_id
          AND issuer_role.tenant_id = v_tenant_id AND issuer_role.scope_type = 'tenant'
          AND issuer_role.status = 'active'
        JOIN public.role_permissions AS issuer_permission
          ON issuer_permission.role_id = issuer_role.id
          AND issuer_permission.permission_key = target_permission.permission_key
        WHERE issuer_grant.subject_id = v_issuer_id
          AND issuer_grant.tenant_id = v_tenant_id
          AND issuer_grant.role_scope_type = 'tenant' AND issuer_grant.role_tenant_id = v_tenant_id
          AND issuer_grant.scope_type = 'tenant' AND issuer_grant.scope_id = v_tenant_id::TEXT
          AND issuer_grant.effect = 'allow' AND issuer_grant.revoked_at IS NULL
          AND issuer_grant.starts_at <= v_now
          AND (issuer_grant.expires_at IS NULL OR issuer_grant.expires_at > v_now)
          AND NOT EXISTS (
            SELECT 1 FROM public.access_grants AS deny_grant
            JOIN public.roles AS deny_role ON deny_role.id = deny_grant.role_id
              AND deny_role.tenant_id = v_tenant_id AND deny_role.scope_type = 'tenant'
              AND deny_role.status = 'active'
            JOIN public.role_permissions AS denied_permission
              ON denied_permission.role_id = deny_role.id
              AND denied_permission.permission_key = target_permission.permission_key
            WHERE deny_grant.subject_id = v_issuer_id
              AND deny_grant.tenant_id = v_tenant_id
              AND deny_grant.role_scope_type = 'tenant' AND deny_grant.role_tenant_id = v_tenant_id
              AND deny_grant.scope_type = 'tenant' AND deny_grant.scope_id = v_tenant_id::TEXT
              AND deny_grant.effect = 'deny' AND deny_grant.revoked_at IS NULL
              AND deny_grant.starts_at <= v_now
              AND (deny_grant.expires_at IS NULL OR deny_grant.expires_at > v_now)
          )
      )
  ) THEN
    RAISE EXCEPTION 'Invitation role is invalid or exceeds delegation ceiling' USING ERRCODE = '42501';
  END IF;

  SELECT id, status INTO v_membership_id, v_membership_status FROM public.memberships
  WHERE tenant_id = v_tenant_id AND user_id = v_actor;
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
    VALUES (v_tenant_id, v_actor, 'active', v_now)
    RETURNING id INTO v_membership_id;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.access_grants AS g WHERE g.tenant_id = v_tenant_id
      AND g.subject_id = v_actor AND g.role_id = v_role_id
      AND g.scope_type = 'tenant' AND g.scope_id = v_tenant_id::TEXT
      AND g.effect = 'allow' AND g.revoked_at IS NULL
      AND (g.expires_at IS NULL OR g.expires_at > v_now)
  ) THEN
    INSERT INTO public.access_grants (
      tenant_id, subject_id, role_id, role_scope_type, role_tenant_id,
      scope_type, scope_id, effect, granted_by, reason
    ) VALUES (
      v_tenant_id, v_actor, v_role_id, 'tenant', v_tenant_id,
      'tenant', v_tenant_id::TEXT, 'allow', v_issuer_id,
      'Tenant member invitation accepted'
    );
  END IF;

  UPDATE public.tenant_invitations SET accepted_at = v_now, accepted_by = v_actor,
    version = version + 1 WHERE id = v_invitation.id;

  INSERT INTO public.audit_events (
    tenant_id, actor_id, actor_type, action, resource_type, resource_id,
    correlation_id, reason, after_redacted, source, schema_version, idempotency_key
  ) VALUES (
    v_tenant_id, v_actor, 'user', 'membership.grant', 'membership', v_membership_id,
    v_correlation_id, 'Tenant member invitation accepted',
    pg_catalog.jsonb_build_object('invitationId', v_invitation.id, 'roleKey', v_role.key),
    'tenant-member-invitation-acceptance', '1', v_invitation.id::TEXT
  );

  RETURN pg_catalog.jsonb_build_object(
    'tenantId', v_tenant_id, 'tenantName', v_tenant.display_name,
    'membershipId', v_membership_id, 'roleKey', v_role.key,
    'invitationKind', 'tenant_member', 'correlationId', v_correlation_id
  );
END;
$function$;

CREATE OR REPLACE FUNCTION private.accept_any_tenant_invitation(p_token_hash BYTEA)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  v_kind TEXT;
  v_result JSONB;
BEGIN
  IF p_token_hash IS NULL OR pg_catalog.octet_length(p_token_hash) <> 32 THEN
    RAISE EXCEPTION 'Invalid invitation' USING ERRCODE = '22023';
  END IF;
  SELECT invitation_kind INTO v_kind FROM public.tenant_invitations WHERE token_hash = p_token_hash;
  IF v_kind = 'first_admin' THEN
    v_result := private.accept_tenant_invitation(p_token_hash);
  ELSIF v_kind = 'tenant_member' THEN
    v_result := private.accept_tenant_member_invitation(p_token_hash);
  ELSE
    RAISE EXCEPTION 'Invitation is invalid or unavailable' USING ERRCODE = '22023';
  END IF;
  RETURN v_result || pg_catalog.jsonb_build_object('invitationKind', v_kind);
END;
$function$;

REVOKE ALL ON FUNCTION private.create_tenant_member_invitation(UUID, TEXT, TEXT, BYTEA, TEXT)
  FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON FUNCTION private.accept_tenant_member_invitation(BYTEA)
  FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON FUNCTION private.accept_any_tenant_invitation(BYTEA)
  FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION private.create_tenant_member_invitation(UUID, TEXT, TEXT, BYTEA, TEXT)
  TO authenticated;
GRANT EXECUTE ON FUNCTION private.accept_tenant_member_invitation(BYTEA)
  TO authenticated;
GRANT EXECUTE ON FUNCTION private.accept_any_tenant_invitation(BYTEA)
  TO authenticated;

CREATE OR REPLACE FUNCTION public.create_tenant_member_invitation(
  p_tenant_id UUID, p_email TEXT, p_role_key TEXT, p_token_hash BYTEA, p_reason TEXT
)
RETURNS JSONB LANGUAGE SQL SECURITY INVOKER SET search_path = '' AS $function$
  SELECT private.create_tenant_member_invitation(p_tenant_id, p_email, p_role_key, p_token_hash, p_reason);
$function$;

CREATE OR REPLACE FUNCTION public.accept_tenant_invitation(p_token_hash BYTEA)
RETURNS JSONB LANGUAGE SQL SECURITY INVOKER SET search_path = '' AS $function$
  SELECT private.accept_any_tenant_invitation(p_token_hash);
$function$;

REVOKE ALL ON FUNCTION public.create_tenant_member_invitation(UUID, TEXT, TEXT, BYTEA, TEXT)
  FROM PUBLIC, anon, service_role;
REVOKE ALL ON FUNCTION public.accept_tenant_invitation(BYTEA)
  FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.create_tenant_member_invitation(UUID, TEXT, TEXT, BYTEA, TEXT)
  TO authenticated;
GRANT EXECUTE ON FUNCTION public.accept_tenant_invitation(BYTEA)
  TO authenticated;

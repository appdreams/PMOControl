-- F1-05 / F1-10: expose a minimal Tenant membership directory only to an
-- authenticated member with the exact tenant-scoped membership.view grant.
-- No email, token, grant IDs, or cross-scope assignments are returned.

CREATE OR REPLACE FUNCTION private.list_tenant_members(p_tenant_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  v_actor UUID := auth.uid();
  v_now TIMESTAMPTZ := pg_catalog.now();
  v_members JSONB;
BEGIN
  IF v_actor IS NULL OR p_tenant_id IS NULL THEN
    RAISE EXCEPTION 'Tenant membership access denied' USING ERRCODE = '42501';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.tenants AS t
    JOIN public.memberships AS m
      ON m.tenant_id = t.id AND m.user_id = v_actor AND m.status = 'active'
    WHERE t.id = p_tenant_id AND t.status = 'active'
  ) OR NOT EXISTS (
    SELECT 1
    FROM public.access_grants AS g
    JOIN public.roles AS r
      ON r.id = g.role_id
      AND r.scope_type = 'tenant'
      AND r.tenant_id = p_tenant_id
      AND r.status = 'active'
    JOIN public.role_permissions AS rp
      ON rp.role_id = r.id AND rp.permission_key = 'membership.view'
    WHERE g.subject_id = v_actor
      AND g.tenant_id = p_tenant_id
      AND g.role_scope_type = 'tenant'
      AND g.role_tenant_id = p_tenant_id
      AND g.scope_type = 'tenant'
      AND g.scope_id = p_tenant_id::TEXT
      AND g.effect = 'allow'
      AND g.revoked_at IS NULL
      AND g.starts_at <= v_now
      AND (g.expires_at IS NULL OR g.expires_at > v_now)
  ) OR EXISTS (
    SELECT 1
    FROM public.access_grants AS g
    JOIN public.roles AS r
      ON r.id = g.role_id
      AND r.scope_type = 'tenant'
      AND r.tenant_id = p_tenant_id
      AND r.status = 'active'
    JOIN public.role_permissions AS rp
      ON rp.role_id = r.id AND rp.permission_key = 'membership.view'
    WHERE g.subject_id = v_actor
      AND g.tenant_id = p_tenant_id
      AND g.role_scope_type = 'tenant'
      AND g.role_tenant_id = p_tenant_id
      AND g.scope_type = 'tenant'
      AND g.scope_id = p_tenant_id::TEXT
      AND g.effect = 'deny'
      AND g.revoked_at IS NULL
      AND g.starts_at <= v_now
      AND (g.expires_at IS NULL OR g.expires_at > v_now)
  ) THEN
    RAISE EXCEPTION 'Tenant membership access denied' USING ERRCODE = '42501';
  END IF;

  SELECT COALESCE(
    pg_catalog.jsonb_agg(
      pg_catalog.jsonb_build_object(
        'membershipId', m.id,
        'userId', m.user_id,
        'displayName', up.display_name,
        'status', m.status,
        'activatedAt', m.activated_at,
        'tenantRoleKeys', COALESCE((
          SELECT pg_catalog.jsonb_agg(DISTINCT r.key ORDER BY r.key)
          FROM public.access_grants AS g
          JOIN public.roles AS r
            ON r.id = g.role_id
            AND r.scope_type = 'tenant'
            AND r.tenant_id = p_tenant_id
            AND r.status = 'active'
          WHERE g.subject_id = m.user_id
            AND g.tenant_id = p_tenant_id
            AND g.role_scope_type = 'tenant'
            AND g.role_tenant_id = p_tenant_id
            AND g.scope_type = 'tenant'
            AND g.scope_id = p_tenant_id::TEXT
            AND g.effect = 'allow'
            AND g.revoked_at IS NULL
            AND g.starts_at <= v_now
            AND (g.expires_at IS NULL OR g.expires_at > v_now)
        ), '[]'::JSONB)
      ) ORDER BY m.created_at, m.id
    ),
    '[]'::JSONB
  ) INTO v_members
  FROM public.memberships AS m
  LEFT JOIN public.user_profiles AS up ON up.user_id = m.user_id
  WHERE m.tenant_id = p_tenant_id;

  RETURN pg_catalog.jsonb_build_object('members', v_members);
END;
$function$;

REVOKE ALL ON FUNCTION private.list_tenant_members(UUID) FROM PUBLIC, anon, authenticated, service_role;
GRANT USAGE ON SCHEMA private TO authenticated;
GRANT EXECUTE ON FUNCTION private.list_tenant_members(UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.list_tenant_members(p_tenant_id UUID)
RETURNS JSONB
LANGUAGE SQL
SECURITY INVOKER
SET search_path = ''
AS $function$
  SELECT private.list_tenant_members(p_tenant_id);
$function$;

REVOKE ALL ON FUNCTION public.list_tenant_members(UUID) FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.list_tenant_members(UUID) TO authenticated;

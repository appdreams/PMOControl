-- Return only exact scopes where the caller can delegate at least one preset.
-- Resource labels are protected data and must not be enumerable by Tenant-only actors.

CREATE OR REPLACE FUNCTION private.list_delegable_invitation_scopes(p_tenant_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  v_actor UUID := auth.uid();
  v_tenant public.tenants%ROWTYPE;
BEGIN
  IF v_actor IS NULL OR p_tenant_id IS NULL THEN
    RAISE EXCEPTION 'Authentication and Tenant are required' USING ERRCODE = '42501';
  END IF;
  SELECT * INTO v_tenant FROM public.tenants WHERE id = p_tenant_id;
  IF NOT FOUND OR v_tenant.status <> 'active' OR NOT EXISTS (
    SELECT 1 FROM public.memberships AS m
    WHERE m.tenant_id = p_tenant_id AND m.user_id = v_actor AND m.status = 'active'
  ) THEN
    RAISE EXCEPTION 'Active Tenant membership required' USING ERRCODE = '42501';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.access_grants AS g
    JOIN public.roles AS r ON r.id = g.role_id AND r.scope_type = 'tenant'
      AND r.tenant_id = p_tenant_id AND r.status = 'active'
    JOIN public.role_permissions AS rp ON rp.role_id = r.id
      AND rp.permission_key = 'membership.invite'
    WHERE g.subject_id = v_actor AND g.tenant_id = p_tenant_id
      AND g.role_scope_type = 'tenant' AND g.role_tenant_id = p_tenant_id
      AND g.scope_type = 'tenant' AND g.scope_id = p_tenant_id::TEXT
      AND g.effect = 'allow' AND g.revoked_at IS NULL AND g.starts_at <= pg_catalog.now()
      AND (g.expires_at IS NULL OR g.expires_at > pg_catalog.now())
  ) OR EXISTS (
    SELECT 1 FROM public.access_grants AS g
    JOIN public.roles AS r ON r.id = g.role_id AND r.scope_type = 'tenant'
      AND r.tenant_id = p_tenant_id AND r.status = 'active'
    JOIN public.role_permissions AS rp ON rp.role_id = r.id
      AND rp.permission_key = 'membership.invite'
    WHERE g.subject_id = v_actor AND g.tenant_id = p_tenant_id
      AND g.role_scope_type = 'tenant' AND g.role_tenant_id = p_tenant_id
      AND g.scope_type = 'tenant' AND g.scope_id = p_tenant_id::TEXT
      AND g.effect = 'deny' AND g.revoked_at IS NULL AND g.starts_at <= pg_catalog.now()
      AND (g.expires_at IS NULL OR g.expires_at > pg_catalog.now())
  ) THEN
    RAISE EXCEPTION 'Membership invitation permission required' USING ERRCODE = '42501';
  END IF;

  RETURN (
    SELECT pg_catalog.jsonb_build_object(
      'scopes', coalesce(pg_catalog.jsonb_agg(
        pg_catalog.jsonb_build_object(
          'scopeType', eligible.scope_type,
          'scopeId', eligible.scope_id,
          'label', eligible.display_name,
          'roleKeys', eligible.role_keys
        ) ORDER BY eligible.scope_type, eligible.display_name
      ), '[]'::JSONB)
    )
    FROM (
      SELECT candidate.scope_type, candidate.scope_id, candidate.display_name,
        pg_catalog.array_agg(target_role.key ORDER BY target_role.key) AS role_keys
      FROM (
        SELECT 'tenant'::TEXT AS scope_type, v_tenant.id AS scope_id,
          v_tenant.display_name AS display_name
        UNION ALL
        SELECT 'portfolio'::TEXT, p.id, p.name
        FROM public.portfolios AS p
        WHERE p.tenant_id = p_tenant_id AND p.status = 'active'
        UNION ALL
        SELECT 'project'::TEXT, pr.id, pr.name
        FROM public.projects AS pr
        WHERE pr.tenant_id = p_tenant_id AND pr.archived_at IS NULL
      ) AS candidate
      JOIN public.roles AS target_role ON target_role.tenant_id = p_tenant_id
        AND target_role.scope_type = 'tenant' AND target_role.is_system AND target_role.status = 'active'
      WHERE private.role_delegable_at_scope(
        v_actor, p_tenant_id, target_role.id, candidate.scope_type, candidate.scope_id
      )
      GROUP BY candidate.scope_type, candidate.scope_id, candidate.display_name
    ) AS eligible
  );
END;
$function$;

REVOKE ALL ON FUNCTION private.list_delegable_invitation_scopes(UUID)
  FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION private.list_delegable_invitation_scopes(UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.list_delegable_invitation_scopes(p_tenant_id UUID)
RETURNS JSONB
LANGUAGE SQL
SECURITY INVOKER
SET search_path = ''
AS $function$
  SELECT private.list_delegable_invitation_scopes(p_tenant_id);
$function$;

REVOKE ALL ON FUNCTION public.list_delegable_invitation_scopes(UUID)
  FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.list_delegable_invitation_scopes(UUID) TO authenticated;

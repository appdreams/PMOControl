-- Keep the privileged resource-directory query outside the exposed API schema.
CREATE OR REPLACE FUNCTION private.list_resource_grant_targets(p_tenant_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  v_actor UUID := auth.uid();
  v_now TIMESTAMPTZ := pg_catalog.now();
  v_resources JSONB;
BEGIN
  IF v_actor IS NULL OR p_tenant_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.tenants AS t
    JOIN public.memberships AS m ON m.tenant_id = t.id
      AND m.user_id = v_actor AND m.status = 'active'
    WHERE t.id = p_tenant_id AND t.status = 'active'
  ) THEN
    RAISE EXCEPTION 'Tenant is unavailable' USING ERRCODE = '42501';
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

  SELECT COALESCE(pg_catalog.jsonb_agg(resource ORDER BY resource->>'label'), '[]'::JSONB)
  INTO v_resources
  FROM (
    SELECT pg_catalog.jsonb_build_object('scopeType', 'portfolio', 'scopeId', p.id, 'label', p.name) AS resource
    FROM public.portfolios AS p
    WHERE p.tenant_id = p_tenant_id AND p.status = 'active' AND p.archived_at IS NULL
    UNION ALL
    SELECT pg_catalog.jsonb_build_object('scopeType', 'project', 'scopeId', p.id, 'label', p.name) AS resource
    FROM public.projects AS p
    WHERE p.tenant_id = p_tenant_id AND p.status NOT IN ('completed', 'cancelled') AND p.archived_at IS NULL
  ) AS available;
  RETURN pg_catalog.jsonb_build_object('resources', v_resources);
END;
$function$;

REVOKE ALL ON FUNCTION private.list_resource_grant_targets(UUID) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION private.list_resource_grant_targets(UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.list_resource_grant_targets(p_tenant_id UUID)
RETURNS JSONB
LANGUAGE SQL
SECURITY INVOKER
SET search_path = ''
AS $function$
  SELECT private.list_resource_grant_targets(p_tenant_id);
$function$;

REVOKE ALL ON FUNCTION public.list_resource_grant_targets(UUID) FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.list_resource_grant_targets(UUID) TO authenticated;

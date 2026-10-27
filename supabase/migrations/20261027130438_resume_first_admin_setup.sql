-- Allow the authorized Tenant creator to resume the post-provisioning invitation step.
CREATE OR REPLACE FUNCTION private.get_first_tenant_admin_context(p_tenant_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  v_actor UUID := auth.uid();
  v_now TIMESTAMPTZ := pg_catalog.now();
  v_tenant public.tenants%ROWTYPE;
BEGIN
  IF v_actor IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;
  IF p_tenant_id IS NULL THEN
    RAISE EXCEPTION 'Tenant is required' USING ERRCODE = '22023';
  END IF;

  SELECT * INTO v_tenant FROM public.tenants WHERE id = p_tenant_id;
  IF NOT FOUND OR v_tenant.created_by <> v_actor OR v_tenant.status <> 'active' THEN
    RAISE EXCEPTION 'Tenant setup is not available' USING ERRCODE = '42501';
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

  RETURN pg_catalog.jsonb_build_object(
    'tenantId', v_tenant.id,
    'name', v_tenant.display_name,
    'slug', v_tenant.slug,
    'firstAdminActivated',
      EXISTS (SELECT 1 FROM public.memberships WHERE tenant_id = p_tenant_id AND status = 'active')
      OR EXISTS (SELECT 1 FROM public.tenant_invitations WHERE tenant_id = p_tenant_id
        AND invitation_kind = 'first_admin' AND accepted_at IS NOT NULL),
    'pendingInvitation',
      EXISTS (SELECT 1 FROM public.tenant_invitations WHERE tenant_id = p_tenant_id
        AND invitation_kind = 'first_admin' AND accepted_at IS NULL AND revoked_at IS NULL AND expires_at > v_now)
  );
END;
$function$;

REVOKE ALL ON FUNCTION private.get_first_tenant_admin_context(UUID) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION private.get_first_tenant_admin_context(UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.get_first_tenant_admin_context(p_tenant_id UUID)
RETURNS JSONB
LANGUAGE SQL
SECURITY INVOKER
SET search_path = ''
AS $function$
  SELECT private.get_first_tenant_admin_context(p_tenant_id);
$function$;

REVOKE ALL ON FUNCTION public.get_first_tenant_admin_context(UUID) FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.get_first_tenant_admin_context(UUID) TO authenticated;

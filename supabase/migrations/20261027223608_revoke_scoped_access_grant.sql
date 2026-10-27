-- F1-07: explicit, auditable revocation for delegated resource roles.
-- The project_manager role is revoked only by the manager reassignment RPC,
-- which updates the Project and its grant atomically.
CREATE OR REPLACE FUNCTION private.revoke_resource_role_grant(
  p_tenant_id UUID,
  p_grant_id UUID,
  p_expected_version INTEGER,
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
  v_grant public.access_grants%ROWTYPE;
  v_role_key TEXT;
  v_correlation_id UUID := gen_random_uuid();
  v_identity JSONB;
  v_before JSONB;
  v_after JSONB;
  v_existing public.audit_events%ROWTYPE;
  v_new_version INTEGER;
BEGIN
  IF v_actor IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;
  IF p_tenant_id IS NULL OR p_grant_id IS NULL OR p_expected_version IS NULL OR p_expected_version < 1
     OR p_reason IS NULL OR p_reason <> pg_catalog.btrim(p_reason)
     OR pg_catalog.char_length(p_reason) NOT BETWEEN 1 AND 1000
     OR p_idempotency_key IS NULL THEN
    RAISE EXCEPTION 'Invalid resource grant revocation' USING ERRCODE = '22023';
  END IF;

  PERFORM 1 FROM public.tenants AS t
  WHERE t.id = p_tenant_id AND t.status = 'active'
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Tenant is unavailable' USING ERRCODE = '42501';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.memberships AS m
    WHERE m.tenant_id = p_tenant_id AND m.user_id = v_actor AND m.status = 'active'
  ) OR NOT EXISTS (
    SELECT 1 FROM public.access_grants AS g
    JOIN public.roles AS r ON r.id = g.role_id AND r.status = 'active'
      AND r.scope_type = 'tenant' AND r.tenant_id = p_tenant_id
    JOIN public.role_permissions AS rp ON rp.role_id = r.id AND rp.permission_key = 'membership.grant'
    WHERE g.tenant_id = p_tenant_id AND g.subject_id = v_actor
      AND g.role_scope_type = 'tenant' AND g.role_tenant_id = p_tenant_id
      AND g.scope_type = 'tenant' AND g.scope_id = p_tenant_id::TEXT
      AND g.effect = 'allow' AND g.revoked_at IS NULL
      AND g.starts_at <= v_now AND (g.expires_at IS NULL OR g.expires_at > v_now)
  ) OR EXISTS (
    SELECT 1 FROM public.access_grants AS g
    JOIN public.roles AS r ON r.id = g.role_id AND r.status = 'active'
      AND r.scope_type = 'tenant' AND r.tenant_id = p_tenant_id
    JOIN public.role_permissions AS rp ON rp.role_id = r.id AND rp.permission_key = 'membership.grant'
    WHERE g.tenant_id = p_tenant_id AND g.subject_id = v_actor
      AND g.role_scope_type = 'tenant' AND g.role_tenant_id = p_tenant_id
      AND g.scope_type = 'tenant' AND g.scope_id = p_tenant_id::TEXT
      AND g.effect = 'deny' AND g.revoked_at IS NULL
      AND g.starts_at <= v_now AND (g.expires_at IS NULL OR g.expires_at > v_now)
  ) THEN
    RAISE EXCEPTION 'Resource grant permission required' USING ERRCODE = '42501';
  END IF;

  SELECT g.* INTO v_grant
  FROM public.access_grants AS g
  WHERE g.id = p_grant_id AND g.tenant_id = p_tenant_id
    AND g.role_scope_type = 'tenant' AND g.role_tenant_id = p_tenant_id
    AND g.scope_type IN ('portfolio', 'project') AND g.effect = 'allow'
    AND EXISTS (
      SELECT 1 FROM public.roles AS r
      WHERE r.id = g.role_id AND r.tenant_id = p_tenant_id
    )
  FOR UPDATE OF g;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Resource grant is unavailable' USING ERRCODE = '42501';
  END IF;
  SELECT r.key INTO v_role_key FROM public.roles AS r
  WHERE r.id = v_grant.role_id AND r.tenant_id = p_tenant_id
  FOR SHARE;
  IF v_role_key = 'project_manager' THEN
    RAISE EXCEPTION 'Project manager grants must be revoked through manager reassignment' USING ERRCODE = '22023';
  END IF;

  v_identity := pg_catalog.jsonb_build_object(
    'grantId', v_grant.id, 'subjectId', v_grant.subject_id, 'roleKey', v_role_key,
    'scopeType', v_grant.scope_type, 'scopeId', v_grant.scope_id
  );
  v_before := v_identity || pg_catalog.jsonb_build_object(
    'state', 'active', 'version', v_grant.version
  );
  SELECT * INTO v_existing FROM public.audit_events AS a
  WHERE a.tenant_id = p_tenant_id AND a.source = 'resource-access-grant'
    AND a.idempotency_key = 'revoke:' || p_idempotency_key::TEXT
  FOR UPDATE;
  IF FOUND THEN
    IF v_existing.actor_id <> v_actor OR v_existing.reason <> p_reason
       OR v_existing.resource_id <> p_grant_id
       OR (v_existing.before_redacted - 'state' - 'version') <> v_identity
       OR (v_existing.before_redacted->>'version')::INTEGER <> p_expected_version THEN
      RAISE EXCEPTION 'Idempotency key payload mismatch' USING ERRCODE = '23505';
    END IF;
    RETURN pg_catalog.jsonb_build_object(
      'grantId', p_grant_id, 'tenantId', p_tenant_id,
      'subjectId', v_grant.subject_id, 'roleKey', v_role_key,
      'scopeType', v_grant.scope_type, 'scopeId', v_grant.scope_id,
      'version', (v_existing.after_redacted->>'version')::INTEGER,
      'correlationId', v_existing.correlation_id, 'idempotentReplay', TRUE
    );
  END IF;

  IF v_grant.revoked_at IS NOT NULL OR v_grant.version <> p_expected_version THEN
    RAISE EXCEPTION 'Resource grant version conflict' USING ERRCODE = '40001';
  END IF;

  UPDATE public.access_grants AS g
  SET revoked_at = v_now, revoked_by = v_actor, revocation_reason = p_reason,
      version = g.version + 1
  WHERE g.id = p_grant_id AND g.tenant_id = p_tenant_id
    AND g.revoked_at IS NULL AND g.version = p_expected_version
  RETURNING g.version INTO v_new_version;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Resource grant version conflict' USING ERRCODE = '40001';
  END IF;

  v_after := pg_catalog.jsonb_build_object(
    'grantId', v_grant.id, 'subjectId', v_grant.subject_id, 'roleKey', v_role_key,
    'scopeType', v_grant.scope_type, 'scopeId', v_grant.scope_id,
    'state', 'revoked', 'version', v_new_version
  );
  INSERT INTO public.audit_events (
    tenant_id, actor_id, actor_type, action, resource_type, resource_id,
    correlation_id, reason, before_redacted, after_redacted,
    source, schema_version, idempotency_key
  ) VALUES (
    p_tenant_id, v_actor, 'user', 'access_grant.revoke', 'access_grant', v_grant.id,
    v_correlation_id, p_reason, v_before, v_after,
    'resource-access-grant', '1', 'revoke:' || p_idempotency_key::TEXT
  );

  RETURN pg_catalog.jsonb_build_object(
    'grantId', v_grant.id, 'tenantId', p_tenant_id,
    'subjectId', v_grant.subject_id, 'roleKey', v_role_key,
    'scopeType', v_grant.scope_type, 'scopeId', v_grant.scope_id,
    'version', v_new_version, 'correlationId', v_correlation_id, 'idempotentReplay', FALSE
  );
END;
$function$;

REVOKE ALL ON FUNCTION private.revoke_resource_role_grant(UUID, UUID, INTEGER, TEXT, UUID)
  FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION private.revoke_resource_role_grant(UUID, UUID, INTEGER, TEXT, UUID)
  TO authenticated;

CREATE OR REPLACE FUNCTION public.revoke_resource_role_grant(
  p_tenant_id UUID, p_grant_id UUID, p_expected_version INTEGER,
  p_reason TEXT, p_idempotency_key UUID
)
RETURNS JSONB
LANGUAGE SQL
SECURITY INVOKER
SET search_path = ''
AS $function$
  SELECT private.revoke_resource_role_grant(
    p_tenant_id, p_grant_id, p_expected_version, p_reason, p_idempotency_key
  );
$function$;

REVOKE ALL ON FUNCTION public.revoke_resource_role_grant(UUID, UUID, INTEGER, TEXT, UUID)
  FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.revoke_resource_role_grant(UUID, UUID, INTEGER, TEXT, UUID)
  TO authenticated;

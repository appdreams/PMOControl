-- F1-11: begin the Tenant export-first termination lifecycle.
-- This command only enters termination_pending; no export or purge is performed.
CREATE OR REPLACE FUNCTION private.begin_tenant_termination(
  p_tenant_id UUID,
  p_expected_version BIGINT,
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
  v_tenant public.tenants%ROWTYPE;
  v_existing public.audit_events%ROWTYPE;
  v_before JSONB;
  v_after JSONB;
  v_correlation_id UUID := gen_random_uuid();
  v_new_version BIGINT;
BEGIN
  IF v_actor IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;
  IF p_tenant_id IS NULL OR p_expected_version IS NULL OR p_expected_version < 1
     OR p_reason IS NULL OR p_reason <> pg_catalog.btrim(p_reason)
     OR pg_catalog.char_length(p_reason) NOT BETWEEN 1 AND 1000
     OR p_idempotency_key IS NULL THEN
    RAISE EXCEPTION 'Invalid Tenant termination request' USING ERRCODE = '22023';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.access_grants AS g
    JOIN public.roles AS r ON r.id = g.role_id AND r.scope_type = 'platform'
      AND r.tenant_id IS NULL AND r.status = 'active'
    JOIN public.role_permissions AS rp ON rp.role_id = r.id
      AND rp.permission_key = 'tenant.lifecycle.terminate'
    WHERE g.subject_id = v_actor AND g.tenant_id IS NULL
      AND g.role_scope_type = 'platform' AND g.role_tenant_id IS NULL
      AND g.scope_type = 'platform' AND g.scope_id = 'platform'
      AND g.effect = 'allow' AND g.revoked_at IS NULL
      AND g.starts_at <= v_now AND (g.expires_at IS NULL OR g.expires_at > v_now)
  ) OR EXISTS (
    SELECT 1 FROM public.access_grants AS g
    JOIN public.roles AS r ON r.id = g.role_id AND r.scope_type = 'platform'
      AND r.tenant_id IS NULL AND r.status = 'active'
    JOIN public.role_permissions AS rp ON rp.role_id = r.id
      AND rp.permission_key = 'tenant.lifecycle.terminate'
    WHERE g.subject_id = v_actor AND g.tenant_id IS NULL
      AND g.role_scope_type = 'platform' AND g.role_tenant_id IS NULL
      AND g.scope_type = 'platform' AND g.scope_id = 'platform'
      AND g.effect = 'deny' AND g.revoked_at IS NULL
      AND g.starts_at <= v_now AND (g.expires_at IS NULL OR g.expires_at > v_now)
  ) THEN
    RAISE EXCEPTION 'Platform termination permission required' USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_existing FROM public.audit_events AS a
  WHERE a.tenant_id IS NULL AND a.source = 'tenant-termination'
    AND a.idempotency_key = p_idempotency_key::TEXT
  FOR UPDATE;
  IF FOUND THEN
    IF v_existing.actor_id <> v_actor OR v_existing.resource_id <> p_tenant_id
       OR v_existing.reason <> p_reason
       OR (v_existing.before_redacted->>'version')::BIGINT <> p_expected_version THEN
      RAISE EXCEPTION 'Idempotency key payload mismatch' USING ERRCODE = '23505';
    END IF;
    RETURN pg_catalog.jsonb_build_object(
      'tenantId', p_tenant_id,
      'status', v_existing.after_redacted->>'status',
      'version', (v_existing.after_redacted->>'version')::BIGINT,
      'terminationStartedAt', v_existing.after_redacted->>'terminationStartedAt',
      'correlationId', v_existing.correlation_id,
      'idempotentReplay', TRUE
    );
  END IF;

  SELECT * INTO v_tenant FROM public.tenants AS t
  WHERE t.id = p_tenant_id
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Tenant is unavailable' USING ERRCODE = '42501';
  END IF;
  IF v_tenant.status NOT IN ('active', 'suspended') THEN
    RAISE EXCEPTION 'Tenant lifecycle transition is unavailable' USING ERRCODE = '22023';
  END IF;
  IF v_tenant.version <> p_expected_version THEN
    RAISE EXCEPTION 'Tenant version conflict' USING ERRCODE = '40001';
  END IF;

  v_before := pg_catalog.jsonb_build_object(
    'tenantId', p_tenant_id, 'status', v_tenant.status, 'version', v_tenant.version
  );
  UPDATE public.tenants AS t
  SET status = 'termination_pending', termination_started_at = v_now,
      version = t.version + 1
  WHERE t.id = p_tenant_id AND t.version = p_expected_version
  RETURNING t.version INTO v_new_version;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Tenant version conflict' USING ERRCODE = '40001';
  END IF;

  v_after := pg_catalog.jsonb_build_object(
    'tenantId', p_tenant_id, 'status', 'termination_pending',
    'version', v_new_version, 'terminationStartedAt', v_now
  );
  INSERT INTO public.audit_events (
    tenant_id, actor_id, actor_type, action, resource_type, resource_id,
    correlation_id, reason, before_redacted, after_redacted,
    source, schema_version, idempotency_key
  ) VALUES (
    NULL, v_actor, 'user', 'tenant.lifecycle.terminate', 'tenant', p_tenant_id,
    v_correlation_id, p_reason, v_before, v_after,
    'tenant-termination', '1', p_idempotency_key::TEXT
  );

  RETURN pg_catalog.jsonb_build_object(
    'tenantId', p_tenant_id, 'status', 'termination_pending',
    'version', v_new_version, 'terminationStartedAt', v_now,
    'correlationId', v_correlation_id, 'idempotentReplay', FALSE
  );
END;
$function$;

REVOKE ALL ON FUNCTION private.begin_tenant_termination(UUID, BIGINT, TEXT, UUID)
  FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION private.begin_tenant_termination(UUID, BIGINT, TEXT, UUID)
  TO authenticated;

CREATE OR REPLACE FUNCTION public.begin_tenant_termination(
  p_tenant_id UUID, p_expected_version BIGINT, p_reason TEXT, p_idempotency_key UUID
)
RETURNS JSONB
LANGUAGE SQL
SECURITY INVOKER
SET search_path = ''
AS $function$
  SELECT private.begin_tenant_termination(
    p_tenant_id, p_expected_version, p_reason, p_idempotency_key
  );
$function$;

REVOKE ALL ON FUNCTION public.begin_tenant_termination(UUID, BIGINT, TEXT, UUID)
  FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.begin_tenant_termination(UUID, BIGINT, TEXT, UUID)
  TO authenticated;

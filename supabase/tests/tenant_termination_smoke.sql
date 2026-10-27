-- Export-first termination start smoke. No lifecycle fixtures persist.
BEGIN;
DO $smoke$
DECLARE
  v_actor UUID := gen_random_uuid();
  v_unprivileged UUID := gen_random_uuid();
  v_tenant UUID := gen_random_uuid();
  v_suspended_tenant UUID := gen_random_uuid();
  v_role UUID;
  v_result JSONB;
  v_key UUID := gen_random_uuid();
BEGIN
  INSERT INTO auth.users (
    id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
    created_at, updated_at, raw_app_meta_data, raw_user_meta_data
  ) VALUES
    (v_actor, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
     v_actor::TEXT || '@tenant-termination-smoke.invalid', '', now(), now(), now(),
     '{"provider":"email","providers":["email"]}'::JSONB, '{}'::JSONB),
    (v_unprivileged, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
     v_unprivileged::TEXT || '@tenant-termination-smoke.invalid', '', now(), now(), now(),
     '{"provider":"email","providers":["email"]}'::JSONB, '{}'::JSONB);

  SELECT r.id INTO v_role FROM public.roles AS r
  WHERE r.tenant_id IS NULL AND r.scope_type = 'platform' AND r.key = 'platform_admin'
    AND r.status = 'active';
  IF v_role IS NULL THEN RAISE EXCEPTION 'Platform admin preset is unavailable'; END IF;
  INSERT INTO public.role_permissions (role_id, permission_key)
  VALUES (v_role, 'tenant.lifecycle.terminate')
  ON CONFLICT (role_id, permission_key) DO NOTHING;
  INSERT INTO public.access_grants (
    tenant_id, subject_id, role_id, role_scope_type, role_tenant_id,
    scope_type, scope_id, effect, granted_by, reason
  ) VALUES (NULL, v_actor, v_role, 'platform', NULL, 'platform', 'platform',
            'allow', v_actor, 'termination smoke');

  INSERT INTO public.tenants (id, slug, display_name, status, created_by)
  VALUES (v_tenant, 'termination-' || LEFT(v_tenant::TEXT, 8), 'Termination smoke', 'active', v_actor),
         (v_suspended_tenant, 'term-suspended-' || LEFT(v_suspended_tenant::TEXT, 8),
          'Suspended termination smoke', 'suspended', v_actor);

  PERFORM set_config('request.jwt.claim.sub', v_actor::TEXT, TRUE);
  v_result := public.begin_tenant_termination(v_tenant, 1, 'Close after verified export', v_key);
  IF v_result->>'status' <> 'termination_pending' OR v_result->>'version' <> '2'
     OR v_result->>'idempotentReplay' <> 'false'
     OR NOT EXISTS (
       SELECT 1 FROM public.tenants AS t
       WHERE t.id = v_tenant AND t.status = 'termination_pending'
         AND t.version = 2 AND t.termination_started_at IS NOT NULL
     ) OR NOT EXISTS (
       SELECT 1 FROM public.audit_events AS a
       WHERE a.tenant_id IS NULL AND a.resource_id = v_tenant
         AND a.action = 'tenant.lifecycle.terminate' AND a.idempotency_key = v_key::TEXT
     ) THEN RAISE EXCEPTION 'Tenant termination start or audit failed'; END IF;

  v_result := public.begin_tenant_termination(v_tenant, 1, 'Close after verified export', v_key);
  IF v_result->>'idempotentReplay' <> 'true' OR v_result->>'version' <> '2' THEN
    RAISE EXCEPTION 'Tenant termination replay failed';
  END IF;
  BEGIN
    PERFORM public.begin_tenant_termination(v_tenant, 2, 'Changed version', v_key);
    RAISE EXCEPTION 'Mismatched termination key unexpectedly succeeded';
  EXCEPTION WHEN unique_violation THEN NULL;
  END;
  BEGIN
    PERFORM public.begin_tenant_termination(v_suspended_tenant, 2, 'Stale request', gen_random_uuid());
    RAISE EXCEPTION 'Stale Tenant version unexpectedly succeeded';
  EXCEPTION WHEN serialization_failure THEN NULL;
  END;

  v_result := public.begin_tenant_termination(
    v_suspended_tenant, 1, 'Close suspended Tenant after export', gen_random_uuid()
  );
  IF v_result->>'status' <> 'termination_pending' OR v_result->>'version' <> '2' THEN
    RAISE EXCEPTION 'Suspended Tenant termination start failed';
  END IF;

  PERFORM set_config('request.jwt.claim.sub', v_unprivileged::TEXT, TRUE);
  BEGIN
    PERFORM public.begin_tenant_termination(
      v_tenant, 2, 'Unprivileged attempt', gen_random_uuid()
    );
    RAISE EXCEPTION 'Unprivileged Tenant termination unexpectedly succeeded';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
END;
$smoke$;
ROLLBACK;

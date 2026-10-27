-- Transactional smoke for exact-scope role assignment; no fixtures persist.
BEGIN;
DO $smoke$
DECLARE
  v_actor UUID := gen_random_uuid();
  v_target UUID := gen_random_uuid();
  v_tenant UUID := gen_random_uuid();
  v_other_tenant UUID := gen_random_uuid();
  v_portfolio UUID := gen_random_uuid();
  v_other_portfolio UUID := gen_random_uuid();
  v_admin_role UUID := gen_random_uuid();
  v_target_role UUID := gen_random_uuid();
  v_result JSONB;
  v_targets JSONB;
  v_key UUID := gen_random_uuid();
BEGIN
  INSERT INTO auth.users (
    id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
    created_at, updated_at, raw_app_meta_data, raw_user_meta_data
  ) VALUES
    (v_actor, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
     v_actor::text || '@resource-grant-smoke.invalid', '', now(), now(), now(),
     '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb),
    (v_target, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
     v_target::text || '@resource-grant-smoke.invalid', '', now(), now(), now(),
     '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb);
  INSERT INTO public.tenants (id, slug, display_name, created_by)
  VALUES (v_tenant, 'resource-grant-' || left(v_tenant::text, 8), 'Resource grant smoke', v_actor),
         (v_other_tenant, 'resource-grant-x-' || left(v_other_tenant::text, 8), 'Other tenant smoke', v_actor);
  INSERT INTO public.memberships (tenant_id, user_id, status)
  VALUES (v_tenant, v_actor, 'active'), (v_tenant, v_target, 'active'),
         (v_other_tenant, v_actor, 'active');
  INSERT INTO public.portfolios (id, tenant_id, name, category, owner_id, created_by, updated_by)
  VALUES (v_portfolio, v_tenant, 'Smoke portfolio', 'internal', v_actor, v_actor, v_actor),
         (v_other_portfolio, v_other_tenant, 'Other portfolio', 'internal', v_actor, v_actor, v_actor);
  INSERT INTO public.roles (id, tenant_id, key, name, scope_type, is_system, status)
  VALUES (v_admin_role, v_tenant, 'tenant_admin', 'Tenant Admin', 'tenant', TRUE, 'active'),
         (v_target_role, v_tenant, 'viewer', 'Viewer', 'tenant', TRUE, 'active');
  INSERT INTO public.role_permissions (role_id, permission_key)
  VALUES (v_admin_role, 'membership.grant'), (v_target_role, 'portfolio.view');
  INSERT INTO public.access_grants (
    tenant_id, subject_id, role_id, role_scope_type, role_tenant_id,
    scope_type, scope_id, effect, granted_by, reason
  ) VALUES (v_tenant, v_actor, v_admin_role, 'tenant', v_tenant,
            'tenant', v_tenant::text, 'allow', v_actor, 'resource grant smoke');
  PERFORM set_config('request.jwt.claim.sub', v_actor::text, TRUE);

  v_targets := public.list_resource_grant_targets(v_tenant);
  IF NOT EXISTS (
    SELECT 1 FROM pg_catalog.jsonb_array_elements(v_targets->'resources') AS item
    WHERE item->>'scopeType' = 'portfolio' AND item->>'scopeId' = v_portfolio::text
      AND item->>'label' = 'Smoke portfolio'
  ) THEN RAISE EXCEPTION 'Authorized resource selector omitted active Portfolio'; END IF;

  v_result := public.assign_resource_role(
    v_tenant, v_target, 'viewer', 'portfolio', v_portfolio,
    'Smoke assignment', v_key
  );
  IF v_result->>'scopeType' <> 'portfolio' OR v_result->>'scopeId' <> v_portfolio::text
     OR v_result->>'idempotentReplay' <> 'false'
     OR NOT EXISTS (
       SELECT 1 FROM public.access_grants AS g
       WHERE g.id = (v_result->>'grantId')::uuid AND g.tenant_id = v_tenant
         AND g.subject_id = v_target AND g.scope_type = 'portfolio'
         AND g.scope_id = v_portfolio::text AND g.effect = 'allow' AND g.revoked_at IS NULL
     ) THEN RAISE EXCEPTION 'Exact Portfolio role assignment failed'; END IF;

  v_result := public.assign_resource_role(
    v_tenant, v_target, 'viewer', 'portfolio', v_portfolio,
    'Smoke assignment', v_key
  );
  IF v_result->>'idempotentReplay' <> 'true' THEN
    RAISE EXCEPTION 'Idempotent replay did not return the original grant';
  END IF;

  BEGIN
    PERFORM public.assign_resource_role(
      v_tenant, v_target, 'viewer', 'portfolio', v_other_portfolio,
      'Cross tenant must fail', gen_random_uuid()
    );
    RAISE EXCEPTION 'Cross-Tenant resource assignment unexpectedly succeeded';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;

  INSERT INTO public.access_grants (
    tenant_id, subject_id, role_id, role_scope_type, role_tenant_id,
    scope_type, scope_id, effect, granted_by, reason
  ) VALUES (v_tenant, v_actor, v_admin_role, 'tenant', v_tenant,
            'tenant', v_tenant::text, 'deny', v_actor, 'Explicit deny smoke');
  BEGIN
    PERFORM public.assign_resource_role(
      v_tenant, v_target, 'viewer', 'portfolio', v_portfolio,
      'Denied assignment must fail', gen_random_uuid()
    );
    RAISE EXCEPTION 'Explicit deny did not block resource assignment';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
  BEGIN
    PERFORM public.list_resource_grant_targets(v_tenant);
    RAISE EXCEPTION 'Explicit deny did not block resource list';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
END;
$smoke$;
ROLLBACK;

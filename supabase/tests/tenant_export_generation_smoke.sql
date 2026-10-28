-- Export reservation, allowlisted snapshot and worker finalization. Rollback all fixtures.
BEGIN;
DO $smoke$
DECLARE
  v_actor UUID := gen_random_uuid();
  v_contact UUID := gen_random_uuid();
  v_other UUID := gen_random_uuid();
  v_tenant UUID := gen_random_uuid();
  v_export UUID;
  v_key UUID := gen_random_uuid();
  v_portfolio UUID := gen_random_uuid();
  v_project UUID := gen_random_uuid();
  v_role UUID := gen_random_uuid();
  v_tenant_role UUID := gen_random_uuid();
  v_request JSONB;
  v_bundle_response JSONB;
  v_bundle JSONB;
  v_manifest JSONB;
  v_final JSONB;
  v_object_path TEXT;
  v_available_at TIMESTAMPTZ;
  v_purge_after TIMESTAMPTZ;
  v_audit_count BIGINT;
  v_notification_audit_count BIGINT;
BEGIN
  INSERT INTO auth.users (
    id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
    created_at, updated_at, raw_app_meta_data, raw_user_meta_data
  ) VALUES
    (v_actor, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
     v_actor::TEXT || '@tenant-export-generation.invalid', '', now(), now(), now(),
     '{"provider":"email","providers":["email"]}'::JSONB, '{}'),
    (v_contact, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
     v_contact::TEXT || '@tenant-export-generation.invalid', '', now(), now(), now(),
     '{"provider":"email","providers":["email"]}'::JSONB, '{}'),
    (v_other, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
     v_other::TEXT || '@tenant-export-generation.invalid', '', now(), now(), now(),
     '{"provider":"email","providers":["email"]}'::JSONB, '{}');

  SELECT r.id INTO v_role FROM public.roles AS r
  WHERE r.tenant_id IS NULL AND r.scope_type = 'platform' AND r.key = 'platform_admin'
    AND r.status = 'active';
  IF v_role IS NULL THEN RAISE EXCEPTION 'Platform admin preset is unavailable'; END IF;
  INSERT INTO public.role_permissions (role_id, permission_key)
  VALUES (v_role, 'tenant.lifecycle.terminate') ON CONFLICT DO NOTHING;
  INSERT INTO public.access_grants (
    tenant_id, subject_id, role_id, role_scope_type, role_tenant_id,
    scope_type, scope_id, effect, granted_by, reason
  ) VALUES (NULL, v_actor, v_role, 'platform', NULL, 'platform', 'platform',
            'allow', v_actor, 'export generation smoke');

  INSERT INTO public.tenants (id, slug, display_name, status, version, created_by, termination_started_at)
  VALUES (v_tenant, 'export-gen-' || LEFT(v_tenant::TEXT, 8), 'Export generation smoke',
          'termination_pending', 2, v_actor, now());
  INSERT INTO public.memberships (tenant_id, user_id, status)
  VALUES (v_tenant, v_contact, 'active');
  INSERT INTO public.user_profiles (user_id, display_name, profile_complete)
  VALUES (v_contact, 'Export Contact', TRUE)
  ON CONFLICT (user_id) DO UPDATE SET display_name = EXCLUDED.display_name, profile_complete = TRUE;
  INSERT INTO public.roles (id, tenant_id, key, name, scope_type, is_system, status)
  VALUES (v_tenant_role, v_tenant, 'tenant_admin', 'Tenant Admin', 'tenant', TRUE, 'active');
  INSERT INTO public.role_permissions (role_id, permission_key)
  VALUES (v_tenant_role, 'membership.view') ON CONFLICT DO NOTHING;
  INSERT INTO public.access_grants (
    tenant_id, subject_id, role_id, role_scope_type, role_tenant_id,
    scope_type, scope_id, effect, granted_by, reason
  ) VALUES (v_tenant, v_contact, v_tenant_role, 'tenant', v_tenant, 'tenant', v_tenant::TEXT,
            'allow', v_actor, 'export smoke tenant grant');
  INSERT INTO public.tenant_invitations (
    tenant_id, email_normalized, grant_payload, token_hash, expires_at, created_by
  ) VALUES (v_tenant, 'invite@tenant-export-generation.invalid',
    '{"schema_version":1,"grants":[]}'::JSONB, decode(repeat('cd', 32), 'hex'), now() + INTERVAL '7 days', v_actor);
  INSERT INTO public.portfolios (id, tenant_id, name, owner_id, category, created_by, updated_by)
  VALUES (v_portfolio, v_tenant, 'Export Portfolio', v_contact, 'test', v_actor, v_actor);
  INSERT INTO public.projects (id, tenant_id, name, status, priority, created_by, updated_by)
  VALUES (v_project, v_tenant, 'Export Project', 'planning', 'medium', v_actor, v_actor);
  INSERT INTO public.portfolio_projects (tenant_id, portfolio_id, project_id, linked_by)
  VALUES (v_tenant, v_portfolio, v_project, v_actor);
  INSERT INTO public.audit_events (
    tenant_id, actor_id, actor_type, action, resource_type, resource_id,
    correlation_id, after_redacted, source, schema_version
  ) VALUES (v_tenant, v_actor, 'user', 'tenant.export.smoke', 'tenant', v_tenant,
            gen_random_uuid(), '{"fixture":true}'::JSONB, 'tenant-export-smoke', '1');

  PERFORM set_config('request.jwt.claim.sub', v_actor::TEXT, TRUE);
  PERFORM set_config('request.jwt.claim.role', 'authenticated', TRUE);
  v_request := public.request_tenant_export(v_tenant, 2, v_contact,
    'Close after verified export', v_key);
  IF v_request->>'status' <> 'generating' OR v_request->>'idempotentReplay' <> 'false'
     OR (v_request->>'version')::BIGINT <> 1 THEN
    RAISE EXCEPTION 'Tenant export reservation failed';
  END IF;
  v_export := (v_request->>'exportId')::UUID;
  v_object_path := v_request->>'objectPath';
  v_request := public.request_tenant_export(v_tenant, 2, v_contact,
    'Close after verified export', v_key);
  IF v_request->>'idempotentReplay' <> 'true' OR (v_request->>'exportId')::UUID <> v_export THEN
    RAISE EXCEPTION 'Tenant export request replay failed';
  END IF;
  BEGIN
    PERFORM public.request_tenant_export(v_tenant, 2, v_other,
      'Close after verified export', v_key);
    RAISE EXCEPTION 'Mismatched export request replay unexpectedly succeeded';
  EXCEPTION WHEN unique_violation THEN NULL;
  END;

  v_bundle_response := public.get_tenant_export_bundle(v_export);
  v_bundle := v_bundle_response->'bundle';
  v_manifest := v_bundle_response->'manifest';
  IF v_bundle->>'tenantId' <> v_tenant::TEXT
     OR jsonb_array_length(v_bundle->'userProfiles') <> 1
     OR jsonb_array_length(v_bundle->'memberships') <> 1
     OR jsonb_array_length(v_bundle->'portfolios') <> 1
     OR jsonb_array_length(v_bundle->'projects') <> 1
     OR NOT (v_bundle->'invitations'->0 ? 'email_normalized')
     OR (v_bundle->'invitations'->0 ? 'token_hash')
     OR v_manifest->>'schemaVersion' <> 'tenant-export-v1' THEN
    RAISE EXCEPTION 'Tenant export bundle is incomplete or contains invitation token material';
  END IF;

  PERFORM set_config('request.jwt.claim.sub', v_other::TEXT, TRUE);
  BEGIN
    PERFORM public.get_tenant_export_bundle(v_export);
    RAISE EXCEPTION 'Unprivileged actor obtained Tenant export bundle';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
  PERFORM set_config('request.jwt.claim.sub', v_actor::TEXT, TRUE);

  INSERT INTO storage.objects (bucket_id, name, owner_id, metadata)
  VALUES ('tenant-exports', v_object_path, v_actor::TEXT,
          '{"size":"8","mimetype":"application/json"}'::JSONB);
  PERFORM set_config('request.jwt.claim.role', 'service_role', TRUE);
  EXECUTE 'SET LOCAL ROLE service_role';
  v_final := public.finalize_tenant_export(
    v_actor, v_export, decode(repeat('ef', 32), 'hex'), 8, v_manifest
  );
  IF v_final->>'status' <> 'available' OR v_final->>'idempotentReplay' <> 'false'
     THEN
    RAISE EXCEPTION 'Verified export finalization or retention start failed';
  END IF;
  v_available_at := (v_final->>'availableAt')::TIMESTAMPTZ;
  v_purge_after := (v_final->>'purgeAfter')::TIMESTAMPTZ;
  IF v_purge_after <> v_available_at + INTERVAL '90 days' THEN
    RAISE EXCEPTION 'Export retention window did not begin at availability';
  END IF;
  v_final := public.finalize_tenant_export(
    v_actor, v_export, decode(repeat('ef', 32), 'hex'), 8, v_manifest
  );
  IF v_final->>'idempotentReplay' <> 'true' THEN RAISE EXCEPTION 'Finalization replay failed'; END IF;
  EXECUTE 'RESET ROLE';
  IF NOT EXISTS (SELECT 1 FROM public.tenants t WHERE t.id = v_tenant
        AND t.status = 'export_ready' AND t.version = 3)
     OR NOT EXISTS (SELECT 1 FROM public.tenant_exports e WHERE e.id = v_export
        AND e.status = 'available' AND e.available_at IS NOT NULL
        AND e.purge_after = e.available_at + INTERVAL '90 days'
        AND e.artifact_sha256 = decode(repeat('ef', 32), 'hex') AND e.artifact_bytes = 8) THEN
    RAISE EXCEPTION 'Tenant/export state did not finalize as expected';
  END IF;
  SELECT count(*) INTO v_audit_count FROM public.audit_events AS a
    WHERE a.tenant_id IS NULL AND a.source = 'tenant-export-finalize'
      AND a.idempotency_key = v_export::TEXT;
  IF v_audit_count <> 1 THEN RAISE EXCEPTION 'Export finalization audit is not exactly once'; END IF;

  PERFORM set_config('request.jwt.claim.role', 'authenticated', TRUE);
  PERFORM set_config('request.jwt.claim.sub', v_contact::TEXT, TRUE);
  EXECUTE 'SET LOCAL ROLE authenticated';
  IF NOT EXISTS (SELECT 1 FROM storage.objects WHERE bucket_id = 'tenant-exports' AND name = v_object_path) THEN
    RAISE EXCEPTION 'Authorized contact cannot read the finalized export';
  END IF;
  PERFORM set_config('request.jwt.claim.sub', v_other::TEXT, TRUE);
  BEGIN
    PERFORM public.get_my_tenant_export(v_export);
    RAISE EXCEPTION 'Unrelated user obtained Tenant export metadata';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
  PERFORM set_config('request.jwt.claim.sub', v_contact::TEXT, TRUE);
  v_bundle_response := public.get_my_tenant_export(v_export);
  IF v_bundle_response->>'artifactPath' <> v_object_path
     OR v_bundle_response->>'artifactSha256' <> repeat('ef', 32)
     OR (v_bundle_response->>'artifactBytes')::BIGINT <> 8 THEN
    RAISE EXCEPTION 'Authorized export metadata is incomplete or incorrect';
  END IF;
  v_final := public.record_my_tenant_export_download(v_export);
  IF v_final->>'idempotentReplay' <> 'false' OR v_final->>'firstDownloadedAt' IS NULL THEN
    RAISE EXCEPTION 'First export download was not recorded';
  END IF;
  v_final := public.record_my_tenant_export_download(v_export);
  IF v_final->>'idempotentReplay' <> 'true' THEN RAISE EXCEPTION 'Download audit replay failed'; END IF;
  PERFORM set_config('request.jwt.claim.sub', v_other::TEXT, TRUE);
  v_bundle_response := public.list_and_acknowledge_my_tenant_exports();
  IF jsonb_array_length(v_bundle_response) <> 0 THEN
    RAISE EXCEPTION 'Unrelated user received export notifications';
  END IF;
  PERFORM set_config('request.jwt.claim.sub', v_contact::TEXT, TRUE);
  v_bundle_response := public.list_and_acknowledge_my_tenant_exports();
  IF jsonb_array_length(v_bundle_response) <> 1
     OR v_bundle_response->0->>'exportId' <> v_export::TEXT
     OR v_bundle_response->0->>'tenantName' <> 'Export generation smoke'
     OR v_bundle_response->0->>'notifiedAt' IS NULL THEN
    RAISE EXCEPTION 'Authorized contact did not receive an export notification';
  END IF;
  v_final := public.list_and_acknowledge_my_tenant_exports();
  IF v_final->0->>'notifiedAt' <> v_bundle_response->0->>'notifiedAt' THEN
    RAISE EXCEPTION 'Export notification was not idempotent';
  END IF;
  EXECUTE 'RESET ROLE';
  SELECT count(*) INTO v_audit_count FROM public.audit_events AS a
    WHERE a.tenant_id IS NULL AND a.source = 'tenant-export-download'
      AND a.idempotency_key = v_export::TEXT;
  IF v_audit_count <> 1 OR NOT EXISTS (
    SELECT 1 FROM public.tenant_exports AS e WHERE e.id = v_export AND e.first_downloaded_at IS NOT NULL
  ) THEN RAISE EXCEPTION 'First export download was not audited exactly once'; END IF;
  SELECT count(*) INTO v_notification_audit_count FROM public.audit_events AS a
    WHERE a.tenant_id IS NULL AND a.source = 'tenant-export-notification'
      AND a.idempotency_key = v_export::TEXT;
  IF v_notification_audit_count <> 1 OR NOT EXISTS (
    SELECT 1 FROM public.tenant_exports AS e WHERE e.id = v_export AND e.notified_at IS NOT NULL
  ) THEN RAISE EXCEPTION 'Export notification was not audited exactly once'; END IF;
END;
$smoke$;
ROLLBACK;

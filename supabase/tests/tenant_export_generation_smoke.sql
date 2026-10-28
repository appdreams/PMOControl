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
  v_dispute JSONB;
  v_dispute_id UUID;
  v_resolution_key UUID := gen_random_uuid();
  v_hold JSONB;
  v_hold_id UUID;
  v_hold_release_key UUID := gen_random_uuid();
  v_purge JSONB;
  v_purge_key UUID := gen_random_uuid();
  v_purge_step INTEGER;
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
  VALUES (v_tenant_role, 'membership.view'), (v_tenant_role, 'tenant.export.dispute')
  ON CONFLICT DO NOTHING;
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

  v_dispute := public.file_my_tenant_export_dispute(
    v_export, 'Project dataset is incomplete',
    '{"schema_version":"1","datasets":["projects"]}'::JSONB, v_key
  );
  IF v_dispute->>'status' <> 'open' OR v_dispute->>'idempotentReplay' <> 'false' THEN
    RAISE EXCEPTION 'Authorized export contact could not file a dispute';
  END IF;
  v_dispute_id := (v_dispute->>'disputeId')::UUID;
  v_final := public.file_my_tenant_export_dispute(
    v_export, 'Project dataset is incomplete',
    '{"schema_version":"1","datasets":["projects"]}'::JSONB, v_key
  );
  IF v_final->>'idempotentReplay' <> 'true' OR (v_final->>'disputeId')::UUID <> v_dispute_id THEN
    RAISE EXCEPTION 'Export dispute replay was not idempotent';
  END IF;
  UPDATE public.tenant_exports AS e
  SET generated_at = now() - INTERVAL '100 days',
      available_at = now() - INTERVAL '100 days',
      first_downloaded_at = now() - INTERVAL '99 days',
      notified_at = now() - INTERVAL '70 days',
      purge_after = now() - INTERVAL '10 days'
  WHERE e.id = v_export;
  PERFORM set_config('request.jwt.claim.sub', v_actor::TEXT, TRUE);
  BEGIN
    PERFORM public.begin_tenant_export_purge(
      v_tenant, v_export, 3, 'Purge must wait for dispute resolution', gen_random_uuid()
    );
    RAISE EXCEPTION 'Open dispute unexpectedly allowed purge';
  EXCEPTION WHEN invalid_parameter_value THEN NULL;
  END;
  IF EXISTS (SELECT 1 FROM private.tenant_export_purge_jobs WHERE tenant_id = v_tenant)
     OR NOT EXISTS (SELECT 1 FROM public.tenants WHERE id = v_tenant AND status = 'export_ready') THEN
    RAISE EXCEPTION 'Blocked purge changed Tenant state or created a job';
  END IF;
  PERFORM set_config('request.jwt.claim.sub', v_actor::TEXT, TRUE);
  v_dispute := public.resolve_tenant_export_dispute(
    v_dispute_id, 1, 'resolved', 'Export completeness verified', v_resolution_key
  );
  IF v_dispute->>'status' <> 'resolved' OR (v_dispute->>'version')::BIGINT <> 2 THEN
    RAISE EXCEPTION 'Platform could not resolve export dispute';
  END IF;
  v_final := public.resolve_tenant_export_dispute(
    v_dispute_id, 1, 'resolved', 'Export completeness verified', v_resolution_key
  );
  IF v_final->>'idempotentReplay' <> 'true' THEN RAISE EXCEPTION 'Dispute resolution replay failed'; END IF;

  v_hold := public.apply_tenant_export_hold(
    v_tenant, v_export, '{"schema_version":"1","datasets":["projects"]}'::JSONB,
    'Preserve project data for legal review', v_key
  );
  v_hold_id := (v_hold->>'holdId')::UUID;
  IF v_hold->>'idempotentReplay' <> 'false' OR (v_hold->>'version')::BIGINT <> 1 THEN
    RAISE EXCEPTION 'Authorized platform operator could not apply a legal hold';
  END IF;
  v_final := public.apply_tenant_export_hold(
    v_tenant, v_export, '{"schema_version":"1","datasets":["projects"]}'::JSONB,
    'Preserve project data for legal review', v_key
  );
  IF v_final->>'idempotentReplay' <> 'true' OR (v_final->>'holdId')::UUID <> v_hold_id THEN
    RAISE EXCEPTION 'Legal hold application replay failed';
  END IF;
  BEGIN
    PERFORM public.begin_tenant_export_purge(
      v_tenant, v_export, 3, 'Purge must wait for legal hold release', gen_random_uuid()
    );
    RAISE EXCEPTION 'Active legal hold unexpectedly allowed purge';
  EXCEPTION WHEN invalid_parameter_value THEN NULL;
  END;
  v_hold := public.release_tenant_export_hold(
    v_hold_id, 1, 'Review completed', v_hold_release_key
  );
  IF (v_hold->>'version')::BIGINT <> 2 OR v_hold->>'releasedAt' IS NULL THEN
    RAISE EXCEPTION 'Authorized platform operator could not release a legal hold';
  END IF;
  v_final := public.release_tenant_export_hold(
    v_hold_id, 1, 'Review completed', v_hold_release_key
  );
  IF v_final->>'idempotentReplay' <> 'true' THEN RAISE EXCEPTION 'Legal hold release replay failed'; END IF;

  SELECT count(*) INTO v_audit_count FROM public.audit_events AS a
  WHERE a.source = 'tenant-export-dispute' AND a.resource_id = v_dispute_id;
  IF v_audit_count <> 1 OR NOT EXISTS (
    SELECT 1 FROM public.audit_events AS a WHERE a.source = 'tenant-export-dispute-resolution'
      AND a.resource_id = v_dispute_id AND a.idempotency_key = v_resolution_key::TEXT
  ) THEN RAISE EXCEPTION 'Dispute filing or resolution audit is missing'; END IF;
  IF (SELECT count(*) FROM public.audit_events AS a WHERE a.resource_id = v_hold_id
      AND a.source IN ('tenant-export-hold', 'tenant-export-hold-release')) <> 2
     OR NOT EXISTS (SELECT 1 FROM public.tenant_export_holds AS h
       WHERE h.id = v_hold_id AND h.released_at IS NOT NULL AND h.version = 2) THEN
    RAISE EXCEPTION 'Legal hold audit or released state is incorrect';
  END IF;

  v_purge := public.begin_tenant_export_purge(
    v_tenant, v_export, 3, 'Retention period elapsed and safeguards cleared', v_purge_key
  );
  IF v_purge->>'status' <> 'in_progress' OR v_purge->>'stage' <> 'artifact' THEN
    RAISE EXCEPTION 'Eligible Tenant purge did not start';
  END IF;
  v_final := public.begin_tenant_export_purge(
    v_tenant, v_export, 3, 'Retention period elapsed and safeguards cleared', v_purge_key
  );
  IF v_final->>'idempotentReplay' <> 'true' THEN RAISE EXCEPTION 'Purge request replay failed'; END IF;
  v_purge := public.advance_tenant_export_purge(v_tenant, 1);
  IF v_purge->>'needsArtifactRemoval' <> 'true' OR v_purge->>'stage' <> 'artifact' THEN
    RAISE EXCEPTION 'Purge worker did not request private artifact removal';
  END IF;
  -- The Storage API forbids direct SQL deletion. The transactional smoke
  -- simulates its authenticated worker checkpoint; the Edge Function performs
  -- the actual Storage API removal before calling this checkpoint.
  PERFORM set_config('request.jwt.claim.role', 'service_role', TRUE);
  EXECUTE 'SET LOCAL ROLE service_role';
  v_purge := public.confirm_tenant_export_artifact_purged(v_actor, v_tenant, v_export);
  IF v_purge->>'stage' <> 'portfolio_projects' OR v_purge->>'status' <> 'in_progress' THEN
    RAISE EXCEPTION 'Trusted worker did not checkpoint artifact removal';
  END IF;
  EXECUTE 'RESET ROLE';
  PERFORM set_config('request.jwt.claim.role', 'authenticated', TRUE);
  FOR v_purge_step IN 1..32 LOOP
    v_purge := public.advance_tenant_export_purge(v_tenant, 1);
    EXIT WHEN v_purge->>'status' = 'completed' OR v_purge->>'status' = 'blocked';
  END LOOP;
  IF v_purge->>'status' <> 'completed' THEN
    RAISE EXCEPTION 'Resumable purge did not complete after fixture batches: %', v_purge;
  END IF;
  v_final := public.advance_tenant_export_purge(v_tenant, 1);
  IF v_final->>'idempotentReplay' <> 'true' THEN RAISE EXCEPTION 'Purge completion replay failed'; END IF;
  IF NOT EXISTS (SELECT 1 FROM public.tenants AS t WHERE t.id = v_tenant
       AND t.status = 'terminated' AND t.slug = 'terminated-' || t.id::TEXT)
     OR NOT EXISTS (SELECT 1 FROM public.tenant_exports AS e WHERE e.id = v_export
       AND e.status = 'completed' AND e.contact_user_id IS NULL AND e.completed_at IS NOT NULL)
     OR EXISTS (SELECT 1 FROM public.memberships WHERE tenant_id = v_tenant)
     OR EXISTS (SELECT 1 FROM public.projects WHERE tenant_id = v_tenant)
     OR EXISTS (SELECT 1 FROM public.portfolios WHERE tenant_id = v_tenant)
     OR EXISTS (SELECT 1 FROM public.access_grants WHERE tenant_id = v_tenant)
     OR EXISTS (SELECT 1 FROM public.tenant_invitations WHERE tenant_id = v_tenant)
     OR NOT EXISTS (SELECT 1 FROM public.tenant_export_disputes WHERE id = v_dispute_id AND status = 'resolved')
     OR NOT EXISTS (SELECT 1 FROM public.tenant_export_holds WHERE id = v_hold_id AND released_at IS NOT NULL)
     OR NOT EXISTS (SELECT 1 FROM public.audit_events WHERE source = 'tenant-export-purge-complete'
       AND resource_id = v_tenant AND idempotency_key = v_tenant::TEXT) THEN
    RAISE EXCEPTION 'Tenant purge data, tombstone, or retained audit/hold state is incorrect';
  END IF;
END;
$smoke$;
ROLLBACK;

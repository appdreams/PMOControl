-- F1-11: reserve a verified export, expose an allowlisted snapshot to the
-- authorized platform operator, and finalize only an object uploaded by the
-- trusted server-side worker.

ALTER TABLE public.tenant_exports
  ADD COLUMN requested_tenant_version BIGINT NOT NULL,
  ADD CONSTRAINT tenant_exports_requested_version_positive CHECK (requested_tenant_version > 0);
CREATE UNIQUE INDEX tenant_exports_one_live_per_tenant_idx
  ON public.tenant_exports (tenant_id)
  WHERE status IN ('requested', 'generating', 'available', 'purge_eligible', 'purging');

CREATE OR REPLACE FUNCTION private.has_platform_permission_for_actor(
  p_actor_id UUID,
  p_permission_key TEXT,
  p_require_current_actor BOOLEAN
)
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = ''
AS $function$
  SELECT p_actor_id IS NOT NULL
    AND p_permission_key = 'tenant.lifecycle.terminate'
    AND (NOT p_require_current_actor OR auth.uid() = p_actor_id)
    AND EXISTS (
      SELECT 1
      FROM public.access_grants AS g
      JOIN public.roles AS r ON r.id = g.role_id
        AND r.scope_type = 'platform' AND r.tenant_id IS NULL AND r.status = 'active'
      JOIN public.role_permissions AS rp ON rp.role_id = r.id
        AND rp.permission_key = p_permission_key
      WHERE g.subject_id = p_actor_id AND g.tenant_id IS NULL
        AND g.role_scope_type = 'platform' AND g.role_tenant_id IS NULL
        AND g.scope_type = 'platform' AND g.scope_id = 'platform'
        AND g.effect = 'allow' AND g.revoked_at IS NULL
        AND g.starts_at <= pg_catalog.now()
        AND (g.expires_at IS NULL OR g.expires_at > pg_catalog.now())
    )
    AND NOT EXISTS (
      SELECT 1
      FROM public.access_grants AS g
      JOIN public.roles AS r ON r.id = g.role_id
        AND r.scope_type = 'platform' AND r.tenant_id IS NULL AND r.status = 'active'
      JOIN public.role_permissions AS rp ON rp.role_id = r.id
        AND rp.permission_key = p_permission_key
      WHERE g.subject_id = p_actor_id AND g.tenant_id IS NULL
        AND g.role_scope_type = 'platform' AND g.role_tenant_id IS NULL
        AND g.scope_type = 'platform' AND g.scope_id = 'platform'
        AND g.effect = 'deny' AND g.revoked_at IS NULL
        AND g.starts_at <= pg_catalog.now()
        AND (g.expires_at IS NULL OR g.expires_at > pg_catalog.now())
    );
$function$;

REVOKE ALL ON FUNCTION private.has_platform_permission_for_actor(UUID, TEXT, BOOLEAN)
  FROM PUBLIC, anon, authenticated, service_role;

CREATE OR REPLACE FUNCTION private.request_tenant_export(
  p_tenant_id UUID,
  p_expected_tenant_version BIGINT,
  p_contact_user_id UUID,
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
  v_export public.tenant_exports%ROWTYPE;
  v_existing_audit public.audit_events%ROWTYPE;
  v_export_id UUID;
  v_correlation_id UUID := gen_random_uuid();
  v_before JSONB;
  v_after JSONB;
BEGIN
  IF NOT private.has_platform_permission_for_actor(v_actor, 'tenant.lifecycle.terminate', TRUE) THEN
    RAISE EXCEPTION 'Platform export permission required' USING ERRCODE = '42501';
  END IF;
  IF p_tenant_id IS NULL OR p_expected_tenant_version IS NULL OR p_expected_tenant_version < 1
     OR p_contact_user_id IS NULL OR p_reason IS NULL OR p_reason <> pg_catalog.btrim(p_reason)
     OR pg_catalog.char_length(p_reason) NOT BETWEEN 1 AND 1000 OR p_idempotency_key IS NULL THEN
    RAISE EXCEPTION 'Invalid Tenant export request' USING ERRCODE = '22023';
  END IF;

  SELECT * INTO v_export FROM public.tenant_exports AS e
  WHERE e.tenant_id = p_tenant_id AND e.idempotency_key = p_idempotency_key
  FOR UPDATE;
  IF FOUND THEN
    SELECT * INTO v_existing_audit FROM public.audit_events AS a
    WHERE a.tenant_id IS NULL AND a.source = 'tenant-export-request'
      AND a.idempotency_key = p_idempotency_key::TEXT;
    IF v_export.requested_by <> v_actor OR v_export.contact_user_id <> p_contact_user_id
       OR v_export.requested_tenant_version <> p_expected_tenant_version
       OR v_existing_audit.reason IS DISTINCT FROM p_reason THEN
      RAISE EXCEPTION 'Export idempotency key payload mismatch' USING ERRCODE = '23505';
    END IF;
    RETURN pg_catalog.jsonb_build_object(
      'tenantId', v_export.tenant_id, 'exportId', v_export.id, 'status', v_export.status,
      'version', v_export.version, 'objectPath', v_export.artifact_path,
      'idempotentReplay', TRUE
    );
  END IF;

  SELECT * INTO v_tenant FROM public.tenants AS t WHERE t.id = p_tenant_id FOR UPDATE;
  IF NOT FOUND OR v_tenant.status <> 'termination_pending' THEN
    RAISE EXCEPTION 'Tenant is unavailable for export' USING ERRCODE = '22023';
  END IF;
  IF v_tenant.version <> p_expected_tenant_version THEN
    RAISE EXCEPTION 'Tenant version conflict' USING ERRCODE = '40001';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.memberships AS m
    WHERE m.tenant_id = p_tenant_id AND m.user_id = p_contact_user_id AND m.status = 'active'
  ) THEN
    RAISE EXCEPTION 'Active Tenant export contact required' USING ERRCODE = '22023';
  END IF;

  v_export_id := gen_random_uuid();
  INSERT INTO public.tenant_exports (
    id, tenant_id, requested_by, contact_user_id, status, artifact_path,
    idempotency_key, requested_tenant_version
  ) VALUES (
    v_export_id, p_tenant_id, v_actor, p_contact_user_id, 'generating',
    p_tenant_id::TEXT || '/' || v_export_id::TEXT || '.json',
    p_idempotency_key, p_expected_tenant_version
  ) RETURNING * INTO v_export;

  v_before := pg_catalog.jsonb_build_object('tenantId', p_tenant_id, 'status', v_tenant.status,
    'version', v_tenant.version);
  v_after := pg_catalog.jsonb_build_object('tenantId', p_tenant_id, 'exportId', v_export_id,
    'contactUserId', p_contact_user_id, 'status', 'generating');
  INSERT INTO public.audit_events (
    tenant_id, actor_id, actor_type, action, resource_type, resource_id,
    correlation_id, reason, before_redacted, after_redacted, source, schema_version, idempotency_key
  ) VALUES (
    NULL, v_actor, 'user', 'tenant.export.request', 'tenant_export', v_export_id,
    v_correlation_id, p_reason, v_before, v_after, 'tenant-export-request', '1', p_idempotency_key::TEXT
  );

  RETURN pg_catalog.jsonb_build_object(
    'tenantId', p_tenant_id, 'exportId', v_export_id, 'status', 'generating',
    'version', 1, 'objectPath', v_export.artifact_path, 'correlationId', v_correlation_id,
    'requestedAt', v_now, 'idempotentReplay', FALSE
  );
END;
$function$;

CREATE OR REPLACE FUNCTION private.get_tenant_export_bundle(p_export_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  v_actor UUID := auth.uid();
  v_export public.tenant_exports%ROWTYPE;
  v_tenant JSONB;
  v_profiles JSONB;
  v_memberships JSONB;
  v_invitations JSONB;
  v_roles JSONB;
  v_role_permissions JSONB;
  v_grants JSONB;
  v_portfolios JSONB;
  v_projects JSONB;
  v_associations JSONB;
  v_audit JSONB;
  v_bundle JSONB;
  v_manifest JSONB;
  v_now TIMESTAMPTZ := pg_catalog.now();
BEGIN
  IF p_export_id IS NULL OR NOT private.has_platform_permission_for_actor(
    v_actor, 'tenant.lifecycle.terminate', TRUE
  ) THEN
    RAISE EXCEPTION 'Tenant export access denied' USING ERRCODE = '42501';
  END IF;
  SELECT * INTO v_export FROM public.tenant_exports AS e WHERE e.id = p_export_id;
  IF NOT FOUND OR v_export.requested_by <> v_actor OR v_export.status <> 'generating'
     OR NOT EXISTS (
       SELECT 1 FROM public.tenants AS t
       WHERE t.id = v_export.tenant_id AND t.status = 'termination_pending'
         AND t.version = v_export.requested_tenant_version
     ) THEN
    RAISE EXCEPTION 'Tenant export snapshot is unavailable' USING ERRCODE = '42501';
  END IF;

  SELECT pg_catalog.to_jsonb(t) INTO v_tenant
  FROM public.tenants AS t WHERE t.id = v_export.tenant_id;
  SELECT COALESCE(pg_catalog.jsonb_agg(pg_catalog.to_jsonb(up) ORDER BY up.user_id), '[]'::JSONB)
    INTO v_profiles FROM public.user_profiles AS up
    WHERE up.user_id IN (SELECT m.user_id FROM public.memberships AS m WHERE m.tenant_id = v_export.tenant_id);
  SELECT COALESCE(pg_catalog.jsonb_agg(pg_catalog.to_jsonb(m) ORDER BY m.id), '[]'::JSONB)
    INTO v_memberships FROM public.memberships AS m WHERE m.tenant_id = v_export.tenant_id;
  SELECT COALESCE(pg_catalog.jsonb_agg(pg_catalog.to_jsonb(i) - 'token_hash' ORDER BY i.id), '[]'::JSONB)
    INTO v_invitations FROM public.tenant_invitations AS i WHERE i.tenant_id = v_export.tenant_id;
  SELECT COALESCE(pg_catalog.jsonb_agg(pg_catalog.to_jsonb(r) ORDER BY r.id), '[]'::JSONB)
    INTO v_roles FROM public.roles AS r WHERE r.tenant_id = v_export.tenant_id;
  SELECT COALESCE(pg_catalog.jsonb_agg(pg_catalog.to_jsonb(rp) ORDER BY rp.role_id, rp.permission_key), '[]'::JSONB)
    INTO v_role_permissions FROM public.role_permissions AS rp
    WHERE rp.role_id IN (SELECT r.id FROM public.roles AS r WHERE r.tenant_id = v_export.tenant_id);
  SELECT COALESCE(pg_catalog.jsonb_agg(pg_catalog.to_jsonb(g) ORDER BY g.id), '[]'::JSONB)
    INTO v_grants FROM public.access_grants AS g WHERE g.tenant_id = v_export.tenant_id;
  SELECT COALESCE(pg_catalog.jsonb_agg(pg_catalog.to_jsonb(p) ORDER BY p.id), '[]'::JSONB)
    INTO v_portfolios FROM public.portfolios AS p WHERE p.tenant_id = v_export.tenant_id;
  SELECT COALESCE(pg_catalog.jsonb_agg(pg_catalog.to_jsonb(p) ORDER BY p.id), '[]'::JSONB)
    INTO v_projects FROM public.projects AS p WHERE p.tenant_id = v_export.tenant_id;
  SELECT COALESCE(pg_catalog.jsonb_agg(pg_catalog.to_jsonb(a) ORDER BY a.id), '[]'::JSONB)
    INTO v_associations FROM public.portfolio_projects AS a WHERE a.tenant_id = v_export.tenant_id;
  SELECT COALESCE(pg_catalog.jsonb_agg(pg_catalog.to_jsonb(a) ORDER BY a.occurred_at, a.id), '[]'::JSONB)
    INTO v_audit FROM public.audit_events AS a
    WHERE a.tenant_id = v_export.tenant_id
      OR (a.tenant_id IS NULL AND a.resource_type IN ('tenant', 'tenant_export')
          AND a.resource_id IN (v_export.tenant_id, v_export.id));

  v_bundle := pg_catalog.jsonb_build_object(
    'schemaVersion', 'tenant-export-v1', 'tenantId', v_export.tenant_id,
    'generatedAt', v_now, 'tenant', v_tenant, 'userProfiles', v_profiles,
    'memberships', v_memberships, 'invitations', v_invitations, 'roles', v_roles,
    'rolePermissions', v_role_permissions, 'accessGrants', v_grants,
    'portfolios', v_portfolios, 'projects', v_projects,
    'portfolioProjects', v_associations, 'auditEvents', v_audit
  );
  v_manifest := pg_catalog.jsonb_build_object(
    'schemaVersion', 'tenant-export-v1', 'tenantId', v_export.tenant_id,
    'generatedAt', v_now, 'datasets', pg_catalog.jsonb_build_array(
      pg_catalog.jsonb_build_object('name', 'tenant', 'count', 1),
      pg_catalog.jsonb_build_object('name', 'userProfiles', 'count', pg_catalog.jsonb_array_length(v_profiles)),
      pg_catalog.jsonb_build_object('name', 'memberships', 'count', pg_catalog.jsonb_array_length(v_memberships)),
      pg_catalog.jsonb_build_object('name', 'invitations', 'count', pg_catalog.jsonb_array_length(v_invitations)),
      pg_catalog.jsonb_build_object('name', 'roles', 'count', pg_catalog.jsonb_array_length(v_roles)),
      pg_catalog.jsonb_build_object('name', 'rolePermissions', 'count', pg_catalog.jsonb_array_length(v_role_permissions)),
      pg_catalog.jsonb_build_object('name', 'accessGrants', 'count', pg_catalog.jsonb_array_length(v_grants)),
      pg_catalog.jsonb_build_object('name', 'portfolios', 'count', pg_catalog.jsonb_array_length(v_portfolios)),
      pg_catalog.jsonb_build_object('name', 'projects', 'count', pg_catalog.jsonb_array_length(v_projects)),
      pg_catalog.jsonb_build_object('name', 'portfolioProjects', 'count', pg_catalog.jsonb_array_length(v_associations)),
      pg_catalog.jsonb_build_object('name', 'auditEvents', 'count', pg_catalog.jsonb_array_length(v_audit))
    ),
    'excludedSecrets', pg_catalog.jsonb_build_array('tenant_invitations.token_hash', 'Auth credentials and session tokens')
  );
  RETURN pg_catalog.jsonb_build_object('bundle', v_bundle, 'manifest', v_manifest);
END;
$function$;

CREATE OR REPLACE FUNCTION private.finalize_tenant_export(
  p_actor_id UUID,
  p_export_id UUID,
  p_artifact_sha256 BYTEA,
  p_artifact_bytes BIGINT,
  p_manifest JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  v_export public.tenant_exports%ROWTYPE;
  v_tenant public.tenants%ROWTYPE;
  v_after JSONB;
  v_now TIMESTAMPTZ := pg_catalog.now();
  v_correlation_id UUID := gen_random_uuid();
BEGIN
  IF auth.role() <> 'service_role' OR NOT private.has_platform_permission_for_actor(
    p_actor_id, 'tenant.lifecycle.terminate', FALSE
  ) THEN
    RAISE EXCEPTION 'Trusted export worker required' USING ERRCODE = '42501';
  END IF;
  IF p_export_id IS NULL OR p_artifact_sha256 IS NULL OR octet_length(p_artifact_sha256) <> 32
     OR p_artifact_bytes IS NULL OR p_artifact_bytes < 1 OR p_manifest IS NULL
     OR jsonb_typeof(p_manifest) <> 'object'
     OR p_manifest ->> 'schemaVersion' <> 'tenant-export-v1' THEN
    RAISE EXCEPTION 'Invalid verified export metadata' USING ERRCODE = '22023';
  END IF;
  SELECT e.tenant_id INTO v_export.tenant_id
  FROM public.tenant_exports AS e WHERE e.id = p_export_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Tenant export unavailable' USING ERRCODE = '42501'; END IF;
  SELECT * INTO v_tenant FROM public.tenants AS t WHERE t.id = v_export.tenant_id FOR UPDATE;
  SELECT * INTO v_export FROM public.tenant_exports AS e WHERE e.id = p_export_id FOR UPDATE;
  IF v_export.requested_by <> p_actor_id THEN
    RAISE EXCEPTION 'Tenant export actor mismatch' USING ERRCODE = '42501';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM storage.objects AS o
    WHERE o.bucket_id = 'tenant-exports' AND o.name = v_export.artifact_path
      AND (o.metadata ->> 'size')::BIGINT = p_artifact_bytes
      AND o.metadata ->> 'mimetype' = 'application/json'
  ) THEN
    RAISE EXCEPTION 'Uploaded export artifact could not be verified' USING ERRCODE = '22023';
  END IF;

  IF v_export.status = 'available' THEN
    IF v_export.artifact_sha256 <> p_artifact_sha256 OR v_export.artifact_bytes <> p_artifact_bytes
       OR v_export.manifest <> p_manifest THEN
      RAISE EXCEPTION 'Finalized export payload mismatch' USING ERRCODE = '23505';
    END IF;
    RETURN pg_catalog.jsonb_build_object('tenantId', v_export.tenant_id,
      'exportId', v_export.id, 'status', v_export.status, 'availableAt', v_export.available_at,
      'purgeAfter', v_export.purge_after, 'idempotentReplay', TRUE);
  END IF;
  IF v_export.status <> 'generating' OR v_tenant.status <> 'termination_pending'
     OR v_tenant.version <> v_export.requested_tenant_version THEN
    RAISE EXCEPTION 'Tenant export finalization conflict' USING ERRCODE = '40001';
  END IF;
  UPDATE public.tenant_exports AS e
  SET status = 'available', artifact_sha256 = p_artifact_sha256,
      artifact_bytes = p_artifact_bytes, manifest = p_manifest,
      generated_at = v_now, available_at = v_now,
      purge_after = v_now + INTERVAL '90 days', version = e.version + 1
  WHERE e.id = v_export.id AND e.status = 'generating';
  IF NOT FOUND THEN RAISE EXCEPTION 'Tenant export state conflict' USING ERRCODE = '40001'; END IF;
  UPDATE public.tenants AS t SET status = 'export_ready', version = t.version + 1
  WHERE t.id = v_export.tenant_id AND t.version = v_export.requested_tenant_version;
  IF NOT FOUND THEN RAISE EXCEPTION 'Tenant export state conflict' USING ERRCODE = '40001'; END IF;

  v_after := pg_catalog.jsonb_build_object('tenantId', v_export.tenant_id,
    'exportId', v_export.id, 'status', 'available', 'availableAt', v_now,
    'purgeAfter', v_now + INTERVAL '90 days', 'artifactBytes', p_artifact_bytes,
    'sha256', encode(p_artifact_sha256, 'hex'));
  INSERT INTO public.audit_events (
    tenant_id, actor_id, actor_type, action, resource_type, resource_id,
    correlation_id, after_redacted, source, schema_version, idempotency_key
  ) VALUES (
    NULL, p_actor_id, 'user', 'tenant.export.available', 'tenant_export', v_export.id,
    v_correlation_id, v_after, 'tenant-export-finalize', '1', v_export.id::TEXT
  );
  RETURN pg_catalog.jsonb_build_object('tenantId', v_export.tenant_id,
    'exportId', v_export.id, 'status', 'available', 'availableAt', v_now,
    'purgeAfter', v_now + INTERVAL '90 days', 'idempotentReplay', FALSE);
END;
$function$;

REVOKE ALL ON FUNCTION private.request_tenant_export(UUID, BIGINT, UUID, TEXT, UUID)
  FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON FUNCTION private.get_tenant_export_bundle(UUID)
  FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON FUNCTION private.finalize_tenant_export(UUID, UUID, BYTEA, BIGINT, JSONB)
  FROM PUBLIC, anon, authenticated, service_role;
GRANT USAGE ON SCHEMA private TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION private.request_tenant_export(UUID, BIGINT, UUID, TEXT, UUID)
  TO authenticated;
GRANT EXECUTE ON FUNCTION private.get_tenant_export_bundle(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION private.finalize_tenant_export(UUID, UUID, BYTEA, BIGINT, JSONB)
  TO service_role;

CREATE OR REPLACE FUNCTION public.request_tenant_export(
  p_tenant_id UUID, p_expected_tenant_version BIGINT, p_contact_user_id UUID,
  p_reason TEXT, p_idempotency_key UUID
)
RETURNS JSONB
LANGUAGE SQL
SECURITY INVOKER
SET search_path = ''
AS $function$
  SELECT private.request_tenant_export(
    p_tenant_id, p_expected_tenant_version, p_contact_user_id, p_reason, p_idempotency_key
  );
$function$;
REVOKE ALL ON FUNCTION public.request_tenant_export(UUID, BIGINT, UUID, TEXT, UUID)
  FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.request_tenant_export(UUID, BIGINT, UUID, TEXT, UUID)
  TO authenticated;

CREATE OR REPLACE FUNCTION public.get_tenant_export_bundle(p_export_id UUID)
RETURNS JSONB
LANGUAGE SQL
SECURITY INVOKER
SET search_path = ''
AS $function$
  SELECT private.get_tenant_export_bundle(p_export_id);
$function$;
REVOKE ALL ON FUNCTION public.get_tenant_export_bundle(UUID)
  FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.get_tenant_export_bundle(UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.finalize_tenant_export(
  p_actor_id UUID, p_export_id UUID, p_artifact_sha256 BYTEA,
  p_artifact_bytes BIGINT, p_manifest JSONB
)
RETURNS JSONB
LANGUAGE SQL
SECURITY INVOKER
SET search_path = ''
AS $function$
  SELECT private.finalize_tenant_export(
    p_actor_id, p_export_id, p_artifact_sha256, p_artifact_bytes, p_manifest
  );
$function$;
REVOKE ALL ON FUNCTION public.finalize_tenant_export(UUID, UUID, BYTEA, BIGINT, JSONB)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.finalize_tenant_export(UUID, UUID, BYTEA, BIGINT, JSONB)
  TO service_role;

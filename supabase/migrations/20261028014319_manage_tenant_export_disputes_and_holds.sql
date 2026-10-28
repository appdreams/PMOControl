-- F1-11: authenticated export disputes and platform-managed legal holds.
-- The migration was named manually because the Supabase CLI is not installed
-- locally and registry access is unavailable; timestamp follows DEV history.

ALTER TABLE public.tenant_export_disputes
  ADD COLUMN idempotency_key UUID NOT NULL DEFAULT gen_random_uuid(),
  ADD COLUMN resolution_idempotency_key UUID;
CREATE UNIQUE INDEX tenant_export_disputes_idempotency_idx
  ON public.tenant_export_disputes (tenant_export_id, filed_by, idempotency_key);
CREATE UNIQUE INDEX tenant_export_disputes_resolution_idempotency_idx
  ON public.tenant_export_disputes (resolved_by, resolution_idempotency_key)
  WHERE resolution_idempotency_key IS NOT NULL;

ALTER TABLE public.tenant_export_holds
  ADD COLUMN idempotency_key UUID NOT NULL DEFAULT gen_random_uuid(),
  ADD COLUMN release_idempotency_key UUID;
CREATE UNIQUE INDEX tenant_export_holds_idempotency_idx
  ON public.tenant_export_holds (tenant_id, applied_by, idempotency_key);
CREATE UNIQUE INDEX tenant_export_holds_release_idempotency_idx
  ON public.tenant_export_holds (tenant_id, released_by, release_idempotency_key)
  WHERE release_idempotency_key IS NOT NULL;

INSERT INTO private.tenant_role_preset_permissions (catalog_version, role_key, role_name, permission_key)
VALUES ('rbac-v1', 'tenant_admin', 'Tenant Admin', 'tenant.export.dispute')
ON CONFLICT (catalog_version, role_key, permission_key) DO NOTHING;
INSERT INTO public.role_permissions (role_id, permission_key)
SELECT r.id, 'tenant.export.dispute'
FROM public.roles AS r
WHERE r.scope_type = 'tenant' AND r.status = 'active' AND r.key = 'tenant_admin'
ON CONFLICT (role_id, permission_key) DO NOTHING;
INSERT INTO public.role_permissions (role_id, permission_key)
SELECT r.id, 'tenant.export.dispute.resolve'
FROM public.roles AS r
WHERE r.scope_type = 'platform' AND r.status = 'active' AND r.key = 'platform_admin'
ON CONFLICT (role_id, permission_key) DO NOTHING;

CREATE OR REPLACE FUNCTION private.actor_has_platform_permission_key(
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
    AND p_permission_key IN ('tenant.lifecycle.terminate', 'tenant.export.dispute.resolve')
    AND (NOT p_require_current_actor OR auth.uid() = p_actor_id)
    AND EXISTS (
      SELECT 1 FROM public.access_grants AS g
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
      SELECT 1 FROM public.access_grants AS g
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
REVOKE ALL ON FUNCTION private.actor_has_platform_permission_key(UUID, TEXT, BOOLEAN)
  FROM PUBLIC, anon, authenticated, service_role;

CREATE OR REPLACE FUNCTION private.file_my_tenant_export_dispute(
  p_export_id UUID,
  p_reason TEXT,
  p_disputed_scope JSONB,
  p_idempotency_key UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  v_actor UUID := auth.uid();
  v_export public.tenant_exports%ROWTYPE;
  v_dispute public.tenant_export_disputes%ROWTYPE;
  v_now TIMESTAMPTZ := pg_catalog.now();
  v_correlation_id UUID := gen_random_uuid();
BEGIN
  IF v_actor IS NULL OR p_export_id IS NULL OR p_idempotency_key IS NULL
     OR p_reason IS NULL OR p_reason <> pg_catalog.btrim(p_reason)
     OR pg_catalog.char_length(p_reason) NOT BETWEEN 1 AND 1000
     OR p_disputed_scope IS NULL OR jsonb_typeof(p_disputed_scope) <> 'object'
     OR p_disputed_scope ->> 'schema_version' <> '1'
     OR jsonb_typeof(p_disputed_scope -> 'datasets') <> 'array'
     OR jsonb_array_length(p_disputed_scope -> 'datasets') NOT BETWEEN 1 AND 32 THEN
    RAISE EXCEPTION 'Invalid Tenant export dispute' USING ERRCODE = '22023';
  END IF;
  SELECT e.* INTO v_export FROM public.tenant_exports AS e
  JOIN public.tenants AS t ON t.id = e.tenant_id AND t.status = 'export_ready'
  JOIN public.memberships AS m ON m.tenant_id = e.tenant_id
    AND m.user_id = e.contact_user_id AND m.status = 'active'
  WHERE e.id = p_export_id AND e.contact_user_id = v_actor
    AND e.status IN ('available', 'purge_eligible') AND e.available_at IS NOT NULL
  FOR UPDATE OF e;
  IF NOT FOUND THEN RAISE EXCEPTION 'Tenant export unavailable' USING ERRCODE = '42501'; END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.access_grants AS g
    JOIN public.roles AS r ON r.id = g.role_id AND r.status = 'active'
      AND r.scope_type = 'tenant' AND r.tenant_id = v_export.tenant_id
    JOIN public.role_permissions AS rp ON rp.role_id = r.id
      AND rp.permission_key = 'tenant.export.dispute'
    WHERE g.tenant_id = v_export.tenant_id AND g.subject_id = v_actor
      AND g.scope_type = 'tenant' AND g.scope_id = v_export.tenant_id::TEXT
      AND g.role_scope_type = 'tenant' AND g.role_tenant_id = v_export.tenant_id
      AND g.effect = 'allow' AND g.revoked_at IS NULL
      AND g.starts_at <= v_now AND (g.expires_at IS NULL OR g.expires_at > v_now)
  ) OR EXISTS (
    SELECT 1 FROM public.access_grants AS g
    JOIN public.roles AS r ON r.id = g.role_id AND r.status = 'active'
      AND r.scope_type = 'tenant' AND r.tenant_id = v_export.tenant_id
    JOIN public.role_permissions AS rp ON rp.role_id = r.id
      AND rp.permission_key = 'tenant.export.dispute'
    WHERE g.tenant_id = v_export.tenant_id AND g.subject_id = v_actor
      AND g.scope_type = 'tenant' AND g.scope_id = v_export.tenant_id::TEXT
      AND g.role_scope_type = 'tenant' AND g.role_tenant_id = v_export.tenant_id
      AND g.effect = 'deny' AND g.revoked_at IS NULL
      AND g.starts_at <= v_now AND (g.expires_at IS NULL OR g.expires_at > v_now)
  ) THEN
    RAISE EXCEPTION 'Export dispute permission required' USING ERRCODE = '42501';
  END IF;

  SELECT d.* INTO v_dispute FROM public.tenant_export_disputes AS d
  WHERE d.tenant_export_id = v_export.id AND d.filed_by = v_actor
    AND d.idempotency_key = p_idempotency_key;
  IF FOUND THEN
    IF v_dispute.reason <> p_reason OR v_dispute.disputed_scope <> p_disputed_scope THEN
      RAISE EXCEPTION 'Export dispute idempotency payload mismatch' USING ERRCODE = '23505';
    END IF;
    RETURN pg_catalog.jsonb_build_object('disputeId', v_dispute.id,
      'exportId', v_export.id, 'status', v_dispute.status, 'version', v_dispute.version,
      'idempotentReplay', TRUE);
  END IF;
  IF v_export.notified_at IS NULL OR v_now > v_export.notified_at + INTERVAL '30 days' THEN
    RAISE EXCEPTION 'Export dispute window is closed' USING ERRCODE = '22023';
  END IF;
  IF EXISTS (
    SELECT 1 FROM jsonb_array_elements_text(p_disputed_scope -> 'datasets') AS selected(name)
    WHERE NOT EXISTS (
      SELECT 1 FROM jsonb_array_elements(v_export.manifest -> 'datasets') AS available(dataset)
      WHERE available.dataset ->> 'name' = selected.name
    )
  ) THEN
    RAISE EXCEPTION 'Disputed dataset is not present in the export' USING ERRCODE = '22023';
  END IF;

  INSERT INTO public.tenant_export_disputes (
    tenant_id, tenant_export_id, filed_by, reason, disputed_scope, idempotency_key
  ) VALUES (
    v_export.tenant_id, v_export.id, v_actor, p_reason, p_disputed_scope, p_idempotency_key
  ) RETURNING * INTO v_dispute;
  INSERT INTO public.audit_events (
    tenant_id, actor_id, actor_type, action, resource_type, resource_id,
    correlation_id, reason, after_redacted, source, schema_version, idempotency_key
  ) VALUES (
    NULL, v_actor, 'user', 'tenant.export.dispute.filed', 'tenant_export_dispute', v_dispute.id,
    v_correlation_id, p_reason,
    pg_catalog.jsonb_build_object('tenantId', v_export.tenant_id,
      'exportId', v_export.id, 'disputeId', v_dispute.id, 'scope', p_disputed_scope),
    'tenant-export-dispute', '1', v_dispute.id::TEXT
  );
  RETURN pg_catalog.jsonb_build_object('disputeId', v_dispute.id,
    'exportId', v_export.id, 'status', v_dispute.status, 'version', v_dispute.version,
    'filedAt', v_dispute.filed_at, 'idempotentReplay', FALSE);
END;
$function$;

CREATE OR REPLACE FUNCTION private.resolve_tenant_export_dispute(
  p_dispute_id UUID,
  p_expected_version BIGINT,
  p_outcome TEXT,
  p_resolution TEXT,
  p_idempotency_key UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  v_actor UUID := auth.uid();
  v_dispute public.tenant_export_disputes%ROWTYPE;
  v_correlation_id UUID := gen_random_uuid();
  v_now TIMESTAMPTZ := pg_catalog.now();
BEGIN
  IF NOT private.actor_has_platform_permission_key(v_actor, 'tenant.export.dispute.resolve', TRUE) THEN
    RAISE EXCEPTION 'Platform dispute resolution permission required' USING ERRCODE = '42501';
  END IF;
  IF p_dispute_id IS NULL OR p_expected_version IS NULL OR p_expected_version < 1
     OR p_outcome NOT IN ('resolved', 'rejected') OR p_resolution IS NULL
     OR p_resolution <> pg_catalog.btrim(p_resolution)
     OR pg_catalog.char_length(p_resolution) NOT BETWEEN 1 AND 1000
     OR p_idempotency_key IS NULL THEN
    RAISE EXCEPTION 'Invalid Tenant export dispute resolution' USING ERRCODE = '22023';
  END IF;
  SELECT d.* INTO v_dispute FROM public.tenant_export_disputes AS d
  WHERE d.id = p_dispute_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Dispute unavailable' USING ERRCODE = '42501'; END IF;
  IF v_dispute.status <> 'open' THEN
    IF v_dispute.resolution_idempotency_key = p_idempotency_key
       AND v_dispute.status = p_outcome AND v_dispute.resolution = p_resolution
       AND v_dispute.resolved_by = v_actor THEN
      RETURN pg_catalog.jsonb_build_object('disputeId', v_dispute.id,
        'status', v_dispute.status, 'version', v_dispute.version, 'idempotentReplay', TRUE);
    END IF;
    RAISE EXCEPTION 'Dispute is no longer open' USING ERRCODE = '40001';
  END IF;
  IF v_dispute.version <> p_expected_version THEN
    RAISE EXCEPTION 'Dispute version conflict' USING ERRCODE = '40001';
  END IF;
  UPDATE public.tenant_export_disputes AS d
  SET status = p_outcome, resolution = p_resolution, resolved_by = v_actor,
      resolved_at = v_now, resolution_idempotency_key = p_idempotency_key,
      version = d.version + 1
  WHERE d.id = v_dispute.id AND d.status = 'open' AND d.version = p_expected_version
  RETURNING * INTO v_dispute;
  IF NOT FOUND THEN RAISE EXCEPTION 'Dispute version conflict' USING ERRCODE = '40001'; END IF;
  INSERT INTO public.audit_events (
    tenant_id, actor_id, actor_type, action, resource_type, resource_id,
    correlation_id, reason, before_redacted, after_redacted,
    source, schema_version, idempotency_key
  ) VALUES (
    NULL, v_actor, 'user', 'tenant.export.dispute.' || p_outcome,
    'tenant_export_dispute', v_dispute.id, v_correlation_id, p_resolution,
    pg_catalog.jsonb_build_object('status', 'open', 'version', p_expected_version),
    pg_catalog.jsonb_build_object('status', p_outcome, 'version', v_dispute.version),
    'tenant-export-dispute-resolution', '1', p_idempotency_key::TEXT
  );
  RETURN pg_catalog.jsonb_build_object('disputeId', v_dispute.id,
    'status', v_dispute.status, 'version', v_dispute.version,
    'resolvedAt', v_dispute.resolved_at, 'idempotentReplay', FALSE);
END;
$function$;

CREATE OR REPLACE FUNCTION private.apply_tenant_export_hold(
  p_tenant_id UUID,
  p_export_id UUID,
  p_scope JSONB,
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
  v_hold public.tenant_export_holds%ROWTYPE;
  v_export public.tenant_exports%ROWTYPE;
  v_correlation_id UUID := gen_random_uuid();
BEGIN
  IF NOT private.has_platform_permission_for_actor(v_actor, 'tenant.lifecycle.terminate', TRUE) THEN
    RAISE EXCEPTION 'Platform lifecycle permission required' USING ERRCODE = '42501';
  END IF;
  IF p_tenant_id IS NULL OR p_idempotency_key IS NULL OR p_reason IS NULL
     OR p_reason <> pg_catalog.btrim(p_reason)
     OR pg_catalog.char_length(p_reason) NOT BETWEEN 1 AND 1000
     OR p_scope IS NULL OR jsonb_typeof(p_scope) <> 'object'
     OR p_scope ->> 'schema_version' <> '1'
     OR jsonb_typeof(p_scope -> 'datasets') <> 'array'
     OR jsonb_array_length(p_scope -> 'datasets') NOT BETWEEN 1 AND 32 THEN
    RAISE EXCEPTION 'Invalid Tenant export hold' USING ERRCODE = '22023';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.tenants AS t WHERE t.id = p_tenant_id) THEN
    RAISE EXCEPTION 'Tenant unavailable' USING ERRCODE = '42501';
  END IF;
  IF p_export_id IS NOT NULL THEN
    SELECT e.* INTO v_export FROM public.tenant_exports AS e
    WHERE e.id = p_export_id AND e.tenant_id = p_tenant_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Tenant export unavailable' USING ERRCODE = '42501'; END IF;
    IF EXISTS (
      SELECT 1 FROM jsonb_array_elements_text(p_scope -> 'datasets') AS selected(name)
      WHERE selected.name <> '*'
        AND NOT EXISTS (
          SELECT 1 FROM jsonb_array_elements(v_export.manifest -> 'datasets') AS available(dataset)
          WHERE available.dataset ->> 'name' = selected.name
        )
    ) THEN RAISE EXCEPTION 'Hold dataset is not present in the export' USING ERRCODE = '22023'; END IF;
  ELSIF EXISTS (
    SELECT 1 FROM jsonb_array_elements_text(p_scope -> 'datasets') AS selected(name)
    WHERE selected.name <> '*'
      AND selected.name NOT IN ('tenant', 'userProfiles', 'memberships', 'invitations', 'roles',
        'rolePermissions', 'accessGrants', 'portfolios', 'projects', 'portfolioProjects', 'auditEvents')
  ) THEN
    RAISE EXCEPTION 'Unknown hold dataset' USING ERRCODE = '22023';
  END IF;
  SELECT h.* INTO v_hold FROM public.tenant_export_holds AS h
  WHERE h.tenant_id = p_tenant_id AND h.applied_by = v_actor
    AND h.idempotency_key = p_idempotency_key;
  IF FOUND THEN
    IF v_hold.tenant_export_id IS DISTINCT FROM p_export_id OR v_hold.scope <> p_scope
       OR v_hold.reason <> p_reason THEN
      RAISE EXCEPTION 'Hold idempotency payload mismatch' USING ERRCODE = '23505';
    END IF;
    RETURN pg_catalog.jsonb_build_object('holdId', v_hold.id, 'tenantId', v_hold.tenant_id,
      'version', v_hold.version, 'releasedAt', v_hold.released_at, 'idempotentReplay', TRUE);
  END IF;
  INSERT INTO public.tenant_export_holds (
    tenant_id, tenant_export_id, scope, reason, applied_by, idempotency_key
  ) VALUES (
    p_tenant_id, p_export_id, p_scope, p_reason, v_actor, p_idempotency_key
  ) RETURNING * INTO v_hold;
  INSERT INTO public.audit_events (
    tenant_id, actor_id, actor_type, action, resource_type, resource_id,
    correlation_id, reason, after_redacted, source, schema_version, idempotency_key
  ) VALUES (
    NULL, v_actor, 'user', 'tenant.export.hold.applied', 'tenant_export_hold', v_hold.id,
    v_correlation_id, p_reason,
    pg_catalog.jsonb_build_object('tenantId', p_tenant_id, 'exportId', p_export_id,
      'holdId', v_hold.id, 'scope', p_scope),
    'tenant-export-hold', '1', v_hold.id::TEXT
  );
  RETURN pg_catalog.jsonb_build_object('holdId', v_hold.id, 'tenantId', p_tenant_id,
    'version', v_hold.version, 'appliedAt', v_hold.applied_at, 'idempotentReplay', FALSE);
END;
$function$;

CREATE OR REPLACE FUNCTION private.release_tenant_export_hold(
  p_hold_id UUID,
  p_expected_version BIGINT,
  p_release_reason TEXT,
  p_idempotency_key UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  v_actor UUID := auth.uid();
  v_hold public.tenant_export_holds%ROWTYPE;
  v_now TIMESTAMPTZ := pg_catalog.now();
  v_correlation_id UUID := gen_random_uuid();
BEGIN
  IF NOT private.has_platform_permission_for_actor(v_actor, 'tenant.lifecycle.terminate', TRUE) THEN
    RAISE EXCEPTION 'Platform lifecycle permission required' USING ERRCODE = '42501';
  END IF;
  IF p_hold_id IS NULL OR p_expected_version IS NULL OR p_expected_version < 1
     OR p_release_reason IS NULL OR p_release_reason <> pg_catalog.btrim(p_release_reason)
     OR pg_catalog.char_length(p_release_reason) NOT BETWEEN 1 AND 1000
     OR p_idempotency_key IS NULL THEN
    RAISE EXCEPTION 'Invalid Tenant export hold release' USING ERRCODE = '22023';
  END IF;
  SELECT h.* INTO v_hold FROM public.tenant_export_holds AS h
  WHERE h.id = p_hold_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Hold unavailable' USING ERRCODE = '42501'; END IF;
  IF v_hold.release_idempotency_key = p_idempotency_key
     AND v_hold.release_reason = p_release_reason AND v_hold.released_by = v_actor THEN
    RETURN pg_catalog.jsonb_build_object('holdId', v_hold.id, 'version', v_hold.version,
      'releasedAt', v_hold.released_at, 'idempotentReplay', TRUE);
  END IF;
  IF v_hold.released_at IS NOT NULL OR v_hold.version <> p_expected_version THEN
    RAISE EXCEPTION 'Hold version conflict' USING ERRCODE = '40001';
  END IF;
  UPDATE public.tenant_export_holds AS h
  SET release_reason = p_release_reason, released_by = v_actor, released_at = v_now,
      release_idempotency_key = p_idempotency_key, version = h.version + 1
  WHERE h.id = p_hold_id AND h.released_at IS NULL AND h.version = p_expected_version
  RETURNING * INTO v_hold;
  IF NOT FOUND THEN RAISE EXCEPTION 'Hold version conflict' USING ERRCODE = '40001'; END IF;
  INSERT INTO public.audit_events (
    tenant_id, actor_id, actor_type, action, resource_type, resource_id,
    correlation_id, reason, before_redacted, after_redacted,
    source, schema_version, idempotency_key
  ) VALUES (
    NULL, v_actor, 'user', 'tenant.export.hold.released', 'tenant_export_hold', v_hold.id,
    v_correlation_id, p_release_reason,
    pg_catalog.jsonb_build_object('version', p_expected_version, 'active', TRUE),
    pg_catalog.jsonb_build_object('version', v_hold.version, 'active', FALSE),
    'tenant-export-hold-release', '1', p_idempotency_key::TEXT
  );
  RETURN pg_catalog.jsonb_build_object('holdId', v_hold.id, 'version', v_hold.version,
    'releasedAt', v_hold.released_at, 'idempotentReplay', FALSE);
END;
$function$;

REVOKE ALL ON FUNCTION private.file_my_tenant_export_dispute(UUID, TEXT, JSONB, UUID)
  FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON FUNCTION private.resolve_tenant_export_dispute(UUID, BIGINT, TEXT, TEXT, UUID)
  FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON FUNCTION private.apply_tenant_export_hold(UUID, UUID, JSONB, TEXT, UUID)
  FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON FUNCTION private.release_tenant_export_hold(UUID, BIGINT, TEXT, UUID)
  FROM PUBLIC, anon, authenticated, service_role;
GRANT USAGE ON SCHEMA private TO authenticated;
GRANT EXECUTE ON FUNCTION private.file_my_tenant_export_dispute(UUID, TEXT, JSONB, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION private.resolve_tenant_export_dispute(UUID, BIGINT, TEXT, TEXT, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION private.apply_tenant_export_hold(UUID, UUID, JSONB, TEXT, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION private.release_tenant_export_hold(UUID, BIGINT, TEXT, UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.file_my_tenant_export_dispute(
  p_export_id UUID, p_reason TEXT, p_disputed_scope JSONB, p_idempotency_key UUID
)
RETURNS JSONB LANGUAGE SQL SECURITY INVOKER SET search_path = ''
AS $function$ SELECT private.file_my_tenant_export_dispute(
  p_export_id, p_reason, p_disputed_scope, p_idempotency_key
) $function$;
REVOKE ALL ON FUNCTION public.file_my_tenant_export_dispute(UUID, TEXT, JSONB, UUID)
  FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.file_my_tenant_export_dispute(UUID, TEXT, JSONB, UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.resolve_tenant_export_dispute(
  p_dispute_id UUID, p_expected_version BIGINT, p_outcome TEXT,
  p_resolution TEXT, p_idempotency_key UUID
)
RETURNS JSONB LANGUAGE SQL SECURITY INVOKER SET search_path = ''
AS $function$ SELECT private.resolve_tenant_export_dispute(
  p_dispute_id, p_expected_version, p_outcome, p_resolution, p_idempotency_key
) $function$;
REVOKE ALL ON FUNCTION public.resolve_tenant_export_dispute(UUID, BIGINT, TEXT, TEXT, UUID)
  FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.resolve_tenant_export_dispute(UUID, BIGINT, TEXT, TEXT, UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.apply_tenant_export_hold(
  p_tenant_id UUID, p_export_id UUID, p_scope JSONB, p_reason TEXT, p_idempotency_key UUID
)
RETURNS JSONB LANGUAGE SQL SECURITY INVOKER SET search_path = ''
AS $function$ SELECT private.apply_tenant_export_hold(
  p_tenant_id, p_export_id, p_scope, p_reason, p_idempotency_key
) $function$;
REVOKE ALL ON FUNCTION public.apply_tenant_export_hold(UUID, UUID, JSONB, TEXT, UUID)
  FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.apply_tenant_export_hold(UUID, UUID, JSONB, TEXT, UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.release_tenant_export_hold(
  p_hold_id UUID, p_expected_version BIGINT, p_release_reason TEXT, p_idempotency_key UUID
)
RETURNS JSONB LANGUAGE SQL SECURITY INVOKER SET search_path = ''
AS $function$ SELECT private.release_tenant_export_hold(
  p_hold_id, p_expected_version, p_release_reason, p_idempotency_key
) $function$;
REVOKE ALL ON FUNCTION public.release_tenant_export_hold(UUID, BIGINT, TEXT, UUID)
  FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.release_tenant_export_hold(UUID, BIGINT, TEXT, UUID) TO authenticated;

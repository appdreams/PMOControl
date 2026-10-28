-- F1-11: resumable, auditable Tenant data purge after verified export,
-- completed notification/dispute window, and release of legal holds.
-- Timestamp was assigned manually because the Supabase CLI is unavailable
-- locally (package registry access is blocked); it follows the DEV version.

ALTER TABLE public.tenant_exports ALTER COLUMN contact_user_id DROP NOT NULL;

CREATE TABLE private.tenant_export_purge_jobs (
  tenant_id UUID PRIMARY KEY REFERENCES public.tenants (id) ON DELETE RESTRICT,
  tenant_export_id UUID NOT NULL,
  requested_by UUID NOT NULL REFERENCES auth.users (id) ON DELETE RESTRICT,
  idempotency_key UUID NOT NULL,
  reason TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'in_progress',
  stage TEXT NOT NULL DEFAULT 'artifact',
  blocked_code TEXT,
  attempt_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  completed_at TIMESTAMPTZ,
  version BIGINT NOT NULL DEFAULT 1,
  CONSTRAINT tenant_export_purge_job_export_fk
    FOREIGN KEY (tenant_id, tenant_export_id)
    REFERENCES public.tenant_exports (tenant_id, id) ON DELETE RESTRICT,
  CONSTRAINT tenant_export_purge_job_status CHECK (status IN ('in_progress', 'blocked', 'completed')),
  CONSTRAINT tenant_export_purge_job_stage CHECK (stage IN (
    'artifact', 'portfolio_projects', 'access_grants', 'projects', 'portfolios',
    'invitations', 'role_permissions', 'roles', 'memberships', 'export_contact', 'finalize'
  )),
  CONSTRAINT tenant_export_purge_job_block CHECK (
    (status = 'blocked') = (blocked_code IS NOT NULL)
  ),
  CONSTRAINT tenant_export_purge_job_completion CHECK (
    (status = 'completed') = (completed_at IS NOT NULL)
  ),
  CONSTRAINT tenant_export_purge_job_version CHECK (version > 0),
  CONSTRAINT tenant_export_purge_job_attempts CHECK (attempt_count >= 0),
  CONSTRAINT tenant_export_purge_job_reason CHECK (
    reason = btrim(reason) AND char_length(reason) BETWEEN 1 AND 1000
  )
);
ALTER TABLE private.tenant_export_purge_jobs ENABLE ROW LEVEL SECURITY;
REVOKE ALL PRIVILEGES ON TABLE private.tenant_export_purge_jobs FROM PUBLIC, anon, authenticated, service_role;

CREATE OR REPLACE FUNCTION private.tenant_export_purge_stage_datasets(p_stage TEXT)
RETURNS TEXT[]
LANGUAGE SQL
IMMUTABLE
SET search_path = ''
AS $function$
  SELECT CASE p_stage
    WHEN 'artifact' THEN ARRAY['*']::TEXT[]
    WHEN 'portfolio_projects' THEN ARRAY['portfolioProjects', 'projects', 'portfolios']::TEXT[]
    WHEN 'access_grants' THEN ARRAY['accessGrants', 'roles', 'rolePermissions']::TEXT[]
    WHEN 'projects' THEN ARRAY['projects']::TEXT[]
    WHEN 'portfolios' THEN ARRAY['portfolios']::TEXT[]
    WHEN 'invitations' THEN ARRAY['invitations']::TEXT[]
    WHEN 'role_permissions' THEN ARRAY['rolePermissions']::TEXT[]
    WHEN 'roles' THEN ARRAY['roles']::TEXT[]
    WHEN 'memberships' THEN ARRAY['memberships']::TEXT[]
    WHEN 'export_contact' THEN ARRAY['memberships', 'userProfiles']::TEXT[]
    WHEN 'finalize' THEN ARRAY['tenant']::TEXT[]
    ELSE ARRAY['*']::TEXT[]
  END;
$function$;
REVOKE ALL ON FUNCTION private.tenant_export_purge_stage_datasets(TEXT)
  FROM PUBLIC, anon, authenticated, service_role;

CREATE OR REPLACE FUNCTION private.tenant_export_purge_block_reason(
  p_tenant_id UUID, p_export_id UUID, p_stage TEXT
)
RETURNS TEXT
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = ''
AS $function$
  SELECT CASE
    WHEN EXISTS (
      SELECT 1 FROM public.tenant_export_holds AS h
      WHERE h.tenant_id = p_tenant_id AND h.released_at IS NULL
        AND (h.tenant_export_id IS NULL OR h.tenant_export_id = p_export_id)
        AND EXISTS (
          SELECT 1 FROM jsonb_array_elements_text(h.scope -> 'datasets') AS held(dataset)
          WHERE held.dataset = '*'
             OR p_stage = 'artifact'
             OR held.dataset = ANY(private.tenant_export_purge_stage_datasets(p_stage))
        )
    ) THEN 'LEGAL_HOLD'
    WHEN EXISTS (
      SELECT 1 FROM public.tenant_export_disputes AS d
      WHERE d.tenant_id = p_tenant_id AND d.tenant_export_id = p_export_id AND d.status = 'open'
        AND (p_stage = 'artifact' OR EXISTS (
          SELECT 1 FROM jsonb_array_elements_text(d.disputed_scope -> 'datasets') AS disputed(dataset)
          WHERE disputed.dataset = ANY(private.tenant_export_purge_stage_datasets(p_stage))
        ))
    ) THEN 'OPEN_DISPUTE'
    ELSE NULL
  END;
$function$;
REVOKE ALL ON FUNCTION private.tenant_export_purge_block_reason(UUID, UUID, TEXT)
  FROM PUBLIC, anon, authenticated, service_role;

CREATE OR REPLACE FUNCTION private.begin_tenant_export_purge(
  p_tenant_id UUID,
  p_export_id UUID,
  p_expected_tenant_version BIGINT,
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
  v_tenant public.tenants%ROWTYPE;
  v_export public.tenant_exports%ROWTYPE;
  v_job private.tenant_export_purge_jobs%ROWTYPE;
  v_now TIMESTAMPTZ := pg_catalog.now();
  v_correlation_id UUID := gen_random_uuid();
BEGIN
  IF NOT private.has_platform_permission_for_actor(v_actor, 'tenant.lifecycle.terminate', TRUE) THEN
    RAISE EXCEPTION 'Platform lifecycle permission required' USING ERRCODE = '42501';
  END IF;
  IF p_tenant_id IS NULL OR p_export_id IS NULL OR p_expected_tenant_version IS NULL
     OR p_expected_tenant_version < 1 OR p_idempotency_key IS NULL OR p_reason IS NULL
     OR p_reason <> pg_catalog.btrim(p_reason)
     OR pg_catalog.char_length(p_reason) NOT BETWEEN 1 AND 1000 THEN
    RAISE EXCEPTION 'Invalid Tenant purge request' USING ERRCODE = '22023';
  END IF;

  SELECT * INTO v_tenant FROM public.tenants AS t WHERE t.id = p_tenant_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Tenant unavailable' USING ERRCODE = '42501'; END IF;
  SELECT * INTO v_job FROM private.tenant_export_purge_jobs AS j
  WHERE j.tenant_id = p_tenant_id FOR UPDATE;
  IF FOUND THEN
    IF v_job.idempotency_key <> p_idempotency_key OR v_job.requested_by <> v_actor
       OR v_job.tenant_export_id <> p_export_id OR v_job.reason <> p_reason THEN
      RAISE EXCEPTION 'Tenant purge idempotency payload mismatch' USING ERRCODE = '23505';
    END IF;
    RETURN pg_catalog.jsonb_build_object('tenantId', p_tenant_id,
      'exportId', v_job.tenant_export_id, 'status', v_job.status, 'stage', v_job.stage,
      'version', v_job.version, 'blockedCode', v_job.blocked_code, 'idempotentReplay', TRUE);
  END IF;
  IF v_tenant.status <> 'export_ready' OR v_tenant.version <> p_expected_tenant_version THEN
    RAISE EXCEPTION 'Tenant purge state or version conflict' USING ERRCODE = '40001';
  END IF;
  SELECT * INTO v_export FROM public.tenant_exports AS e
  WHERE e.id = p_export_id AND e.tenant_id = p_tenant_id FOR UPDATE;
  IF NOT FOUND OR v_export.status NOT IN ('available', 'purge_eligible')
     OR v_export.available_at IS NULL OR v_export.notified_at IS NULL
     OR v_now < v_export.purge_after OR v_now < v_export.notified_at + INTERVAL '30 days' THEN
    RAISE EXCEPTION 'Tenant export retention or notification window is not complete' USING ERRCODE = '22023';
  END IF;
  IF EXISTS (SELECT 1 FROM public.tenant_export_disputes AS d
      WHERE d.tenant_id = p_tenant_id AND d.tenant_export_id = p_export_id AND d.status = 'open')
     OR EXISTS (SELECT 1 FROM public.tenant_export_holds AS h
      WHERE h.tenant_id = p_tenant_id AND h.released_at IS NULL) THEN
    RAISE EXCEPTION 'Open dispute or legal hold blocks Tenant purge' USING ERRCODE = '22023';
  END IF;

  INSERT INTO private.tenant_export_purge_jobs (
    tenant_id, tenant_export_id, requested_by, idempotency_key, reason
  ) VALUES (p_tenant_id, p_export_id, v_actor, p_idempotency_key, p_reason)
  RETURNING * INTO v_job;
  UPDATE public.tenant_exports AS e SET status = 'purge_eligible', version = e.version + 1
  WHERE e.id = p_export_id AND e.tenant_id = p_tenant_id;
  UPDATE public.tenants AS t SET status = 'purging', version = t.version + 1
  WHERE t.id = p_tenant_id AND t.status = 'export_ready' AND t.version = p_expected_tenant_version;
  IF NOT FOUND THEN RAISE EXCEPTION 'Tenant purge state conflict' USING ERRCODE = '40001'; END IF;
  INSERT INTO public.audit_events (
    tenant_id, actor_id, actor_type, action, resource_type, resource_id,
    correlation_id, reason, before_redacted, after_redacted,
    source, schema_version, idempotency_key
  ) VALUES (
    NULL, v_actor, 'user', 'tenant.purge.requested', 'tenant', p_tenant_id,
    v_correlation_id, p_reason,
    pg_catalog.jsonb_build_object('status', 'export_ready', 'version', v_tenant.version),
    pg_catalog.jsonb_build_object('status', 'purging', 'exportId', p_export_id,
      'stage', 'artifact', 'retentionElapsed', TRUE),
    'tenant-export-purge', '1', p_idempotency_key::TEXT
  );
  RETURN pg_catalog.jsonb_build_object('tenantId', p_tenant_id, 'exportId', p_export_id,
    'status', 'in_progress', 'stage', 'artifact', 'version', v_job.version,
    'idempotentReplay', FALSE);
END;
$function$;

CREATE OR REPLACE FUNCTION private.get_tenant_export_purge_artifact(p_tenant_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  v_actor UUID := auth.uid();
  v_job private.tenant_export_purge_jobs%ROWTYPE;
  v_export public.tenant_exports%ROWTYPE;
  v_block TEXT;
BEGIN
  IF NOT private.has_platform_permission_for_actor(v_actor, 'tenant.lifecycle.terminate', TRUE) THEN
    RAISE EXCEPTION 'Platform lifecycle permission required' USING ERRCODE = '42501';
  END IF;
  SELECT * INTO v_job FROM private.tenant_export_purge_jobs AS j
  WHERE j.tenant_id = p_tenant_id FOR UPDATE;
  IF NOT FOUND OR v_job.status = 'completed' THEN
    RAISE EXCEPTION 'Purge artifact unavailable' USING ERRCODE = '42501';
  END IF;
  IF v_job.stage <> 'artifact' THEN
    RETURN pg_catalog.jsonb_build_object('tenantId', p_tenant_id,
      'exportId', v_job.tenant_export_id, 'alreadyRemoved', TRUE);
  END IF;
  v_block := private.tenant_export_purge_block_reason(
    p_tenant_id, v_job.tenant_export_id, 'artifact'
  );
  IF v_block IS NOT NULL THEN
    UPDATE private.tenant_export_purge_jobs AS j
    SET status = 'blocked', blocked_code = v_block, updated_at = pg_catalog.now(), version = j.version + 1
    WHERE j.tenant_id = p_tenant_id;
    RETURN pg_catalog.jsonb_build_object('tenantId', p_tenant_id,
      'exportId', v_job.tenant_export_id, 'blockedCode', v_block);
  END IF;
  SELECT * INTO v_export FROM public.tenant_exports AS e
  WHERE e.id = v_job.tenant_export_id AND e.tenant_id = p_tenant_id;
  RETURN pg_catalog.jsonb_build_object('tenantId', p_tenant_id,
    'exportId', v_export.id, 'artifactBucket', v_export.artifact_bucket,
    'artifactPath', v_export.artifact_path);
END;
$function$;

CREATE OR REPLACE FUNCTION private.confirm_tenant_export_artifact_purged(
  p_actor_id UUID, p_tenant_id UUID, p_export_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  v_job private.tenant_export_purge_jobs%ROWTYPE;
  v_role TEXT := COALESCE(current_setting('request.jwt.claim.role', TRUE),
    current_setting('request.jwt.claims', TRUE)::JSONB ->> 'role');
BEGIN
  IF v_role <> 'service_role' OR NOT private.has_platform_permission_for_actor(
    p_actor_id, 'tenant.lifecycle.terminate', FALSE
  ) THEN
    RAISE EXCEPTION 'Trusted purge worker required' USING ERRCODE = '42501';
  END IF;
  SELECT * INTO v_job FROM private.tenant_export_purge_jobs AS j
  WHERE j.tenant_id = p_tenant_id FOR UPDATE;
  IF NOT FOUND OR v_job.tenant_export_id <> p_export_id THEN
    RAISE EXCEPTION 'Purge job unavailable' USING ERRCODE = '42501';
  END IF;
  IF v_job.stage <> 'artifact' THEN
    RETURN pg_catalog.jsonb_build_object('tenantId', p_tenant_id,
      'exportId', p_export_id, 'status', v_job.status,
      'stage', v_job.stage, 'idempotentReplay', TRUE);
  END IF;
  UPDATE private.tenant_export_purge_jobs AS j
  SET stage = 'portfolio_projects', status = 'in_progress', blocked_code = NULL,
      attempt_count = j.attempt_count + 1, updated_at = pg_catalog.now(), version = j.version + 1
  WHERE j.tenant_id = p_tenant_id AND j.stage = 'artifact'
  RETURNING * INTO v_job;
  RETURN pg_catalog.jsonb_build_object('tenantId', p_tenant_id,
    'exportId', p_export_id, 'status', v_job.status,
    'stage', v_job.stage, 'idempotentReplay', FALSE);
END;
$function$;

CREATE OR REPLACE FUNCTION private.advance_tenant_export_purge(
  p_tenant_id UUID, p_batch_size INTEGER DEFAULT 500
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  v_actor UUID := auth.uid();
  v_tenant public.tenants%ROWTYPE;
  v_job private.tenant_export_purge_jobs%ROWTYPE;
  v_deleted INTEGER := 0;
  v_block TEXT;
  v_next_stage TEXT;
  v_datasets TEXT[];
  v_correlation_id UUID := gen_random_uuid();
BEGIN
  IF NOT private.has_platform_permission_for_actor(v_actor, 'tenant.lifecycle.terminate', TRUE) THEN
    RAISE EXCEPTION 'Platform lifecycle permission required' USING ERRCODE = '42501';
  END IF;
  IF p_tenant_id IS NULL OR p_batch_size NOT BETWEEN 1 AND 1000 THEN
    RAISE EXCEPTION 'Invalid Tenant purge batch' USING ERRCODE = '22023';
  END IF;
  SELECT * INTO v_tenant FROM public.tenants AS t WHERE t.id = p_tenant_id FOR UPDATE;
  SELECT * INTO v_job FROM private.tenant_export_purge_jobs AS j
  WHERE j.tenant_id = p_tenant_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Purge job unavailable' USING ERRCODE = '42501'; END IF;
  IF v_job.status = 'completed' THEN
    RETURN pg_catalog.jsonb_build_object('tenantId', p_tenant_id,
      'exportId', v_job.tenant_export_id, 'status', v_job.status,
      'stage', v_job.stage, 'idempotentReplay', TRUE);
  END IF;
  IF v_tenant.status <> 'purging' THEN RAISE EXCEPTION 'Tenant is not in purge state' USING ERRCODE = '40001'; END IF;
  IF v_job.stage = 'artifact' THEN
    v_block := private.tenant_export_purge_block_reason(
      p_tenant_id, v_job.tenant_export_id, 'artifact'
    );
    IF v_block IS NOT NULL THEN
      UPDATE private.tenant_export_purge_jobs AS j
      SET status = 'blocked', blocked_code = v_block, updated_at = pg_catalog.now(), version = j.version + 1
      WHERE j.tenant_id = p_tenant_id;
      RETURN pg_catalog.jsonb_build_object('tenantId', p_tenant_id,
        'exportId', v_job.tenant_export_id, 'status', 'blocked', 'stage', v_job.stage,
        'blockedCode', v_block, 'idempotentReplay', FALSE);
    END IF;
    IF v_job.status = 'blocked' THEN
      UPDATE private.tenant_export_purge_jobs AS j
      SET status = 'in_progress', blocked_code = NULL, updated_at = pg_catalog.now(), version = j.version + 1
      WHERE j.tenant_id = p_tenant_id;
    END IF;
    RETURN pg_catalog.jsonb_build_object('tenantId', p_tenant_id,
      'exportId', v_job.tenant_export_id, 'status', 'in_progress', 'stage', 'artifact',
      'needsArtifactRemoval', TRUE, 'idempotentReplay', FALSE);
  END IF;

  v_block := private.tenant_export_purge_block_reason(
    p_tenant_id, v_job.tenant_export_id, v_job.stage
  );
  IF v_block IS NOT NULL THEN
    UPDATE private.tenant_export_purge_jobs AS j
    SET status = 'blocked', blocked_code = v_block, updated_at = pg_catalog.now(), version = j.version + 1
    WHERE j.tenant_id = p_tenant_id;
    RETURN pg_catalog.jsonb_build_object('tenantId', p_tenant_id,
      'exportId', v_job.tenant_export_id, 'status', 'blocked', 'stage', v_job.stage,
      'blockedCode', v_block, 'idempotentReplay', FALSE);
  END IF;
  IF v_job.status = 'blocked' THEN
    UPDATE private.tenant_export_purge_jobs AS j
    SET status = 'in_progress', blocked_code = NULL, updated_at = pg_catalog.now(), version = j.version + 1
    WHERE j.tenant_id = p_tenant_id;
  END IF;

  CASE v_job.stage
    WHEN 'portfolio_projects' THEN
      WITH doomed AS (SELECT ctid FROM public.portfolio_projects WHERE tenant_id = p_tenant_id
        ORDER BY tenant_id LIMIT p_batch_size FOR UPDATE SKIP LOCKED)
      DELETE FROM public.portfolio_projects AS x USING doomed AS d WHERE x.ctid = d.ctid;
      GET DIAGNOSTICS v_deleted = ROW_COUNT;
      v_next_stage := 'access_grants';
    WHEN 'access_grants' THEN
      WITH doomed AS (SELECT ctid FROM public.access_grants WHERE tenant_id = p_tenant_id
        ORDER BY id LIMIT p_batch_size FOR UPDATE SKIP LOCKED)
      DELETE FROM public.access_grants AS x USING doomed AS d WHERE x.ctid = d.ctid;
      GET DIAGNOSTICS v_deleted = ROW_COUNT;
      v_next_stage := 'projects';
    WHEN 'projects' THEN
      WITH doomed AS (SELECT ctid FROM public.projects WHERE tenant_id = p_tenant_id
        ORDER BY id LIMIT p_batch_size FOR UPDATE SKIP LOCKED)
      DELETE FROM public.projects AS x USING doomed AS d WHERE x.ctid = d.ctid;
      GET DIAGNOSTICS v_deleted = ROW_COUNT;
      v_next_stage := 'portfolios';
    WHEN 'portfolios' THEN
      WITH doomed AS (SELECT ctid FROM public.portfolios WHERE tenant_id = p_tenant_id
        ORDER BY id LIMIT p_batch_size FOR UPDATE SKIP LOCKED)
      DELETE FROM public.portfolios AS x USING doomed AS d WHERE x.ctid = d.ctid;
      GET DIAGNOSTICS v_deleted = ROW_COUNT;
      v_next_stage := 'invitations';
    WHEN 'invitations' THEN
      WITH doomed AS (SELECT ctid FROM public.tenant_invitations WHERE tenant_id = p_tenant_id
        ORDER BY id LIMIT p_batch_size FOR UPDATE SKIP LOCKED)
      DELETE FROM public.tenant_invitations AS x USING doomed AS d WHERE x.ctid = d.ctid;
      GET DIAGNOSTICS v_deleted = ROW_COUNT;
      v_next_stage := 'role_permissions';
    WHEN 'role_permissions' THEN
      WITH doomed AS (
        SELECT rp.ctid FROM public.role_permissions AS rp
        JOIN public.roles AS r ON r.id = rp.role_id
        WHERE r.tenant_id = p_tenant_id ORDER BY rp.role_id, rp.permission_key
        LIMIT p_batch_size FOR UPDATE OF rp SKIP LOCKED
      )
      DELETE FROM public.role_permissions AS x USING doomed AS d WHERE x.ctid = d.ctid;
      GET DIAGNOSTICS v_deleted = ROW_COUNT;
      v_next_stage := 'roles';
    WHEN 'roles' THEN
      WITH doomed AS (SELECT ctid FROM public.roles WHERE tenant_id = p_tenant_id
        ORDER BY id LIMIT p_batch_size FOR UPDATE SKIP LOCKED)
      DELETE FROM public.roles AS x USING doomed AS d WHERE x.ctid = d.ctid;
      GET DIAGNOSTICS v_deleted = ROW_COUNT;
      v_next_stage := 'memberships';
    WHEN 'memberships' THEN
      WITH doomed AS (SELECT ctid FROM public.memberships WHERE tenant_id = p_tenant_id
        ORDER BY user_id LIMIT p_batch_size FOR UPDATE SKIP LOCKED)
      DELETE FROM public.memberships AS x USING doomed AS d WHERE x.ctid = d.ctid;
      GET DIAGNOSTICS v_deleted = ROW_COUNT;
      v_next_stage := 'export_contact';
    WHEN 'export_contact' THEN
      UPDATE public.tenant_exports AS e
      SET contact_user_id = NULL, status = 'completed', completed_at = pg_catalog.now(),
          version = e.version + 1
      WHERE e.id = v_job.tenant_export_id AND e.tenant_id = p_tenant_id
        AND e.status = 'purge_eligible' AND e.contact_user_id IS NOT NULL;
      GET DIAGNOSTICS v_deleted = ROW_COUNT;
      v_next_stage := 'finalize';
    WHEN 'finalize' THEN
      IF private.tenant_export_purge_block_reason(
        p_tenant_id, v_job.tenant_export_id, 'finalize'
      ) IS NOT NULL THEN
        UPDATE private.tenant_export_purge_jobs AS j
        SET status = 'blocked', blocked_code = 'LEGAL_HOLD', updated_at = pg_catalog.now(), version = j.version + 1
        WHERE j.tenant_id = p_tenant_id;
        RETURN pg_catalog.jsonb_build_object('tenantId', p_tenant_id,
          'status', 'blocked', 'stage', 'finalize', 'blockedCode', 'LEGAL_HOLD');
      END IF;
      UPDATE public.tenants AS t
      SET status = 'terminated', slug = 'terminated-' || t.id::TEXT,
          display_name = 'Encerrado ' || pg_catalog.left(t.id::TEXT, 8), version = t.version + 1
      WHERE t.id = p_tenant_id AND t.status = 'purging';
      IF NOT FOUND THEN RAISE EXCEPTION 'Tenant purge finalization conflict' USING ERRCODE = '40001'; END IF;
      UPDATE private.tenant_export_purge_jobs AS j
      SET status = 'completed', stage = 'finalize', blocked_code = NULL,
          completed_at = pg_catalog.now(), updated_at = pg_catalog.now(), version = j.version + 1
      WHERE j.tenant_id = p_tenant_id;
      INSERT INTO public.audit_events (
        tenant_id, actor_id, actor_type, action, resource_type, resource_id,
        correlation_id, reason, before_redacted, after_redacted,
        source, schema_version, idempotency_key
      ) VALUES (
        p_tenant_id, v_actor, 'user', 'tenant.lifecycle.terminated', 'tenant', p_tenant_id,
        v_correlation_id, v_job.reason,
        pg_catalog.jsonb_build_object('status', 'purging'),
        pg_catalog.jsonb_build_object('status', 'terminated', 'exportId', v_job.tenant_export_id,
          'tenantDataPurged', TRUE, 'auditAndLegalHoldRecordsRetained', TRUE),
        'tenant-export-purge-complete', '1', v_job.tenant_id::TEXT
      );
      RETURN pg_catalog.jsonb_build_object('tenantId', p_tenant_id,
        'exportId', v_job.tenant_export_id, 'status', 'completed',
        'stage', 'finalize', 'idempotentReplay', FALSE);
    ELSE
      RAISE EXCEPTION 'Unknown Tenant purge stage' USING ERRCODE = '22023';
  END CASE;

  IF v_deleted < p_batch_size THEN
    UPDATE private.tenant_export_purge_jobs AS j
    SET stage = v_next_stage, status = 'in_progress', blocked_code = NULL,
        attempt_count = j.attempt_count + 1, updated_at = pg_catalog.now(), version = j.version + 1
    WHERE j.tenant_id = p_tenant_id;
  ELSE
    UPDATE private.tenant_export_purge_jobs AS j
    SET status = 'in_progress', blocked_code = NULL,
        attempt_count = j.attempt_count + 1, updated_at = pg_catalog.now(), version = j.version + 1
    WHERE j.tenant_id = p_tenant_id;
  END IF;
  RETURN pg_catalog.jsonb_build_object('tenantId', p_tenant_id,
    'exportId', v_job.tenant_export_id, 'status', 'in_progress',
    'stage', CASE WHEN v_deleted < p_batch_size THEN v_next_stage ELSE v_job.stage END,
    'deletedRows', v_deleted, 'idempotentReplay', FALSE);
END;
$function$;

REVOKE ALL ON FUNCTION private.begin_tenant_export_purge(UUID, UUID, BIGINT, TEXT, UUID)
  FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON FUNCTION private.get_tenant_export_purge_artifact(UUID)
  FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON FUNCTION private.confirm_tenant_export_artifact_purged(UUID, UUID, UUID)
  FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON FUNCTION private.advance_tenant_export_purge(UUID, INTEGER)
  FROM PUBLIC, anon, authenticated, service_role;
GRANT USAGE ON SCHEMA private TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION private.begin_tenant_export_purge(UUID, UUID, BIGINT, TEXT, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION private.get_tenant_export_purge_artifact(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION private.confirm_tenant_export_artifact_purged(UUID, UUID, UUID) TO service_role;
GRANT EXECUTE ON FUNCTION private.advance_tenant_export_purge(UUID, INTEGER) TO authenticated;

CREATE OR REPLACE FUNCTION public.begin_tenant_export_purge(
  p_tenant_id UUID, p_export_id UUID, p_expected_tenant_version BIGINT,
  p_reason TEXT, p_idempotency_key UUID
)
RETURNS JSONB LANGUAGE SQL SECURITY INVOKER SET search_path = ''
AS $function$ SELECT private.begin_tenant_export_purge(
  p_tenant_id, p_export_id, p_expected_tenant_version, p_reason, p_idempotency_key
) $function$;
REVOKE ALL ON FUNCTION public.begin_tenant_export_purge(UUID, UUID, BIGINT, TEXT, UUID)
  FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.begin_tenant_export_purge(UUID, UUID, BIGINT, TEXT, UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.get_tenant_export_purge_artifact(p_tenant_id UUID)
RETURNS JSONB LANGUAGE SQL SECURITY INVOKER SET search_path = ''
AS $function$ SELECT private.get_tenant_export_purge_artifact(p_tenant_id) $function$;
REVOKE ALL ON FUNCTION public.get_tenant_export_purge_artifact(UUID)
  FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.get_tenant_export_purge_artifact(UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.confirm_tenant_export_artifact_purged(
  p_actor_id UUID, p_tenant_id UUID, p_export_id UUID
)
RETURNS JSONB LANGUAGE SQL SECURITY INVOKER SET search_path = ''
AS $function$ SELECT private.confirm_tenant_export_artifact_purged(p_actor_id, p_tenant_id, p_export_id) $function$;
REVOKE ALL ON FUNCTION public.confirm_tenant_export_artifact_purged(UUID, UUID, UUID)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.confirm_tenant_export_artifact_purged(UUID, UUID, UUID) TO service_role;

CREATE OR REPLACE FUNCTION public.advance_tenant_export_purge(
  p_tenant_id UUID, p_batch_size INTEGER DEFAULT 500
)
RETURNS JSONB LANGUAGE SQL SECURITY INVOKER SET search_path = ''
AS $function$ SELECT private.advance_tenant_export_purge(p_tenant_id, p_batch_size) $function$;
REVOKE ALL ON FUNCTION public.advance_tenant_export_purge(UUID, INTEGER)
  FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.advance_tenant_export_purge(UUID, INTEGER) TO authenticated;

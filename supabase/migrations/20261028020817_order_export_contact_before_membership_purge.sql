-- Clear export contact FK before deleting its membership to satisfy tenant_exports_contact_same_tenant_fk.
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
      v_next_stage := 'export_contact';
    WHEN 'memberships' THEN
      WITH doomed AS (SELECT ctid FROM public.memberships WHERE tenant_id = p_tenant_id
        ORDER BY user_id LIMIT p_batch_size FOR UPDATE SKIP LOCKED)
      DELETE FROM public.memberships AS x USING doomed AS d WHERE x.ctid = d.ctid;
      GET DIAGNOSTICS v_deleted = ROW_COUNT;
      v_next_stage := 'finalize';
    WHEN 'export_contact' THEN
      UPDATE public.tenant_exports AS e
      SET contact_user_id = NULL, status = 'completed', completed_at = pg_catalog.now(),
          version = e.version + 1
      WHERE e.id = v_job.tenant_export_id AND e.tenant_id = p_tenant_id
        AND e.status = 'purge_eligible' AND e.contact_user_id IS NOT NULL;
      GET DIAGNOSTICS v_deleted = ROW_COUNT;
      v_next_stage := 'memberships';
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
REVOKE ALL ON FUNCTION private.advance_tenant_export_purge(UUID, INTEGER) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION private.advance_tenant_export_purge(UUID, INTEGER) TO authenticated;
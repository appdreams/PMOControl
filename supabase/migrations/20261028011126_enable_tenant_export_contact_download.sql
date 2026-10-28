-- F1-11: authorized contact metadata lookup and audited first download.
CREATE OR REPLACE FUNCTION private.get_my_tenant_export(p_export_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  v_export public.tenant_exports%ROWTYPE;
BEGIN
  IF auth.uid() IS NULL OR p_export_id IS NULL THEN
    RAISE EXCEPTION 'Tenant export unavailable' USING ERRCODE = '42501';
  END IF;
  SELECT e.* INTO v_export
  FROM public.tenant_exports AS e
  JOIN public.tenants AS t ON t.id = e.tenant_id AND t.status = 'export_ready'
  JOIN public.memberships AS m
    ON m.tenant_id = e.tenant_id AND m.user_id = e.contact_user_id AND m.status = 'active'
  WHERE e.id = p_export_id
    AND e.contact_user_id = auth.uid()
    AND e.status IN ('available', 'purge_eligible')
    AND e.available_at IS NOT NULL;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Tenant export unavailable' USING ERRCODE = '42501';
  END IF;
  RETURN pg_catalog.jsonb_build_object(
    'tenantId', v_export.tenant_id,
    'exportId', v_export.id,
    'status', v_export.status,
    'artifactBucket', v_export.artifact_bucket,
    'artifactPath', v_export.artifact_path,
    'artifactSha256', encode(v_export.artifact_sha256, 'hex'),
    'artifactBytes', v_export.artifact_bytes,
    'availableAt', v_export.available_at,
    'firstDownloadedAt', v_export.first_downloaded_at,
    'purgeAfter', v_export.purge_after
  );
END;
$function$;

CREATE OR REPLACE FUNCTION private.record_my_tenant_export_download(p_export_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  v_actor UUID := auth.uid();
  v_export public.tenant_exports%ROWTYPE;
  v_now TIMESTAMPTZ := pg_catalog.now();
  v_correlation_id UUID := gen_random_uuid();
BEGIN
  IF v_actor IS NULL OR p_export_id IS NULL THEN
    RAISE EXCEPTION 'Tenant export unavailable' USING ERRCODE = '42501';
  END IF;
  SELECT e.* INTO v_export
  FROM public.tenant_exports AS e
  JOIN public.tenants AS t ON t.id = e.tenant_id AND t.status = 'export_ready'
  JOIN public.memberships AS m
    ON m.tenant_id = e.tenant_id AND m.user_id = e.contact_user_id AND m.status = 'active'
  WHERE e.id = p_export_id
    AND e.contact_user_id = v_actor
    AND e.status IN ('available', 'purge_eligible')
    AND e.available_at IS NOT NULL
  FOR UPDATE OF e;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Tenant export unavailable' USING ERRCODE = '42501';
  END IF;
  IF v_export.first_downloaded_at IS NOT NULL THEN
    RETURN pg_catalog.jsonb_build_object(
      'exportId', v_export.id, 'firstDownloadedAt', v_export.first_downloaded_at,
      'idempotentReplay', TRUE
    );
  END IF;

  UPDATE public.tenant_exports AS e
  SET first_downloaded_at = v_now, version = e.version + 1
  WHERE e.id = v_export.id AND e.first_downloaded_at IS NULL
  RETURNING * INTO v_export;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Tenant export download state conflict' USING ERRCODE = '40001';
  END IF;
  INSERT INTO public.audit_events (
    tenant_id, actor_id, actor_type, action, resource_type, resource_id,
    correlation_id, after_redacted, source, schema_version, idempotency_key
  ) VALUES (
    NULL, v_actor, 'user', 'tenant.export.downloaded', 'tenant_export', v_export.id,
    v_correlation_id,
    pg_catalog.jsonb_build_object('tenantId', v_export.tenant_id, 'exportId', v_export.id,
      'artifactBytes', v_export.artifact_bytes, 'sha256', encode(v_export.artifact_sha256, 'hex')),
    'tenant-export-download', '1', v_export.id::TEXT
  );
  RETURN pg_catalog.jsonb_build_object(
    'exportId', v_export.id, 'firstDownloadedAt', v_export.first_downloaded_at,
    'idempotentReplay', FALSE
  );
END;
$function$;

REVOKE ALL ON FUNCTION private.get_my_tenant_export(UUID)
  FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON FUNCTION private.record_my_tenant_export_download(UUID)
  FROM PUBLIC, anon, authenticated, service_role;
GRANT USAGE ON SCHEMA private TO authenticated;
GRANT EXECUTE ON FUNCTION private.get_my_tenant_export(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION private.record_my_tenant_export_download(UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.get_my_tenant_export(p_export_id UUID)
RETURNS JSONB
LANGUAGE SQL
SECURITY INVOKER
SET search_path = ''
AS $function$
  SELECT private.get_my_tenant_export(p_export_id);
$function$;
REVOKE ALL ON FUNCTION public.get_my_tenant_export(UUID) FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.get_my_tenant_export(UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.record_my_tenant_export_download(p_export_id UUID)
RETURNS JSONB
LANGUAGE SQL
SECURITY INVOKER
SET search_path = ''
AS $function$
  SELECT private.record_my_tenant_export_download(p_export_id);
$function$;
REVOKE ALL ON FUNCTION public.record_my_tenant_export_download(UUID) FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.record_my_tenant_export_download(UUID) TO authenticated;

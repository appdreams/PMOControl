-- F1-11: notify the authenticated export contact in the workspace.
CREATE OR REPLACE FUNCTION private.list_and_acknowledge_my_tenant_exports()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  v_actor UUID := auth.uid();
  v_export public.tenant_exports%ROWTYPE;
  v_tenant_name TEXT;
  v_correlation_id UUID;
  v_exports JSONB := '[]'::JSONB;
BEGIN
  IF v_actor IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;
  FOR v_export IN
    SELECT e.*
    FROM public.tenant_exports AS e
    JOIN public.tenants AS t ON t.id = e.tenant_id AND t.status = 'export_ready'
    JOIN public.memberships AS m
      ON m.tenant_id = e.tenant_id AND m.user_id = e.contact_user_id AND m.status = 'active'
    WHERE e.contact_user_id = v_actor
      AND e.status IN ('available', 'purge_eligible')
      AND e.available_at IS NOT NULL
    ORDER BY e.available_at DESC, e.id
    FOR UPDATE OF e
  LOOP
    SELECT t.display_name INTO v_tenant_name
    FROM public.tenants AS t WHERE t.id = v_export.tenant_id;
    IF v_export.notified_at IS NULL THEN
      UPDATE public.tenant_exports AS e
      SET notified_at = pg_catalog.now(), version = e.version + 1
      WHERE e.id = v_export.id AND e.notified_at IS NULL
      RETURNING * INTO v_export;
      IF FOUND THEN
        v_correlation_id := gen_random_uuid();
        INSERT INTO public.audit_events (
          tenant_id, actor_id, actor_type, action, resource_type, resource_id,
          correlation_id, after_redacted, source, schema_version, idempotency_key
        ) VALUES (
          NULL, v_actor, 'user', 'tenant.export.notified', 'tenant_export', v_export.id,
          v_correlation_id,
          pg_catalog.jsonb_build_object('tenantId', v_export.tenant_id,
            'exportId', v_export.id, 'notifiedAt', v_export.notified_at),
          'tenant-export-notification', '1', v_export.id::TEXT
        );
      END IF;
    END IF;
    v_exports := v_exports || pg_catalog.jsonb_build_array(pg_catalog.jsonb_build_object(
      'tenantId', v_export.tenant_id,
      'tenantName', v_tenant_name,
      'exportId', v_export.id,
      'status', v_export.status,
      'availableAt', v_export.available_at,
      'purgeAfter', v_export.purge_after,
      'artifactBytes', v_export.artifact_bytes,
      'firstDownloadedAt', v_export.first_downloaded_at,
      'notifiedAt', v_export.notified_at
    ));
  END LOOP;
  RETURN v_exports;
END;
$function$;

REVOKE ALL ON FUNCTION private.list_and_acknowledge_my_tenant_exports()
  FROM PUBLIC, anon, authenticated, service_role;
GRANT USAGE ON SCHEMA private TO authenticated;
GRANT EXECUTE ON FUNCTION private.list_and_acknowledge_my_tenant_exports() TO authenticated;

CREATE OR REPLACE FUNCTION public.list_and_acknowledge_my_tenant_exports()
RETURNS JSONB
LANGUAGE SQL
SECURITY INVOKER
SET search_path = ''
AS $function$
  SELECT private.list_and_acknowledge_my_tenant_exports();
$function$;
REVOKE ALL ON FUNCTION public.list_and_acknowledge_my_tenant_exports()
  FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.list_and_acknowledge_my_tenant_exports() TO authenticated;

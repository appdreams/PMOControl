-- One-time DEV bootstrap, executed manually by the Supabase project owner in SQL Editor.
-- Before execution: verify project ref xsznvegtaukrvvrgubnn and replace the operator email; review the reason.
-- The target must already exist in auth.users with a confirmed email address.
-- This script intentionally is not a migration and must never run in preview/production.
BEGIN;

DO $bootstrap$
DECLARE
  v_email TEXT := 'REPLACE_WITH_CONFIRMED_OPERATOR_EMAIL';
  v_reason TEXT := 'Initial platform operator bootstrap approved by the Supabase DEV project owner.';
  v_subject UUID;
  v_role UUID;
  v_grant UUID;
  v_correlation UUID := gen_random_uuid();
BEGIN
  IF v_email = 'REPLACE_WITH_CONFIRMED_OPERATOR_EMAIL'
     OR v_email <> lower(btrim(v_email)) OR position('@' IN v_email) < 2
     OR char_length(v_reason) NOT BETWEEN 1 AND 1000 THEN
    RAISE EXCEPTION 'Replace the bootstrap email with a normalized, confirmed Auth email and review the reason.';
  END IF;

  SELECT id INTO STRICT v_subject
  FROM auth.users
  WHERE lower(email) = v_email AND email_confirmed_at IS NOT NULL;

  IF EXISTS (
    SELECT 1 FROM public.access_grants
    WHERE tenant_id IS NULL AND role_scope_type = 'platform' AND revoked_at IS NULL
  ) THEN
    RAISE EXCEPTION 'Platform bootstrap is already initialized; use the reviewed grant-management workflow.';
  END IF;

  SELECT r.id INTO STRICT v_role
  FROM public.roles AS r
  JOIN public.role_permissions AS rp ON rp.role_id = r.id
  WHERE r.tenant_id IS NULL AND r.scope_type = 'platform'
    AND r.key = 'platform_admin' AND r.status = 'active'
    AND rp.permission_key = 'tenant.lifecycle.create';

  INSERT INTO public.access_grants (
    tenant_id, subject_id, role_id, role_scope_type, role_tenant_id,
    scope_type, scope_id, effect, granted_by, reason, starts_at
  ) VALUES (
    NULL, v_subject, v_role, 'platform', NULL,
    'platform', 'platform', 'allow', v_subject, v_reason, now()
  ) RETURNING id INTO v_grant;

  INSERT INTO public.audit_events (
    tenant_id, actor_id, actor_type, action, resource_type, resource_id,
    correlation_id, reason, after_redacted, source, schema_version, idempotency_key
  ) VALUES (
    NULL, v_subject, 'user', 'platform.access_grant.bootstrap', 'access_grant', v_grant,
    v_correlation, v_reason,
    jsonb_build_object(
      'roleKey', 'platform_admin', 'permissionKey', 'tenant.lifecycle.create',
      'scopeType', 'platform', 'scopeId', 'platform',
      'bootstrapChannel', 'supabase-dev-project-owner-sql-editor'
    ),
    'manual-platform-bootstrap', '1', 'bootstrap-platform-admin-v1'
  );
END;
$bootstrap$;

COMMIT;

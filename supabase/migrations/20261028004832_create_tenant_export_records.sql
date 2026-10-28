-- F1-11: private export metadata, scoped disputes/legal holds and download ACL.
-- Artifact writes are reserved for the server-side export worker; no client
-- role can upload, replace, enumerate, or remove export objects directly.

CREATE TABLE public.tenant_exports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  requested_by UUID NOT NULL REFERENCES auth.users (id) ON DELETE RESTRICT,
  contact_user_id UUID NOT NULL REFERENCES auth.users (id) ON DELETE RESTRICT,
  status TEXT NOT NULL DEFAULT 'requested',
  artifact_bucket TEXT NOT NULL DEFAULT 'tenant-exports',
  artifact_path TEXT,
  artifact_sha256 BYTEA,
  artifact_bytes BIGINT,
  manifest JSONB,
  schema_version TEXT NOT NULL DEFAULT 'tenant-export-v1',
  requested_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  generated_at TIMESTAMPTZ,
  available_at TIMESTAMPTZ,
  first_downloaded_at TIMESTAMPTZ,
  notified_at TIMESTAMPTZ,
  purge_after TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  failure_code TEXT,
  idempotency_key UUID NOT NULL,
  version BIGINT NOT NULL DEFAULT 1,
  CONSTRAINT tenant_exports_status_allowed CHECK (
    status IN ('requested', 'generating', 'available', 'purge_eligible', 'purging', 'completed', 'failed', 'cancelled')
  ),
  CONSTRAINT tenant_exports_schema_version CHECK (schema_version = 'tenant-export-v1'),
  CONSTRAINT tenant_exports_artifact_bucket CHECK (artifact_bucket = 'tenant-exports'),
  CONSTRAINT tenant_exports_path_owned CHECK (
    artifact_path IS NULL OR artifact_path = tenant_id::TEXT || '/' || id::TEXT || '.json'
  ),
  CONSTRAINT tenant_exports_checksum_size CHECK (
    (artifact_sha256 IS NULL AND artifact_bytes IS NULL)
    OR (octet_length(artifact_sha256) = 32 AND artifact_bytes > 0)
  ),
  CONSTRAINT tenant_exports_manifest_object CHECK (manifest IS NULL OR jsonb_typeof(manifest) = 'object'),
  CONSTRAINT tenant_exports_ready_consistent CHECK (
    (available_at IS NULL AND purge_after IS NULL)
    OR (available_at IS NOT NULL AND purge_after = available_at + INTERVAL '90 days'
        AND generated_at IS NOT NULL AND artifact_path IS NOT NULL
        AND artifact_sha256 IS NOT NULL AND artifact_bytes IS NOT NULL AND manifest IS NOT NULL)
  ),
  CONSTRAINT tenant_exports_available_state_consistent CHECK (
    status NOT IN ('available', 'purge_eligible', 'purging', 'completed') OR available_at IS NOT NULL
  ),
  CONSTRAINT tenant_exports_download_after_available CHECK (
    first_downloaded_at IS NULL OR available_at IS NOT NULL AND first_downloaded_at >= available_at
  ),
  CONSTRAINT tenant_exports_notification_after_available CHECK (
    notified_at IS NULL OR available_at IS NOT NULL AND notified_at >= available_at
  ),
  CONSTRAINT tenant_exports_completed_consistent CHECK (
    (status = 'completed') = (completed_at IS NOT NULL)
  ),
  CONSTRAINT tenant_exports_version_positive CHECK (version > 0),
  CONSTRAINT tenant_exports_id_tenant_unique UNIQUE (id, tenant_id),
  CONSTRAINT tenant_exports_contact_same_tenant_fk
    FOREIGN KEY (tenant_id, contact_user_id)
    REFERENCES public.memberships (tenant_id, user_id) ON DELETE RESTRICT
);

CREATE UNIQUE INDEX tenant_exports_idempotency_idx
  ON public.tenant_exports (tenant_id, idempotency_key);
CREATE INDEX tenant_exports_retention_idx
  ON public.tenant_exports (purge_after, tenant_id)
  WHERE status IN ('available', 'purge_eligible');
CREATE INDEX tenant_exports_contact_idx
  ON public.tenant_exports (contact_user_id, status, available_at DESC);

CREATE TABLE public.tenant_export_disputes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  tenant_export_id UUID NOT NULL,
  filed_by UUID NOT NULL REFERENCES auth.users (id) ON DELETE RESTRICT,
  reason TEXT NOT NULL,
  disputed_scope JSONB NOT NULL,
  status TEXT NOT NULL DEFAULT 'open',
  resolution TEXT,
  resolved_by UUID REFERENCES auth.users (id) ON DELETE RESTRICT,
  filed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  resolved_at TIMESTAMPTZ,
  version BIGINT NOT NULL DEFAULT 1,
  CONSTRAINT tenant_export_disputes_export_same_tenant_fk
    FOREIGN KEY (tenant_id, tenant_export_id)
    REFERENCES public.tenant_exports (tenant_id, id) ON DELETE RESTRICT,
  CONSTRAINT tenant_export_disputes_reason_nonempty CHECK (
    reason = btrim(reason) AND char_length(reason) BETWEEN 1 AND 1000
  ),
  CONSTRAINT tenant_export_disputes_scope_shape CHECK (
    jsonb_typeof(disputed_scope) = 'object'
    AND disputed_scope ->> 'schema_version' = '1'
    AND CASE WHEN jsonb_typeof(disputed_scope -> 'datasets') = 'array'
      THEN jsonb_array_length(disputed_scope -> 'datasets') BETWEEN 1 AND 32
      ELSE FALSE END
  ),
  CONSTRAINT tenant_export_disputes_status_allowed CHECK (status IN ('open', 'resolved', 'rejected')),
  CONSTRAINT tenant_export_disputes_resolution_consistent CHECK (
    (status = 'open' AND resolution IS NULL AND resolved_by IS NULL AND resolved_at IS NULL)
    OR (status IN ('resolved', 'rejected') AND resolution IS NOT NULL
        AND resolution = btrim(resolution) AND char_length(resolution) BETWEEN 1 AND 1000
        AND resolved_by IS NOT NULL AND resolved_at IS NOT NULL)
  ),
  CONSTRAINT tenant_export_disputes_version_positive CHECK (version > 0)
);

CREATE INDEX tenant_export_disputes_export_status_idx
  ON public.tenant_export_disputes (tenant_id, tenant_export_id, status);
CREATE INDEX tenant_export_disputes_tenant_filed_idx
  ON public.tenant_export_disputes (tenant_id, status, filed_at);
CREATE UNIQUE INDEX tenant_export_disputes_one_open_idx
  ON public.tenant_export_disputes (tenant_export_id)
  WHERE status = 'open';

CREATE TABLE public.tenant_export_holds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  tenant_export_id UUID,
  scope JSONB NOT NULL,
  reason TEXT NOT NULL,
  applied_by UUID NOT NULL REFERENCES auth.users (id) ON DELETE RESTRICT,
  applied_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  release_reason TEXT,
  released_by UUID REFERENCES auth.users (id) ON DELETE RESTRICT,
  released_at TIMESTAMPTZ,
  version BIGINT NOT NULL DEFAULT 1,
  CONSTRAINT tenant_export_holds_export_same_tenant_fk
    FOREIGN KEY (tenant_id, tenant_export_id)
    REFERENCES public.tenant_exports (tenant_id, id) ON DELETE RESTRICT,
  CONSTRAINT tenant_export_holds_scope_shape CHECK (
    jsonb_typeof(scope) = 'object' AND scope ->> 'schema_version' = '1'
    AND CASE WHEN jsonb_typeof(scope -> 'datasets') = 'array'
      THEN jsonb_array_length(scope -> 'datasets') BETWEEN 1 AND 32
      ELSE FALSE END
  ),
  CONSTRAINT tenant_export_holds_reason_nonempty CHECK (
    reason = btrim(reason) AND char_length(reason) BETWEEN 1 AND 1000
  ),
  CONSTRAINT tenant_export_holds_release_consistent CHECK (
    (released_at IS NULL AND released_by IS NULL AND release_reason IS NULL)
    OR (released_at IS NOT NULL AND released_by IS NOT NULL
        AND release_reason IS NOT NULL AND release_reason = btrim(release_reason)
        AND char_length(release_reason) BETWEEN 1 AND 1000)
  ),
  CONSTRAINT tenant_export_holds_version_positive CHECK (version > 0)
);

CREATE INDEX tenant_export_holds_active_idx
  ON public.tenant_export_holds (tenant_id, tenant_export_id)
  WHERE released_at IS NULL;

ALTER TABLE public.tenant_exports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tenant_export_disputes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tenant_export_holds ENABLE ROW LEVEL SECURITY;

REVOKE ALL PRIVILEGES ON TABLE public.tenant_exports,
  public.tenant_export_disputes, public.tenant_export_holds
  FROM PUBLIC, anon, authenticated, service_role;

COMMENT ON TABLE public.tenant_exports IS
  'Private metadata for a verified Tenant export; the export worker alone may create and finalize artifacts.';
COMMENT ON TABLE public.tenant_export_disputes IS
  'Scoped completeness disputes; an open dispute pauses purge only for its declared dataset scope.';
COMMENT ON TABLE public.tenant_export_holds IS
  'Audited, scoped legal holds; holds are not removed by an export purge.';

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('tenant-exports', 'tenant-exports', FALSE, 52428800, ARRAY['application/json']::TEXT[])
ON CONFLICT (id) DO NOTHING;

DO $bucket_guard$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM storage.buckets
    WHERE id = 'tenant-exports' AND public = FALSE
      AND file_size_limit = 52428800
      AND allowed_mime_types = ARRAY['application/json']::TEXT[]
  ) THEN
    RAISE EXCEPTION 'tenant-exports bucket must be private and restricted to JSON up to 50 MiB';
  END IF;
END;
$bucket_guard$;

CREATE OR REPLACE FUNCTION private.can_read_tenant_export_object(p_object_name TEXT)
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = ''
AS $function$
  SELECT auth.uid() IS NOT NULL AND EXISTS (
    SELECT 1
    FROM public.tenant_exports AS e
    JOIN public.tenants AS t ON t.id = e.tenant_id AND t.status = 'export_ready'
    JOIN public.memberships AS m
      ON m.tenant_id = e.tenant_id AND m.user_id = e.contact_user_id AND m.status = 'active'
    WHERE e.artifact_bucket = 'tenant-exports'
      AND e.artifact_path = p_object_name
      AND e.contact_user_id = auth.uid()
      AND e.status IN ('available', 'purge_eligible')
      AND e.available_at IS NOT NULL
  );
$function$;

REVOKE ALL ON FUNCTION private.can_read_tenant_export_object(TEXT)
  FROM PUBLIC, anon, authenticated, service_role;
GRANT USAGE ON SCHEMA private TO authenticated;
GRANT EXECUTE ON FUNCTION private.can_read_tenant_export_object(TEXT) TO authenticated;

CREATE POLICY tenant_export_contact_download
  ON storage.objects
  FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'tenant-exports'
    AND private.can_read_tenant_export_object(name)
  );

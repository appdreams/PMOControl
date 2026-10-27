-- F1-02: foundational identity, tenant, RBAC, and audit tables.
-- RLS is enabled with no API policies by design. F1-05 adds reviewed policies.
-- This migration must be applied only to the designated development project.

CREATE TABLE public.user_profiles (
  user_id UUID PRIMARY KEY REFERENCES auth.users (id) ON DELETE RESTRICT,
  display_name TEXT,
  locale TEXT NOT NULL DEFAULT 'pt-BR',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT user_profiles_display_name_length CHECK (
    display_name IS NULL OR char_length(display_name) BETWEEN 1 AND 120
  ),
  CONSTRAINT user_profiles_locale_format CHECK (locale ~ '^[a-z]{2}(-[A-Z]{2})?$')
);

CREATE TABLE public.tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT NOT NULL,
  display_name TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active',
  version BIGINT NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by UUID NOT NULL REFERENCES auth.users (id) ON DELETE RESTRICT,
  suspended_at TIMESTAMPTZ,
  termination_started_at TIMESTAMPTZ,
  CONSTRAINT tenants_slug_format CHECK (
    slug = lower(slug)
    AND slug = btrim(slug)
    AND slug ~ '^[a-z0-9]+([a-z0-9-]*[a-z0-9])?$'
    AND char_length(slug) BETWEEN 3 AND 63
  ),
  CONSTRAINT tenants_display_name_length CHECK (char_length(btrim(display_name)) BETWEEN 1 AND 160),
  CONSTRAINT tenants_status_allowed CHECK (
    status IN ('active', 'suspended', 'termination_pending', 'export_ready', 'purging', 'terminated')
  ),
  CONSTRAINT tenants_version_positive CHECK (version > 0)
);

CREATE UNIQUE INDEX tenants_slug_lower_uidx ON public.tenants (lower(slug));
CREATE INDEX tenants_status_created_idx ON public.tenants (status, created_at DESC);

CREATE TABLE public.memberships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  user_id UUID NOT NULL REFERENCES auth.users (id) ON DELETE RESTRICT,
  status TEXT NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  activated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  suspended_at TIMESTAMPTZ,
  revoked_at TIMESTAMPTZ,
  version BIGINT NOT NULL DEFAULT 1,
  CONSTRAINT memberships_tenant_user_unique UNIQUE (tenant_id, user_id),
  CONSTRAINT memberships_tenant_id_id_unique UNIQUE (tenant_id, id),
  CONSTRAINT memberships_status_allowed CHECK (status IN ('active', 'suspended', 'revoked')),
  CONSTRAINT memberships_lifecycle_timestamps CHECK (
    (status <> 'suspended' OR suspended_at IS NOT NULL)
    AND (status <> 'revoked' OR revoked_at IS NOT NULL)
  ),
  CONSTRAINT memberships_version_positive CHECK (version > 0)
);

CREATE INDEX memberships_user_status_idx ON public.memberships (user_id, status, tenant_id);
CREATE INDEX memberships_tenant_status_idx ON public.memberships (tenant_id, status, created_at DESC);

CREATE TABLE public.tenant_invitations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants (id) ON DELETE RESTRICT,
  email_normalized TEXT NOT NULL,
  grant_payload JSONB NOT NULL,
  token_hash BYTEA NOT NULL,
  issued_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at TIMESTAMPTZ NOT NULL,
  accepted_at TIMESTAMPTZ,
  accepted_by UUID REFERENCES auth.users (id) ON DELETE RESTRICT,
  revoked_at TIMESTAMPTZ,
  created_by UUID NOT NULL REFERENCES auth.users (id) ON DELETE RESTRICT,
  version BIGINT NOT NULL DEFAULT 1,
  CONSTRAINT tenant_invitations_token_hash_unique UNIQUE (token_hash),
  CONSTRAINT tenant_invitations_tenant_id_id_unique UNIQUE (tenant_id, id),
  CONSTRAINT tenant_invitations_email_normalized CHECK (
    email_normalized = lower(btrim(email_normalized))
    AND email_normalized ~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'
    AND char_length(email_normalized) <= 320
  ),
  CONSTRAINT tenant_invitations_payload_v1 CHECK (
    jsonb_typeof(grant_payload) = 'object'
    AND grant_payload ->> 'schema_version' = '1'
    AND jsonb_typeof(grant_payload -> 'grants') = 'array'
    AND grant_payload - 'schema_version' - 'grants' = '{}'::JSONB
  ),
  CONSTRAINT tenant_invitations_token_hash_length CHECK (octet_length(token_hash) = 32),
  CONSTRAINT tenant_invitations_expiry_exact CHECK (expires_at = issued_at + interval '7 days'),
  CONSTRAINT tenant_invitations_acceptance_consistent CHECK (
    (accepted_at IS NULL AND accepted_by IS NULL)
    OR (accepted_at IS NOT NULL AND accepted_by IS NOT NULL AND revoked_at IS NULL)
  ),
  CONSTRAINT tenant_invitations_version_positive CHECK (version > 0)
);

CREATE INDEX tenant_invitations_pending_email_idx
  ON public.tenant_invitations (tenant_id, email_normalized, expires_at)
  WHERE accepted_at IS NULL AND revoked_at IS NULL;

CREATE TABLE public.roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES public.tenants (id) ON DELETE RESTRICT,
  key TEXT NOT NULL,
  name TEXT NOT NULL,
  scope_type TEXT NOT NULL,
  is_system BOOLEAN NOT NULL DEFAULT FALSE,
  status TEXT NOT NULL DEFAULT 'active',
  CONSTRAINT roles_scope_type_allowed CHECK (scope_type IN ('platform', 'tenant')),
  CONSTRAINT roles_scope_tenant_consistent CHECK (
    is_system
    AND (
      (scope_type = 'platform' AND tenant_id IS NULL)
      OR (scope_type = 'tenant' AND tenant_id IS NOT NULL)
    )
  ),
  CONSTRAINT roles_key_format CHECK (key ~ '^[a-z][a-z0-9_.-]{1,79}$'),
  CONSTRAINT roles_name_length CHECK (char_length(btrim(name)) BETWEEN 1 AND 120),
  CONSTRAINT roles_status_allowed CHECK (status IN ('active', 'retired')),
  CONSTRAINT roles_id_scope_unique UNIQUE (id, scope_type),
  CONSTRAINT roles_id_tenant_unique UNIQUE (id, tenant_id)
);

CREATE UNIQUE INDEX roles_tenant_key_uidx
  ON public.roles (tenant_id, key) NULLS NOT DISTINCT;
CREATE INDEX roles_tenant_status_idx ON public.roles (tenant_id, status, key);

CREATE TABLE public.permissions (
  key TEXT PRIMARY KEY,
  resource_type TEXT NOT NULL,
  action TEXT NOT NULL,
  data_classification TEXT NOT NULL DEFAULT 'internal',
  is_sensitive BOOLEAN NOT NULL DEFAULT FALSE,
  CONSTRAINT permissions_key_format CHECK (key ~ '^[a-z][a-z0-9_.{}-]{1,159}$'),
  CONSTRAINT permissions_resource_type_length CHECK (char_length(btrim(resource_type)) BETWEEN 1 AND 80),
  CONSTRAINT permissions_action_length CHECK (char_length(btrim(action)) BETWEEN 1 AND 80),
  CONSTRAINT permissions_data_classification_length CHECK (
    char_length(btrim(data_classification)) BETWEEN 1 AND 40
  )
);

CREATE TABLE public.role_permissions (
  role_id UUID NOT NULL REFERENCES public.roles (id) ON DELETE RESTRICT,
  permission_key TEXT NOT NULL REFERENCES public.permissions (key) ON DELETE RESTRICT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (role_id, permission_key)
);

CREATE INDEX role_permissions_permission_idx ON public.role_permissions (permission_key, role_id);

CREATE TABLE public.access_grants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES public.tenants (id) ON DELETE RESTRICT,
  subject_id UUID NOT NULL REFERENCES auth.users (id) ON DELETE RESTRICT,
  role_id UUID NOT NULL,
  role_scope_type TEXT NOT NULL,
  role_tenant_id UUID,
  scope_type TEXT NOT NULL,
  scope_id TEXT NOT NULL,
  effect TEXT NOT NULL,
  granted_by UUID NOT NULL REFERENCES auth.users (id) ON DELETE RESTRICT,
  reason TEXT NOT NULL,
  starts_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at TIMESTAMPTZ,
  revoked_at TIMESTAMPTZ,
  revoked_by UUID REFERENCES auth.users (id) ON DELETE RESTRICT,
  revocation_reason TEXT,
  version BIGINT NOT NULL DEFAULT 1,
  CONSTRAINT access_grants_role_scope_fk
    FOREIGN KEY (role_id, role_scope_type) REFERENCES public.roles (id, scope_type) ON DELETE RESTRICT,
  CONSTRAINT access_grants_role_tenant_fk
    FOREIGN KEY (role_id, role_tenant_id) REFERENCES public.roles (id, tenant_id) ON DELETE RESTRICT,
  CONSTRAINT access_grants_scope_type_allowed CHECK (
    scope_type IN ('platform', 'tenant', 'portfolio', 'project', 'resource', 'item')
  ),
  CONSTRAINT access_grants_role_scope_consistent CHECK (
    (scope_type = 'platform' AND tenant_id IS NULL AND scope_id = 'platform'
      AND role_scope_type = 'platform' AND role_tenant_id IS NULL)
    OR (scope_type <> 'platform' AND tenant_id IS NOT NULL
      AND role_scope_type = 'tenant' AND role_tenant_id = tenant_id)
  ),
  CONSTRAINT access_grants_tenant_scope_id CHECK (
    scope_type <> 'tenant' OR scope_id = tenant_id::TEXT
  ),
  CONSTRAINT access_grants_resource_scope_id CHECK (
    scope_type IN ('platform', 'tenant') OR scope_id ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
  ),
  CONSTRAINT access_grants_effect_allowed CHECK (effect IN ('allow', 'deny')),
  CONSTRAINT access_grants_reason_nonempty CHECK (char_length(btrim(reason)) BETWEEN 1 AND 1000),
  CONSTRAINT access_grants_expiry_after_start CHECK (expires_at IS NULL OR expires_at > starts_at),
  CONSTRAINT access_grants_revocation_consistent CHECK (
    (revoked_at IS NULL AND revoked_by IS NULL AND revocation_reason IS NULL)
    OR (revoked_at IS NOT NULL AND revoked_by IS NOT NULL AND char_length(btrim(revocation_reason)) > 0)
  ),
  CONSTRAINT access_grants_version_positive CHECK (version > 0),
  CONSTRAINT access_grants_id_tenant_unique UNIQUE (id, tenant_id)
);

CREATE UNIQUE INDEX access_grants_active_unique_idx
  ON public.access_grants (tenant_id, subject_id, role_id, scope_type, scope_id, effect) NULLS NOT DISTINCT
  WHERE revoked_at IS NULL;
CREATE INDEX access_grants_subject_lookup_idx
  ON public.access_grants (tenant_id, subject_id, revoked_at, expires_at);
CREATE INDEX access_grants_scope_lookup_idx
  ON public.access_grants (tenant_id, scope_type, scope_id);

CREATE TABLE public.audit_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES public.tenants (id) ON DELETE RESTRICT,
  actor_id UUID NOT NULL,
  actor_type TEXT NOT NULL,
  action TEXT NOT NULL,
  resource_type TEXT NOT NULL,
  resource_id UUID,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  correlation_id UUID NOT NULL,
  reason TEXT,
  before_redacted JSONB,
  after_redacted JSONB,
  source TEXT NOT NULL,
  schema_version TEXT NOT NULL,
  idempotency_key TEXT,
  CONSTRAINT audit_events_actor_type_allowed CHECK (
    actor_type IN ('user', 'platform_service', 'system_job')
  ),
  CONSTRAINT audit_events_action_nonempty CHECK (char_length(btrim(action)) BETWEEN 1 AND 160),
  CONSTRAINT audit_events_resource_type_nonempty CHECK (
    char_length(btrim(resource_type)) BETWEEN 1 AND 100
  ),
  CONSTRAINT audit_events_source_nonempty CHECK (char_length(btrim(source)) BETWEEN 1 AND 100),
  CONSTRAINT audit_events_schema_version_nonempty CHECK (
    char_length(btrim(schema_version)) BETWEEN 1 AND 40
  ),
  CONSTRAINT audit_events_idempotency_key_length CHECK (
    idempotency_key IS NULL OR char_length(idempotency_key) BETWEEN 1 AND 200
  )
);

CREATE UNIQUE INDEX audit_events_idempotency_uidx
  ON public.audit_events (tenant_id, source, idempotency_key) NULLS NOT DISTINCT
  WHERE idempotency_key IS NOT NULL;
CREATE INDEX audit_events_tenant_time_idx ON public.audit_events (tenant_id, occurred_at DESC);
CREATE INDEX audit_events_tenant_resource_time_idx
  ON public.audit_events (tenant_id, resource_type, resource_id, occurred_at DESC);
CREATE INDEX audit_events_tenant_actor_time_idx
  ON public.audit_events (tenant_id, actor_id, occurred_at DESC);
CREATE INDEX audit_events_tenant_correlation_idx ON public.audit_events (tenant_id, correlation_id);

-- Revoke default API and service-role grants. F1-05 will grant only what reviewed
-- RLS policies/RPC boundaries need; service_role is not a generic application path.
REVOKE ALL PRIVILEGES ON TABLE
  public.user_profiles,
  public.tenants,
  public.memberships,
  public.tenant_invitations,
  public.roles,
  public.permissions,
  public.role_permissions,
  public.access_grants,
  public.audit_events
FROM PUBLIC, anon, authenticated, service_role;

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tenant_invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.access_grants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_events ENABLE ROW LEVEL SECURITY;

COMMENT ON TABLE public.user_profiles IS 'Non-secret user profile fields; Supabase Auth owns credentials and sessions.';
COMMENT ON TABLE public.tenant_invitations IS 'Stores only SHA-256 token hashes; raw invitation tokens must never be persisted.';
COMMENT ON TABLE public.access_grants IS 'Role assignments only; effective permissions are derived from role_permissions.';
COMMENT ON TABLE public.audit_events IS 'Append-only application audit; pre-authentication failures remain in provider logs.';

-- F2-03/F2-04: establish Tenant-owned Portfolio/Project identities and exact
-- resource scopes before exposing resource-grant or invitation workflows.

CREATE TABLE public.portfolios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE RESTRICT,
  name TEXT NOT NULL,
  code TEXT,
  owner_id UUID NOT NULL,
  sponsor_id UUID,
  category TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active',
  start_date DATE,
  target_end_date DATE,
  archived_at TIMESTAMPTZ,
  version BIGINT NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
  CONSTRAINT portfolios_tenant_id_id_unique UNIQUE (tenant_id, id),
  CONSTRAINT portfolios_owner_same_tenant_fk
    FOREIGN KEY (tenant_id, owner_id) REFERENCES public.memberships(tenant_id, user_id) ON DELETE RESTRICT,
  CONSTRAINT portfolios_sponsor_same_tenant_fk
    FOREIGN KEY (tenant_id, sponsor_id) REFERENCES public.memberships(tenant_id, user_id) ON DELETE RESTRICT,
  CONSTRAINT portfolios_name_length CHECK (char_length(btrim(name)) BETWEEN 1 AND 160),
  CONSTRAINT portfolios_code_normalized CHECK (code IS NULL OR (code = upper(btrim(code)) AND btrim(code) <> '')),
  CONSTRAINT portfolios_category_length CHECK (char_length(btrim(category)) BETWEEN 1 AND 80),
  CONSTRAINT portfolios_status_allowed CHECK (status IN ('active', 'archived')),
  CONSTRAINT portfolios_archive_consistent CHECK ((status = 'archived') = (archived_at IS NOT NULL)),
  CONSTRAINT portfolios_date_range CHECK (start_date IS NULL OR target_end_date IS NULL OR target_end_date >= start_date),
  CONSTRAINT portfolios_version_positive CHECK (version > 0)
);

CREATE UNIQUE INDEX portfolios_tenant_code_unique
  ON public.portfolios (tenant_id, upper(btrim(code)))
  WHERE code IS NOT NULL AND btrim(code) <> '';
CREATE INDEX portfolios_tenant_status_name_idx ON public.portfolios (tenant_id, status, name);
CREATE INDEX portfolios_tenant_owner_status_idx ON public.portfolios (tenant_id, owner_id, status);
CREATE INDEX portfolios_tenant_sponsor_idx ON public.portfolios (tenant_id, sponsor_id) WHERE sponsor_id IS NOT NULL;

CREATE TABLE public.projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE RESTRICT,
  name TEXT NOT NULL,
  code TEXT,
  sponsor_id UUID,
  project_manager_id UUID,
  status TEXT NOT NULL DEFAULT 'planning',
  priority TEXT NOT NULL DEFAULT 'medium',
  scope_summary TEXT,
  start_date DATE,
  target_end_date DATE,
  archived_at TIMESTAMPTZ,
  version BIGINT NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
  CONSTRAINT projects_tenant_id_id_unique UNIQUE (tenant_id, id),
  CONSTRAINT projects_sponsor_same_tenant_fk
    FOREIGN KEY (tenant_id, sponsor_id) REFERENCES public.memberships(tenant_id, user_id) ON DELETE RESTRICT,
  CONSTRAINT projects_manager_same_tenant_fk
    FOREIGN KEY (tenant_id, project_manager_id) REFERENCES public.memberships(tenant_id, user_id) ON DELETE RESTRICT,
  CONSTRAINT projects_name_length CHECK (char_length(btrim(name)) BETWEEN 1 AND 160),
  CONSTRAINT projects_code_normalized CHECK (code IS NULL OR (code = upper(btrim(code)) AND btrim(code) <> '')),
  CONSTRAINT projects_status_allowed CHECK (status IN ('planning', 'execution', 'paused', 'completed', 'cancelled')),
  CONSTRAINT projects_priority_allowed CHECK (priority IN ('low', 'medium', 'high', 'critical')),
  CONSTRAINT projects_scope_summary_length CHECK (scope_summary IS NULL OR char_length(btrim(scope_summary)) <= 2000),
  CONSTRAINT projects_date_range CHECK (start_date IS NULL OR target_end_date IS NULL OR target_end_date >= start_date),
  CONSTRAINT projects_version_positive CHECK (version > 0)
);

CREATE UNIQUE INDEX projects_tenant_code_unique
  ON public.projects (tenant_id, upper(btrim(code)))
  WHERE code IS NOT NULL AND btrim(code) <> '';
CREATE INDEX projects_tenant_status_name_idx ON public.projects (tenant_id, status, name);
CREATE INDEX projects_tenant_manager_status_idx ON public.projects (tenant_id, project_manager_id, status)
  WHERE project_manager_id IS NOT NULL;
CREATE INDEX projects_tenant_sponsor_idx ON public.projects (tenant_id, sponsor_id)
  WHERE sponsor_id IS NOT NULL;

CREATE TABLE public.portfolio_projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE RESTRICT,
  portfolio_id UUID NOT NULL,
  project_id UUID NOT NULL,
  linked_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  linked_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
  removed_at TIMESTAMPTZ,
  removed_by UUID REFERENCES auth.users(id) ON DELETE RESTRICT,
  version BIGINT NOT NULL DEFAULT 1,
  CONSTRAINT portfolio_projects_tenant_id_id_unique UNIQUE (tenant_id, id),
  CONSTRAINT portfolio_projects_portfolio_same_tenant_fk
    FOREIGN KEY (tenant_id, portfolio_id) REFERENCES public.portfolios(tenant_id, id) ON DELETE RESTRICT,
  CONSTRAINT portfolio_projects_project_same_tenant_fk
    FOREIGN KEY (tenant_id, project_id) REFERENCES public.projects(tenant_id, id) ON DELETE RESTRICT,
  CONSTRAINT portfolio_projects_removal_consistent CHECK (
    (removed_at IS NULL AND removed_by IS NULL) OR (removed_at IS NOT NULL AND removed_by IS NOT NULL)
  ),
  CONSTRAINT portfolio_projects_version_positive CHECK (version > 0)
);
CREATE UNIQUE INDEX portfolio_projects_active_unique
  ON public.portfolio_projects (tenant_id, portfolio_id, project_id)
  WHERE removed_at IS NULL;
CREATE INDEX portfolio_projects_tenant_project_idx
  ON public.portfolio_projects (tenant_id, project_id, removed_at);

-- Keep access grants resource-aware without a polymorphic FK escape hatch.
ALTER TABLE public.access_grants
  ADD COLUMN portfolio_scope_id UUID GENERATED ALWAYS AS
    (CASE WHEN scope_type = 'portfolio' THEN scope_id::UUID END) STORED,
  ADD COLUMN project_scope_id UUID GENERATED ALWAYS AS
    (CASE WHEN scope_type = 'project' THEN scope_id::UUID END) STORED,
  ADD CONSTRAINT access_grants_portfolio_scope_same_tenant_fk
    FOREIGN KEY (tenant_id, portfolio_scope_id) REFERENCES public.portfolios(tenant_id, id) ON DELETE RESTRICT,
  ADD CONSTRAINT access_grants_project_scope_same_tenant_fk
    FOREIGN KEY (tenant_id, project_scope_id) REFERENCES public.projects(tenant_id, id) ON DELETE RESTRICT;
CREATE INDEX access_grants_tenant_portfolio_scope_idx
  ON public.access_grants (tenant_id, portfolio_scope_id) WHERE portfolio_scope_id IS NOT NULL;
CREATE INDEX access_grants_tenant_project_scope_idx
  ON public.access_grants (tenant_id, project_scope_id) WHERE project_scope_id IS NOT NULL;

ALTER TABLE public.portfolios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolio_projects ENABLE ROW LEVEL SECURITY;
REVOKE ALL PRIVILEGES ON TABLE public.portfolios, public.projects, public.portfolio_projects
  FROM PUBLIC, anon, authenticated, service_role;

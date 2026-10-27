-- F2-03/F2-04: first authorized CRUD slice for creating and listing
-- Tenant-owned Portfolios and Projects through RPC-only boundaries.

-- Tenant Admin may bootstrap Portfolio creation. Each created Portfolio gives
-- its creator a PMO Admin grant at that one Portfolio, never at Tenant scope.
INSERT INTO private.tenant_role_preset_permissions (catalog_version, role_key, role_name, permission_key)
VALUES ('rbac-v1', 'tenant_admin', 'Tenant Admin', 'portfolio.create')
ON CONFLICT (catalog_version, role_key, permission_key) DO NOTHING;
INSERT INTO public.role_permissions (role_id, permission_key)
SELECT r.id, 'portfolio.create' FROM public.roles AS r
WHERE r.scope_type = 'tenant' AND r.status = 'active' AND r.key = 'tenant_admin'
ON CONFLICT (role_id, permission_key) DO NOTHING;

CREATE OR REPLACE FUNCTION private.actor_has_scope_permission(
  p_tenant_id UUID, p_permission_key TEXT, p_scope_type TEXT, p_scope_id TEXT
)
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = ''
AS $function$
  SELECT auth.uid() IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM public.memberships AS m
      JOIN public.tenants AS t ON t.id = m.tenant_id AND t.status = 'active'
      WHERE m.tenant_id = p_tenant_id AND m.user_id = auth.uid() AND m.status = 'active'
    )
    AND EXISTS (
      SELECT 1 FROM public.access_grants AS g
      JOIN public.roles AS r ON r.id = g.role_id AND r.status = 'active'
        AND r.scope_type = 'tenant' AND r.tenant_id = p_tenant_id
      JOIN public.role_permissions AS rp ON rp.role_id = r.id
        AND rp.permission_key = p_permission_key
      WHERE g.tenant_id = p_tenant_id AND g.subject_id = auth.uid()
        AND g.role_scope_type = 'tenant' AND g.role_tenant_id = p_tenant_id
        AND g.scope_type = p_scope_type AND g.scope_id = p_scope_id
        AND g.effect = 'allow' AND g.revoked_at IS NULL
        AND g.starts_at <= pg_catalog.now()
        AND (g.expires_at IS NULL OR g.expires_at > pg_catalog.now())
    )
    AND NOT EXISTS (
      SELECT 1 FROM public.access_grants AS g
      JOIN public.roles AS r ON r.id = g.role_id AND r.status = 'active'
        AND r.scope_type = 'tenant' AND r.tenant_id = p_tenant_id
      JOIN public.role_permissions AS rp ON rp.role_id = r.id
        AND rp.permission_key = p_permission_key
      WHERE g.tenant_id = p_tenant_id AND g.subject_id = auth.uid()
        AND g.role_scope_type = 'tenant' AND g.role_tenant_id = p_tenant_id
        AND g.scope_type = p_scope_type AND g.scope_id = p_scope_id
        AND g.effect = 'deny' AND g.revoked_at IS NULL
        AND g.starts_at <= pg_catalog.now()
        AND (g.expires_at IS NULL OR g.expires_at > pg_catalog.now())
    );
$function$;
REVOKE ALL ON FUNCTION private.actor_has_scope_permission(UUID, TEXT, TEXT, TEXT)
  FROM PUBLIC, anon, authenticated, service_role;

CREATE OR REPLACE FUNCTION private.list_tenant_portfolios(p_tenant_id UUID)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $function$
DECLARE
  v_actor UUID := auth.uid();
  v_rows JSONB;
  v_can_create BOOLEAN;
BEGIN
  IF v_actor IS NULL OR p_tenant_id IS NULL OR NOT EXISTS (
    SELECT 1 FROM public.memberships AS m JOIN public.tenants AS t ON t.id = m.tenant_id
    WHERE m.tenant_id = p_tenant_id AND m.user_id = v_actor
      AND m.status = 'active' AND t.status = 'active'
  ) THEN RAISE EXCEPTION 'Tenant unavailable' USING ERRCODE = '42501'; END IF;
  v_can_create := private.actor_has_scope_permission(p_tenant_id, 'portfolio.create', 'tenant', p_tenant_id::TEXT);
  SELECT COALESCE(pg_catalog.jsonb_agg(pg_catalog.jsonb_build_object(
    'id', p.id, 'tenantId', p.tenant_id, 'name', p.name, 'code', p.code,
    'category', p.category, 'ownerId', p.owner_id, 'sponsorId', p.sponsor_id,
    'status', p.status, 'startDate', p.start_date, 'targetEndDate', p.target_end_date,
    'version', p.version::TEXT
  ) ORDER BY p.name, p.id), '[]'::JSONB)
  INTO v_rows FROM public.portfolios AS p
  WHERE p.tenant_id = p_tenant_id AND p.status = 'active' AND p.archived_at IS NULL
    AND private.actor_has_scope_permission(p_tenant_id, 'portfolio.view', 'portfolio', p.id::TEXT);
  RETURN pg_catalog.jsonb_build_object('portfolios', v_rows, 'canCreate', v_can_create);
END;
$function$;

CREATE OR REPLACE FUNCTION private.create_tenant_portfolio(
  p_tenant_id UUID, p_name TEXT, p_code TEXT, p_sponsor_id UUID,
  p_category TEXT, p_start_date DATE, p_target_end_date DATE,
  p_reason TEXT, p_idempotency_key UUID
)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $function$
DECLARE
  v_actor UUID := auth.uid();
  v_role_id UUID;
  v_id UUID;
  v_grant_id UUID;
  v_now TIMESTAMPTZ := pg_catalog.now();
  v_correlation UUID := gen_random_uuid();
  v_after JSONB;
  v_existing public.audit_events%ROWTYPE;
  v_row public.portfolios%ROWTYPE;
BEGIN
  IF v_actor IS NULL OR p_tenant_id IS NULL OR p_idempotency_key IS NULL
    OR p_name IS NULL OR p_name <> pg_catalog.btrim(p_name) OR pg_catalog.char_length(p_name) NOT BETWEEN 1 AND 160
    OR p_code IS NOT NULL AND (p_code <> pg_catalog.upper(pg_catalog.btrim(p_code)) OR pg_catalog.char_length(p_code) NOT BETWEEN 1 AND 40)
    OR p_category IS NULL OR p_category <> pg_catalog.btrim(p_category) OR pg_catalog.char_length(p_category) NOT BETWEEN 1 AND 80
    OR p_start_date IS NOT NULL AND p_target_end_date IS NOT NULL AND p_target_end_date < p_start_date
    OR p_reason IS NULL OR p_reason <> pg_catalog.btrim(p_reason) OR pg_catalog.char_length(p_reason) NOT BETWEEN 1 AND 1000 THEN
    RAISE EXCEPTION 'Invalid Portfolio input' USING ERRCODE = '22023';
  END IF;
  IF NOT private.actor_has_scope_permission(p_tenant_id, 'portfolio.create', 'tenant', p_tenant_id::TEXT)
     OR NOT private.actor_has_scope_permission(p_tenant_id, 'membership.grant', 'tenant', p_tenant_id::TEXT) THEN
    RAISE EXCEPTION 'Portfolio creation is not permitted' USING ERRCODE = '42501';
  END IF;
  IF p_sponsor_id IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM public.memberships AS m WHERE m.tenant_id = p_tenant_id
      AND m.user_id = p_sponsor_id AND m.status = 'active'
  ) THEN RAISE EXCEPTION 'Sponsor unavailable' USING ERRCODE = '42501'; END IF;

  v_after := pg_catalog.jsonb_build_object(
    'name', p_name, 'code', p_code, 'category', p_category,
    'ownerId', v_actor, 'sponsorId', p_sponsor_id,
    'startDate', p_start_date, 'targetEndDate', p_target_end_date
  );
  SELECT * INTO v_existing FROM public.audit_events AS a
  WHERE a.tenant_id = p_tenant_id AND a.source = 'portfolio-create'
    AND a.idempotency_key = 'create:' || p_idempotency_key::TEXT FOR UPDATE;
  IF FOUND THEN
    IF v_existing.actor_id <> v_actor OR v_existing.reason <> p_reason OR v_existing.after_redacted <> v_after THEN
      RAISE EXCEPTION 'Idempotency key payload mismatch' USING ERRCODE = '23505';
    END IF;
    SELECT * INTO v_row FROM public.portfolios AS p WHERE p.tenant_id = p_tenant_id AND p.id = v_existing.resource_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Portfolio replay unavailable' USING ERRCODE = '40001'; END IF;
    RETURN pg_catalog.jsonb_build_object('portfolioId', v_row.id, 'tenantId', v_row.tenant_id,
      'name', v_row.name, 'code', v_row.code, 'category', v_row.category, 'ownerId', v_row.owner_id,
      'sponsorId', v_row.sponsor_id, 'status', v_row.status, 'version', v_row.version::TEXT,
      'correlationId', v_existing.correlation_id, 'idempotentReplay', TRUE);
  END IF;

  SELECT r.id INTO v_role_id FROM public.roles AS r
  WHERE r.tenant_id = p_tenant_id AND r.scope_type = 'tenant'
    AND r.key = 'pmo_admin' AND r.is_system AND r.status = 'active';
  IF v_role_id IS NULL THEN RAISE EXCEPTION 'Portfolio owner role unavailable' USING ERRCODE = '22023'; END IF;
  INSERT INTO public.portfolios (
    tenant_id, name, code, owner_id, sponsor_id, category, status,
    start_date, target_end_date, created_by, updated_by
  ) VALUES (
    p_tenant_id, p_name, p_code, v_actor, p_sponsor_id, p_category, 'active',
    p_start_date, p_target_end_date, v_actor, v_actor
  ) RETURNING * INTO v_row;
  v_id := v_row.id;
  INSERT INTO public.access_grants (
    tenant_id, subject_id, role_id, role_scope_type, role_tenant_id,
    scope_type, scope_id, effect, granted_by, reason
  ) VALUES (
    p_tenant_id, v_actor, v_role_id, 'tenant', p_tenant_id,
    'portfolio', v_id::TEXT, 'allow', v_actor, 'Initial Portfolio owner access'
  ) RETURNING id INTO v_grant_id;
  INSERT INTO public.audit_events (
    tenant_id, actor_id, actor_type, action, resource_type, resource_id,
    correlation_id, reason, after_redacted, source, schema_version, idempotency_key
  ) VALUES (
    p_tenant_id, v_actor, 'user', 'portfolio.create', 'portfolio', v_id,
    v_correlation, p_reason, v_after, 'portfolio-create', '1', 'create:' || p_idempotency_key::TEXT
  );
  INSERT INTO public.audit_events (
    tenant_id, actor_id, actor_type, action, resource_type, resource_id,
    correlation_id, reason, after_redacted, source, schema_version, idempotency_key
  ) VALUES (
    p_tenant_id, v_actor, 'user', 'access_grant.create', 'access_grant', v_grant_id,
    v_correlation, 'Initial Portfolio owner access',
    pg_catalog.jsonb_build_object('subjectId', v_actor, 'roleKey', 'pmo_admin', 'scopeType', 'portfolio', 'scopeId', v_id),
    'portfolio-create-grant', '1', 'owner:' || p_idempotency_key::TEXT
  );
  RETURN pg_catalog.jsonb_build_object('portfolioId', v_row.id, 'tenantId', v_row.tenant_id,
    'name', v_row.name, 'code', v_row.code, 'category', v_row.category, 'ownerId', v_row.owner_id,
    'sponsorId', v_row.sponsor_id, 'status', v_row.status, 'version', v_row.version::TEXT,
    'correlationId', v_correlation, 'idempotentReplay', FALSE);
END;
$function$;

CREATE OR REPLACE FUNCTION private.list_portfolio_projects(p_tenant_id UUID, p_portfolio_id UUID)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $function$
DECLARE
  v_actor UUID := auth.uid();
  v_rows JSONB;
  v_can_create BOOLEAN;
BEGIN
  IF v_actor IS NULL OR NOT EXISTS (
    SELECT 1 FROM public.memberships AS m JOIN public.tenants AS t ON t.id = m.tenant_id
    WHERE m.tenant_id = p_tenant_id AND m.user_id = v_actor AND m.status = 'active' AND t.status = 'active'
  ) THEN RAISE EXCEPTION 'Tenant unavailable' USING ERRCODE = '42501'; END IF;
  v_can_create := private.actor_has_scope_permission(p_tenant_id, 'project.create', 'portfolio', p_portfolio_id::TEXT)
    AND EXISTS (SELECT 1 FROM public.portfolios AS p WHERE p.tenant_id = p_tenant_id
      AND p.id = p_portfolio_id AND p.status = 'active' AND p.archived_at IS NULL);
  SELECT COALESCE(pg_catalog.jsonb_agg(pg_catalog.jsonb_build_object(
    'id', p.id, 'tenantId', p.tenant_id, 'portfolioId', link.portfolio_id,
    'name', p.name, 'code', p.code, 'status', p.status, 'priority', p.priority,
    'scopeSummary', p.scope_summary, 'projectManagerId', p.project_manager_id,
    'sponsorId', p.sponsor_id, 'startDate', p.start_date, 'targetEndDate', p.target_end_date,
    'version', p.version::TEXT
  ) ORDER BY p.name, p.id), '[]'::JSONB)
  INTO v_rows FROM public.projects AS p
  JOIN public.portfolio_projects AS link ON link.tenant_id = p.tenant_id
    AND link.project_id = p.id AND link.portfolio_id = p_portfolio_id AND link.removed_at IS NULL
  WHERE p.tenant_id = p_tenant_id AND p.archived_at IS NULL
    AND private.actor_has_scope_permission(p_tenant_id, 'project.view', 'project', p.id::TEXT);
  RETURN pg_catalog.jsonb_build_object('projects', v_rows, 'canCreate', COALESCE(v_can_create, FALSE));
END;
$function$;

CREATE OR REPLACE FUNCTION private.create_portfolio_project(
  p_tenant_id UUID, p_portfolio_id UUID, p_name TEXT, p_code TEXT,
  p_sponsor_id UUID, p_priority TEXT, p_scope_summary TEXT,
  p_start_date DATE, p_target_end_date DATE, p_reason TEXT, p_idempotency_key UUID
)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $function$
DECLARE
  v_actor UUID := auth.uid();
  v_project_role_id UUID;
  v_id UUID;
  v_grant_id UUID;
  v_correlation UUID := gen_random_uuid();
  v_after JSONB;
  v_existing public.audit_events%ROWTYPE;
  v_row public.projects%ROWTYPE;
BEGIN
  IF v_actor IS NULL OR p_tenant_id IS NULL OR p_portfolio_id IS NULL OR p_idempotency_key IS NULL
    OR p_name IS NULL OR p_name <> pg_catalog.btrim(p_name) OR pg_catalog.char_length(p_name) NOT BETWEEN 1 AND 160
    OR p_code IS NOT NULL AND (p_code <> pg_catalog.upper(pg_catalog.btrim(p_code)) OR pg_catalog.char_length(p_code) NOT BETWEEN 1 AND 40)
    OR p_priority IS NULL OR p_priority NOT IN ('low','medium','high','critical')
    OR p_scope_summary IS NOT NULL AND pg_catalog.char_length(p_scope_summary) > 2000
    OR p_start_date IS NOT NULL AND p_target_end_date IS NOT NULL AND p_target_end_date < p_start_date
    OR p_reason IS NULL OR p_reason <> pg_catalog.btrim(p_reason) OR pg_catalog.char_length(p_reason) NOT BETWEEN 1 AND 1000 THEN
    RAISE EXCEPTION 'Invalid Project input' USING ERRCODE = '22023';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.memberships AS m JOIN public.tenants AS t ON t.id = m.tenant_id
      WHERE m.tenant_id = p_tenant_id AND m.user_id = v_actor AND m.status = 'active' AND t.status = 'active')
     OR NOT EXISTS (SELECT 1 FROM public.portfolios AS p WHERE p.tenant_id = p_tenant_id
      AND p.id = p_portfolio_id AND p.status = 'active' AND p.archived_at IS NULL)
     OR NOT private.actor_has_scope_permission(p_tenant_id, 'project.create', 'portfolio', p_portfolio_id::TEXT) THEN
    RAISE EXCEPTION 'Project creation is not permitted' USING ERRCODE = '42501';
  END IF;
  IF p_sponsor_id IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM public.memberships AS m WHERE m.tenant_id = p_tenant_id
      AND m.user_id = p_sponsor_id AND m.status = 'active'
  ) THEN RAISE EXCEPTION 'Sponsor unavailable' USING ERRCODE = '42501'; END IF;
  SELECT r.id INTO v_project_role_id FROM public.roles AS r
  WHERE r.tenant_id = p_tenant_id AND r.scope_type = 'tenant'
    AND r.key = 'project_manager' AND r.is_system AND r.status = 'active';
  IF v_project_role_id IS NULL THEN RAISE EXCEPTION 'Project Manager role unavailable' USING ERRCODE = '22023'; END IF;

  v_after := pg_catalog.jsonb_build_object(
    'portfolioId', p_portfolio_id, 'name', p_name, 'code', p_code,
    'projectManagerId', v_actor, 'sponsorId', p_sponsor_id,
    'priority', p_priority, 'scopeSummary', p_scope_summary,
    'startDate', p_start_date, 'targetEndDate', p_target_end_date
  );
  SELECT * INTO v_existing FROM public.audit_events AS a
  WHERE a.tenant_id = p_tenant_id AND a.source = 'project-create'
    AND a.idempotency_key = 'create:' || p_idempotency_key::TEXT FOR UPDATE;
  IF FOUND THEN
    IF v_existing.actor_id <> v_actor OR v_existing.reason <> p_reason OR v_existing.after_redacted <> v_after THEN
      RAISE EXCEPTION 'Idempotency key payload mismatch' USING ERRCODE = '23505';
    END IF;
    SELECT * INTO v_row FROM public.projects AS p WHERE p.tenant_id = p_tenant_id AND p.id = v_existing.resource_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Project replay unavailable' USING ERRCODE = '40001'; END IF;
    RETURN pg_catalog.jsonb_build_object('projectId', v_row.id, 'tenantId', v_row.tenant_id,
      'portfolioId', p_portfolio_id, 'name', v_row.name, 'code', v_row.code,
      'status', v_row.status, 'priority', v_row.priority, 'projectManagerId', v_row.project_manager_id,
      'sponsorId', v_row.sponsor_id, 'version', v_row.version::TEXT,
      'correlationId', v_existing.correlation_id, 'idempotentReplay', TRUE);
  END IF;

  INSERT INTO public.projects (
    tenant_id, name, code, sponsor_id, project_manager_id, status, priority,
    scope_summary, start_date, target_end_date, created_by, updated_by
  ) VALUES (
    p_tenant_id, p_name, p_code, p_sponsor_id, v_actor, 'planning', p_priority,
    p_scope_summary, p_start_date, p_target_end_date, v_actor, v_actor
  ) RETURNING * INTO v_row;
  v_id := v_row.id;
  INSERT INTO public.portfolio_projects (tenant_id, portfolio_id, project_id, linked_by)
  VALUES (p_tenant_id, p_portfolio_id, v_id, v_actor);
  INSERT INTO public.access_grants (
    tenant_id, subject_id, role_id, role_scope_type, role_tenant_id,
    scope_type, scope_id, effect, granted_by, reason
  ) VALUES (
    p_tenant_id, v_actor, v_project_role_id, 'tenant', p_tenant_id,
    'project', v_id::TEXT, 'allow', v_actor, 'Initial Project Manager access'
  ) RETURNING id INTO v_grant_id;
  INSERT INTO public.audit_events (
    tenant_id, actor_id, actor_type, action, resource_type, resource_id,
    correlation_id, reason, after_redacted, source, schema_version, idempotency_key
  ) VALUES (
    p_tenant_id, v_actor, 'user', 'project.create', 'project', v_id,
    v_correlation, p_reason, v_after, 'project-create', '1', 'create:' || p_idempotency_key::TEXT
  );
  INSERT INTO public.audit_events (
    tenant_id, actor_id, actor_type, action, resource_type, resource_id,
    correlation_id, reason, after_redacted, source, schema_version, idempotency_key
  ) VALUES (
    p_tenant_id, v_actor, 'user', 'access_grant.create', 'access_grant', v_grant_id,
    v_correlation, 'Initial Project Manager access',
    pg_catalog.jsonb_build_object('subjectId', v_actor, 'roleKey', 'project_manager', 'scopeType', 'project', 'scopeId', v_id),
    'project-create-grant', '1', 'manager:' || p_idempotency_key::TEXT
  );
  RETURN pg_catalog.jsonb_build_object('projectId', v_id, 'tenantId', p_tenant_id,
    'portfolioId', p_portfolio_id, 'name', v_row.name, 'code', v_row.code,
    'status', v_row.status, 'priority', v_row.priority, 'projectManagerId', v_actor,
    'sponsorId', p_sponsor_id, 'version', v_row.version::TEXT,
    'correlationId', v_correlation, 'idempotentReplay', FALSE);
END;
$function$;

CREATE OR REPLACE FUNCTION public.list_tenant_portfolios(p_tenant_id UUID)
RETURNS JSONB LANGUAGE SQL SECURITY INVOKER SET search_path = ''
AS $function$ SELECT private.list_tenant_portfolios(p_tenant_id); $function$;
CREATE OR REPLACE FUNCTION public.create_tenant_portfolio(
  p_tenant_id UUID, p_name TEXT, p_code TEXT, p_sponsor_id UUID, p_category TEXT,
  p_start_date DATE, p_target_end_date DATE, p_reason TEXT, p_idempotency_key UUID
)
RETURNS JSONB LANGUAGE SQL SECURITY INVOKER SET search_path = ''
AS $function$ SELECT private.create_tenant_portfolio(
  p_tenant_id, p_name, p_code, p_sponsor_id, p_category, p_start_date,
  p_target_end_date, p_reason, p_idempotency_key
); $function$;
CREATE OR REPLACE FUNCTION public.list_portfolio_projects(p_tenant_id UUID, p_portfolio_id UUID)
RETURNS JSONB LANGUAGE SQL SECURITY INVOKER SET search_path = ''
AS $function$ SELECT private.list_portfolio_projects(p_tenant_id, p_portfolio_id); $function$;
CREATE OR REPLACE FUNCTION public.create_portfolio_project(
  p_tenant_id UUID, p_portfolio_id UUID, p_name TEXT, p_code TEXT, p_sponsor_id UUID,
  p_priority TEXT, p_scope_summary TEXT, p_start_date DATE, p_target_end_date DATE,
  p_reason TEXT, p_idempotency_key UUID
)
RETURNS JSONB LANGUAGE SQL SECURITY INVOKER SET search_path = ''
AS $function$ SELECT private.create_portfolio_project(
  p_tenant_id, p_portfolio_id, p_name, p_code, p_sponsor_id, p_priority,
  p_scope_summary, p_start_date, p_target_end_date, p_reason, p_idempotency_key
); $function$;

REVOKE ALL ON FUNCTION private.list_tenant_portfolios(UUID),
  private.create_tenant_portfolio(UUID,TEXT,TEXT,UUID,TEXT,DATE,DATE,TEXT,UUID),
  private.list_portfolio_projects(UUID,UUID),
  private.create_portfolio_project(UUID,UUID,TEXT,TEXT,UUID,TEXT,TEXT,DATE,DATE,TEXT,UUID)
  FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION private.list_tenant_portfolios(UUID),
  private.create_tenant_portfolio(UUID,TEXT,TEXT,UUID,TEXT,DATE,DATE,TEXT,UUID),
  private.list_portfolio_projects(UUID,UUID),
  private.create_portfolio_project(UUID,UUID,TEXT,TEXT,UUID,TEXT,TEXT,DATE,DATE,TEXT,UUID)
  TO authenticated;

REVOKE ALL ON FUNCTION public.list_tenant_portfolios(UUID),
  public.create_tenant_portfolio(UUID,TEXT,TEXT,UUID,TEXT,DATE,DATE,TEXT,UUID),
  public.list_portfolio_projects(UUID,UUID),
  public.create_portfolio_project(UUID,UUID,TEXT,TEXT,UUID,TEXT,TEXT,DATE,DATE,TEXT,UUID)
  FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.list_tenant_portfolios(UUID),
  public.create_tenant_portfolio(UUID,TEXT,TEXT,UUID,TEXT,DATE,DATE,TEXT,UUID),
  public.list_portfolio_projects(UUID,UUID),
  public.create_portfolio_project(UUID,UUID,TEXT,TEXT,UUID,TEXT,TEXT,DATE,DATE,TEXT,UUID)
  TO authenticated;

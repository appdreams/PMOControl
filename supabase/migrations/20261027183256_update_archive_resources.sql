-- F2-03/F2-04: versioned resource edits and soft archival through exact-scope RPCs.
CREATE OR REPLACE FUNCTION private.mutate_portfolio(
  p_tenant_id UUID, p_portfolio_id UUID, p_action TEXT, p_patch JSONB,
  p_expected_version BIGINT, p_reason TEXT, p_idempotency_key UUID
)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $function$
DECLARE
  v_actor UUID := auth.uid();
  v_now TIMESTAMPTZ := pg_catalog.now();
  v_permission TEXT;
  v_row public.portfolios%ROWTYPE;
  v_existing public.audit_events%ROWTYPE;
  v_before JSONB;
  v_after JSONB;
  v_request JSONB;
  v_correlation UUID := gen_random_uuid();
  v_source TEXT := 'portfolio-mutation';
BEGIN
  IF v_actor IS NULL OR p_tenant_id IS NULL OR p_portfolio_id IS NULL
     OR p_action NOT IN ('update','archive') OR p_expected_version IS NULL OR p_expected_version < 1
     OR p_idempotency_key IS NULL OR p_reason IS NULL OR p_reason <> pg_catalog.btrim(p_reason)
     OR pg_catalog.char_length(p_reason) NOT BETWEEN 1 AND 1000 OR p_patch IS NULL
     OR pg_catalog.jsonb_typeof(p_patch) <> 'object' THEN
    RAISE EXCEPTION 'Invalid Portfolio mutation' USING ERRCODE = '22023';
  END IF;
  IF p_action = 'update' AND (p_patch = '{}'::JSONB OR EXISTS (
      SELECT 1 FROM pg_catalog.jsonb_object_keys(p_patch) AS k
      WHERE k NOT IN ('name','code','sponsorId','category','startDate','targetEndDate')
    )) THEN RAISE EXCEPTION 'Invalid Portfolio fields' USING ERRCODE = '22023'; END IF;
  IF p_action = 'archive' AND p_patch <> '{}'::JSONB THEN
    RAISE EXCEPTION 'Archive does not accept fields' USING ERRCODE = '22023';
  END IF;
  IF p_patch ? 'name' AND (pg_catalog.jsonb_typeof(p_patch->'name') <> 'string'
      OR pg_catalog.char_length(pg_catalog.btrim(p_patch->>'name')) NOT BETWEEN 1 AND 160)
     OR p_patch ? 'category' AND (pg_catalog.jsonb_typeof(p_patch->'category') <> 'string'
      OR pg_catalog.char_length(pg_catalog.btrim(p_patch->>'category')) NOT BETWEEN 1 AND 80)
     OR p_patch ? 'code' AND p_patch->'code' <> 'null'::JSONB AND
        (pg_catalog.jsonb_typeof(p_patch->'code') <> 'string' OR p_patch->>'code' <> pg_catalog.upper(pg_catalog.btrim(p_patch->>'code'))
          OR pg_catalog.char_length(p_patch->>'code') NOT BETWEEN 1 AND 40)
     OR p_patch ? 'sponsorId' AND p_patch->'sponsorId' <> 'null'::JSONB AND
        (pg_catalog.jsonb_typeof(p_patch->'sponsorId') <> 'string' OR (p_patch->>'sponsorId')::UUID IS NULL)
     OR p_patch ? 'startDate' AND p_patch->'startDate' <> 'null'::JSONB AND pg_catalog.jsonb_typeof(p_patch->'startDate') <> 'string'
     OR p_patch ? 'targetEndDate' AND p_patch->'targetEndDate' <> 'null'::JSONB AND pg_catalog.jsonb_typeof(p_patch->'targetEndDate') <> 'string' THEN
    RAISE EXCEPTION 'Invalid Portfolio fields' USING ERRCODE = '22023';
  END IF;
  v_permission := CASE p_action WHEN 'update' THEN 'portfolio.edit' ELSE 'portfolio.archive' END;
  IF NOT private.actor_has_scope_permission(p_tenant_id, v_permission, 'portfolio', p_portfolio_id::TEXT) THEN
    RAISE EXCEPTION 'Portfolio mutation is not permitted' USING ERRCODE = '42501';
  END IF;
  v_request := pg_catalog.jsonb_build_object('action',p_action,'patch',p_patch,'expectedVersion',p_expected_version::TEXT);
  SELECT * INTO v_existing FROM public.audit_events a WHERE a.tenant_id=p_tenant_id
    AND a.source=v_source AND a.idempotency_key=p_action || ':' || p_idempotency_key::TEXT FOR UPDATE;
  IF FOUND THEN
    IF v_existing.actor_id <> v_actor OR v_existing.resource_id <> p_portfolio_id OR v_existing.reason <> p_reason
       OR v_existing.before_redacted->'request' <> v_request THEN
      RAISE EXCEPTION 'Idempotency key payload mismatch' USING ERRCODE = '23505';
    END IF;
    RETURN pg_catalog.jsonb_build_object('portfolio',v_existing.after_redacted->'resource',
      'correlationId',v_existing.correlation_id,'idempotentReplay',TRUE);
  END IF;
  SELECT * INTO v_row FROM public.portfolios p WHERE p.tenant_id=p_tenant_id AND p.id=p_portfolio_id FOR UPDATE;
  IF NOT FOUND OR v_row.archived_at IS NOT NULL OR v_row.status <> 'active' THEN
    RAISE EXCEPTION 'Portfolio unavailable' USING ERRCODE = '42501';
  END IF;
  IF v_row.version <> p_expected_version THEN RAISE EXCEPTION 'Portfolio version is stale' USING ERRCODE = '40001'; END IF;
  IF p_action='archive' AND EXISTS (
    SELECT 1 FROM public.portfolio_projects l JOIN public.projects p ON p.tenant_id=l.tenant_id AND p.id=l.project_id
    WHERE l.tenant_id=p_tenant_id AND l.portfolio_id=p_portfolio_id AND l.removed_at IS NULL AND p.archived_at IS NULL
  ) THEN RAISE EXCEPTION 'Archive active Projects first' USING ERRCODE = '23514'; END IF;
  v_before := pg_catalog.to_jsonb(v_row);
  IF p_action='archive' THEN
    UPDATE public.portfolios SET status='archived', archived_at=v_now, updated_at=v_now,
      updated_by=v_actor, version=version+1 WHERE tenant_id=p_tenant_id AND id=p_portfolio_id AND version=p_expected_version RETURNING * INTO v_row;
  ELSE
    UPDATE public.portfolios SET
      name=CASE WHEN p_patch ? 'name' THEN pg_catalog.btrim(p_patch->>'name') ELSE name END,
      code=CASE WHEN p_patch ? 'code' THEN NULLIF(pg_catalog.btrim(p_patch->>'code'),'') ELSE code END,
      sponsor_id=CASE WHEN p_patch ? 'sponsorId' THEN NULLIF(p_patch->>'sponsorId','null')::UUID ELSE sponsor_id END,
      category=CASE WHEN p_patch ? 'category' THEN pg_catalog.btrim(p_patch->>'category') ELSE category END,
      start_date=CASE WHEN p_patch ? 'startDate' THEN NULLIF(p_patch->>'startDate','null')::DATE ELSE start_date END,
      target_end_date=CASE WHEN p_patch ? 'targetEndDate' THEN NULLIF(p_patch->>'targetEndDate','null')::DATE ELSE target_end_date END,
      updated_at=v_now, updated_by=v_actor, version=version+1
    WHERE tenant_id=p_tenant_id AND id=p_portfolio_id AND version=p_expected_version RETURNING * INTO v_row;
  END IF;
  IF NOT FOUND THEN RAISE EXCEPTION 'Portfolio version is stale' USING ERRCODE = '40001'; END IF;
  IF v_row.sponsor_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM public.memberships m
      WHERE m.tenant_id=p_tenant_id AND m.user_id=v_row.sponsor_id AND m.status='active') THEN
    RAISE EXCEPTION 'Sponsor unavailable' USING ERRCODE = '42501';
  END IF;
  IF v_row.start_date IS NOT NULL AND v_row.target_end_date IS NOT NULL AND v_row.target_end_date < v_row.start_date THEN
    RAISE EXCEPTION 'Invalid Portfolio date range' USING ERRCODE = '22023';
  END IF;
  v_after := pg_catalog.to_jsonb(v_row);
  INSERT INTO public.audit_events (tenant_id,actor_id,actor_type,action,resource_type,resource_id,
    correlation_id,reason,before_redacted,after_redacted,source,schema_version,idempotency_key)
  VALUES (p_tenant_id,v_actor,'user','portfolio.'||p_action,'portfolio',p_portfolio_id,v_correlation,
    p_reason,pg_catalog.jsonb_build_object('resource',v_before,'request',v_request),
    pg_catalog.jsonb_build_object('resource',v_after),v_source,'1',p_action||':'||p_idempotency_key::TEXT);
  RETURN pg_catalog.jsonb_build_object('portfolio',v_after,'correlationId',v_correlation,'idempotentReplay',FALSE);
END;
$function$;

CREATE OR REPLACE FUNCTION private.mutate_project(
  p_tenant_id UUID, p_project_id UUID, p_action TEXT, p_patch JSONB,
  p_expected_version BIGINT, p_reason TEXT, p_idempotency_key UUID
)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $function$
DECLARE
  v_actor UUID := auth.uid();
  v_now TIMESTAMPTZ := pg_catalog.now();
  v_permission TEXT;
  v_row public.projects%ROWTYPE;
  v_existing public.audit_events%ROWTYPE;
  v_before JSONB;
  v_after JSONB;
  v_request JSONB;
  v_correlation UUID := gen_random_uuid();
  v_source TEXT := 'project-mutation';
BEGIN
  IF v_actor IS NULL OR p_tenant_id IS NULL OR p_project_id IS NULL
     OR p_action NOT IN ('update','archive') OR p_expected_version IS NULL OR p_expected_version < 1
     OR p_idempotency_key IS NULL OR p_reason IS NULL OR p_reason <> pg_catalog.btrim(p_reason)
     OR pg_catalog.char_length(p_reason) NOT BETWEEN 1 AND 1000 OR p_patch IS NULL
     OR pg_catalog.jsonb_typeof(p_patch) <> 'object' THEN
    RAISE EXCEPTION 'Invalid Project mutation' USING ERRCODE = '22023';
  END IF;
  IF p_action='update' AND (p_patch='{}'::JSONB OR EXISTS (
      SELECT 1 FROM pg_catalog.jsonb_object_keys(p_patch) AS k
      WHERE k NOT IN ('name','code','sponsorId','priority','scopeSummary','startDate','targetEndDate')
    )) THEN RAISE EXCEPTION 'Invalid Project fields' USING ERRCODE = '22023'; END IF;
  IF p_action='archive' AND p_patch<>'{}'::JSONB THEN RAISE EXCEPTION 'Archive does not accept fields' USING ERRCODE = '22023'; END IF;
  IF p_patch ? 'name' AND (pg_catalog.jsonb_typeof(p_patch->'name')<>'string' OR pg_catalog.char_length(pg_catalog.btrim(p_patch->>'name')) NOT BETWEEN 1 AND 160)
     OR p_patch ? 'code' AND p_patch->'code'<>'null'::JSONB AND (pg_catalog.jsonb_typeof(p_patch->'code')<>'string'
       OR p_patch->>'code'<>pg_catalog.upper(pg_catalog.btrim(p_patch->>'code')) OR pg_catalog.char_length(p_patch->>'code') NOT BETWEEN 1 AND 40)
     OR p_patch ? 'sponsorId' AND p_patch->'sponsorId'<>'null'::JSONB AND (pg_catalog.jsonb_typeof(p_patch->'sponsorId')<>'string' OR (p_patch->>'sponsorId')::UUID IS NULL)
     OR p_patch ? 'priority' AND (pg_catalog.jsonb_typeof(p_patch->'priority')<>'string' OR p_patch->>'priority' NOT IN ('low','medium','high','critical'))
     OR p_patch ? 'scopeSummary' AND p_patch->'scopeSummary'<>'null'::JSONB AND (pg_catalog.jsonb_typeof(p_patch->'scopeSummary')<>'string' OR pg_catalog.char_length(p_patch->>'scopeSummary')>2000)
     OR p_patch ? 'startDate' AND p_patch->'startDate'<>'null'::JSONB AND pg_catalog.jsonb_typeof(p_patch->'startDate')<>'string'
     OR p_patch ? 'targetEndDate' AND p_patch->'targetEndDate'<>'null'::JSONB AND pg_catalog.jsonb_typeof(p_patch->'targetEndDate')<>'string' THEN
    RAISE EXCEPTION 'Invalid Project fields' USING ERRCODE = '22023';
  END IF;
  v_permission := CASE p_action WHEN 'update' THEN 'project.edit' ELSE 'project.archive' END;
  IF NOT private.actor_has_scope_permission(p_tenant_id,v_permission,'project',p_project_id::TEXT) THEN
    RAISE EXCEPTION 'Project mutation is not permitted' USING ERRCODE = '42501';
  END IF;
  v_request := pg_catalog.jsonb_build_object('action',p_action,'patch',p_patch,'expectedVersion',p_expected_version::TEXT);
  SELECT * INTO v_existing FROM public.audit_events a WHERE a.tenant_id=p_tenant_id
    AND a.source=v_source AND a.idempotency_key=p_action||':'||p_idempotency_key::TEXT FOR UPDATE;
  IF FOUND THEN
    IF v_existing.actor_id<>v_actor OR v_existing.resource_id<>p_project_id OR v_existing.reason<>p_reason
       OR v_existing.before_redacted->'request'<>v_request THEN
      RAISE EXCEPTION 'Idempotency key payload mismatch' USING ERRCODE = '23505';
    END IF;
    RETURN pg_catalog.jsonb_build_object('project',v_existing.after_redacted->'resource',
      'correlationId',v_existing.correlation_id,'idempotentReplay',TRUE);
  END IF;
  SELECT * INTO v_row FROM public.projects p WHERE p.tenant_id=p_tenant_id AND p.id=p_project_id FOR UPDATE;
  IF NOT FOUND OR v_row.archived_at IS NOT NULL THEN RAISE EXCEPTION 'Project unavailable' USING ERRCODE = '42501'; END IF;
  IF v_row.version<>p_expected_version THEN RAISE EXCEPTION 'Project version is stale' USING ERRCODE = '40001'; END IF;
  v_before:=pg_catalog.to_jsonb(v_row);
  IF p_action='archive' THEN
    UPDATE public.projects SET archived_at=v_now,updated_at=v_now,updated_by=v_actor,version=version+1
      WHERE tenant_id=p_tenant_id AND id=p_project_id AND version=p_expected_version RETURNING * INTO v_row;
  ELSE
    UPDATE public.projects SET
      name=CASE WHEN p_patch ? 'name' THEN pg_catalog.btrim(p_patch->>'name') ELSE name END,
      code=CASE WHEN p_patch ? 'code' THEN NULLIF(pg_catalog.btrim(p_patch->>'code'),'') ELSE code END,
      sponsor_id=CASE WHEN p_patch ? 'sponsorId' THEN NULLIF(p_patch->>'sponsorId','null')::UUID ELSE sponsor_id END,
      priority=CASE WHEN p_patch ? 'priority' THEN p_patch->>'priority' ELSE priority END,
      scope_summary=CASE WHEN p_patch ? 'scopeSummary' THEN NULLIF(pg_catalog.btrim(p_patch->>'scopeSummary'),'') ELSE scope_summary END,
      start_date=CASE WHEN p_patch ? 'startDate' THEN NULLIF(p_patch->>'startDate','null')::DATE ELSE start_date END,
      target_end_date=CASE WHEN p_patch ? 'targetEndDate' THEN NULLIF(p_patch->>'targetEndDate','null')::DATE ELSE target_end_date END,
      updated_at=v_now,updated_by=v_actor,version=version+1
    WHERE tenant_id=p_tenant_id AND id=p_project_id AND version=p_expected_version RETURNING * INTO v_row;
  END IF;
  IF NOT FOUND THEN RAISE EXCEPTION 'Project version is stale' USING ERRCODE = '40001'; END IF;
  IF v_row.sponsor_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM public.memberships m
      WHERE m.tenant_id=p_tenant_id AND m.user_id=v_row.sponsor_id AND m.status='active') THEN
    RAISE EXCEPTION 'Sponsor unavailable' USING ERRCODE = '42501';
  END IF;
  IF v_row.start_date IS NOT NULL AND v_row.target_end_date IS NOT NULL AND v_row.target_end_date<v_row.start_date THEN
    RAISE EXCEPTION 'Invalid Project date range' USING ERRCODE = '22023';
  END IF;
  v_after:=pg_catalog.to_jsonb(v_row);
  INSERT INTO public.audit_events (tenant_id,actor_id,actor_type,action,resource_type,resource_id,
    correlation_id,reason,before_redacted,after_redacted,source,schema_version,idempotency_key)
  VALUES (p_tenant_id,v_actor,'user','project.'||p_action,'project',p_project_id,v_correlation,
    p_reason,pg_catalog.jsonb_build_object('resource',v_before,'request',v_request),
    pg_catalog.jsonb_build_object('resource',v_after),v_source,'1',p_action||':'||p_idempotency_key::TEXT);
  RETURN pg_catalog.jsonb_build_object('project',v_after,'correlationId',v_correlation,'idempotentReplay',FALSE);
END;
$function$;

CREATE OR REPLACE FUNCTION public.mutate_portfolio(
  p_tenant_id UUID,p_portfolio_id UUID,p_action TEXT,p_patch JSONB,
  p_expected_version BIGINT,p_reason TEXT,p_idempotency_key UUID
) RETURNS JSONB LANGUAGE SQL SECURITY INVOKER SET search_path=''
AS $function$ SELECT private.mutate_portfolio(p_tenant_id,p_portfolio_id,p_action,p_patch,p_expected_version,p_reason,p_idempotency_key); $function$;
CREATE OR REPLACE FUNCTION public.mutate_project(
  p_tenant_id UUID,p_project_id UUID,p_action TEXT,p_patch JSONB,
  p_expected_version BIGINT,p_reason TEXT,p_idempotency_key UUID
) RETURNS JSONB LANGUAGE SQL SECURITY INVOKER SET search_path=''
AS $function$ SELECT private.mutate_project(p_tenant_id,p_project_id,p_action,p_patch,p_expected_version,p_reason,p_idempotency_key); $function$;

CREATE OR REPLACE FUNCTION private.list_tenant_portfolios(p_tenant_id UUID)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $function$
DECLARE v_actor UUID:=auth.uid(); v_rows JSONB; v_can_create BOOLEAN;
BEGIN
  IF v_actor IS NULL OR p_tenant_id IS NULL OR NOT EXISTS (
    SELECT 1 FROM public.memberships m JOIN public.tenants t ON t.id=m.tenant_id
    WHERE m.tenant_id=p_tenant_id AND m.user_id=v_actor AND m.status='active' AND t.status='active'
  ) THEN RAISE EXCEPTION 'Tenant unavailable' USING ERRCODE='42501'; END IF;
  v_can_create:=private.actor_has_scope_permission(p_tenant_id,'portfolio.create','tenant',p_tenant_id::TEXT);
  SELECT COALESCE(pg_catalog.jsonb_agg(pg_catalog.jsonb_build_object(
    'id',p.id,'tenantId',p.tenant_id,'name',p.name,'code',p.code,'category',p.category,
    'ownerId',p.owner_id,'sponsorId',p.sponsor_id,'status',p.status,'startDate',p.start_date,
    'targetEndDate',p.target_end_date,'version',p.version::TEXT,
    'canEdit',private.actor_has_scope_permission(p_tenant_id,'portfolio.edit','portfolio',p.id::TEXT),
    'canArchive',private.actor_has_scope_permission(p_tenant_id,'portfolio.archive','portfolio',p.id::TEXT)
      AND NOT EXISTS (SELECT 1 FROM public.portfolio_projects l JOIN public.projects pr
        ON pr.tenant_id=l.tenant_id AND pr.id=l.project_id WHERE l.tenant_id=p_tenant_id
        AND l.portfolio_id=p.id AND l.removed_at IS NULL AND pr.archived_at IS NULL)
  ) ORDER BY p.name,p.id),'[]'::JSONB) INTO v_rows
  FROM public.portfolios p WHERE p.tenant_id=p_tenant_id AND p.status='active' AND p.archived_at IS NULL
    AND private.actor_has_scope_permission(p_tenant_id,'portfolio.view','portfolio',p.id::TEXT);
  RETURN pg_catalog.jsonb_build_object('portfolios',v_rows,'canCreate',v_can_create);
END;
$function$;

CREATE OR REPLACE FUNCTION private.list_portfolio_projects(p_tenant_id UUID,p_portfolio_id UUID)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $function$
DECLARE v_actor UUID:=auth.uid(); v_rows JSONB; v_can_create BOOLEAN;
BEGIN
  IF v_actor IS NULL OR p_tenant_id IS NULL OR p_portfolio_id IS NULL OR NOT EXISTS (
    SELECT 1 FROM public.memberships m JOIN public.tenants t ON t.id=m.tenant_id
    WHERE m.tenant_id=p_tenant_id AND m.user_id=v_actor AND m.status='active' AND t.status='active'
  ) THEN RAISE EXCEPTION 'Tenant unavailable' USING ERRCODE='42501'; END IF;
  v_can_create:=private.actor_has_scope_permission(p_tenant_id,'project.create','portfolio',p_portfolio_id::TEXT)
    AND EXISTS (SELECT 1 FROM public.portfolios p WHERE p.tenant_id=p_tenant_id AND p.id=p_portfolio_id
      AND p.status='active' AND p.archived_at IS NULL);
  SELECT COALESCE(pg_catalog.jsonb_agg(pg_catalog.jsonb_build_object(
    'id',p.id,'tenantId',p.tenant_id,'portfolioId',l.portfolio_id,'name',p.name,'code',p.code,
    'status',p.status,'priority',p.priority,'scopeSummary',p.scope_summary,
    'projectManagerId',p.project_manager_id,'sponsorId',p.sponsor_id,'startDate',p.start_date,
    'targetEndDate',p.target_end_date,'version',p.version::TEXT,
    'canEdit',private.actor_has_scope_permission(p_tenant_id,'project.edit','project',p.id::TEXT),
    'canArchive',private.actor_has_scope_permission(p_tenant_id,'project.archive','project',p.id::TEXT)
  ) ORDER BY p.name,p.id),'[]'::JSONB) INTO v_rows
  FROM public.projects p JOIN public.portfolio_projects l ON l.tenant_id=p.tenant_id
    AND l.project_id=p.id AND l.portfolio_id=p_portfolio_id AND l.removed_at IS NULL
  WHERE p.tenant_id=p_tenant_id AND p.archived_at IS NULL
    AND private.actor_has_scope_permission(p_tenant_id,'project.view','project',p.id::TEXT);
  RETURN pg_catalog.jsonb_build_object('projects',v_rows,'canCreate',COALESCE(v_can_create,FALSE));
END;
$function$;

REVOKE ALL ON FUNCTION private.list_tenant_portfolios(UUID),private.list_portfolio_projects(UUID,UUID)
  FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION private.list_tenant_portfolios(UUID),private.list_portfolio_projects(UUID,UUID) TO authenticated;

REVOKE ALL ON FUNCTION private.mutate_portfolio(UUID,UUID,TEXT,JSONB,BIGINT,TEXT,UUID),
  private.mutate_project(UUID,UUID,TEXT,JSONB,BIGINT,TEXT,UUID) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION private.mutate_portfolio(UUID,UUID,TEXT,JSONB,BIGINT,TEXT,UUID),
  private.mutate_project(UUID,UUID,TEXT,JSONB,BIGINT,TEXT,UUID) TO authenticated;
REVOKE ALL ON FUNCTION public.mutate_portfolio(UUID,UUID,TEXT,JSONB,BIGINT,TEXT,UUID),
  public.mutate_project(UUID,UUID,TEXT,JSONB,BIGINT,TEXT,UUID) FROM PUBLIC,anon,service_role;
GRANT EXECUTE ON FUNCTION public.mutate_portfolio(UUID,UUID,TEXT,JSONB,BIGINT,TEXT,UUID),
  public.mutate_project(UUID,UUID,TEXT,JSONB,BIGINT,TEXT,UUID) TO authenticated;

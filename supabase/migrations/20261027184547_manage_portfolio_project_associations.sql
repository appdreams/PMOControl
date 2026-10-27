-- F2-05: independently manage temporal Project–Portfolio associations.
-- Removing a link never deletes or mutates the Project itself.

INSERT INTO private.tenant_role_preset_permissions (catalog_version,role_key,role_name,permission_key)
VALUES ('rbac-v1','pmo_admin','PMO Admin','portfolio.projects.associate'),
       ('rbac-v1','pmo_admin','PMO Admin','portfolio.projects.remove')
ON CONFLICT (catalog_version,role_key,permission_key) DO NOTHING;
INSERT INTO public.role_permissions (role_id,permission_key)
SELECT r.id,p.permission_key FROM public.roles r
CROSS JOIN (VALUES ('portfolio.projects.associate'),('portfolio.projects.remove')) p(permission_key)
WHERE r.key='pmo_admin' AND r.scope_type='tenant' AND r.status='active'
ON CONFLICT (role_id,permission_key) DO NOTHING;

CREATE OR REPLACE FUNCTION private.list_tenant_portfolios(p_tenant_id UUID)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path=''
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
        AND l.portfolio_id=p.id AND l.removed_at IS NULL AND pr.archived_at IS NULL),
    'canAssociate',private.actor_has_scope_permission(p_tenant_id,'portfolio.projects.associate','portfolio',p.id::TEXT)
  ) ORDER BY p.name,p.id),'[]'::JSONB) INTO v_rows FROM public.portfolios p
  WHERE p.tenant_id=p_tenant_id AND p.status='active' AND p.archived_at IS NULL
    AND private.actor_has_scope_permission(p_tenant_id,'portfolio.view','portfolio',p.id::TEXT);
  RETURN pg_catalog.jsonb_build_object('portfolios',v_rows,'canCreate',v_can_create);
END;
$function$;

CREATE OR REPLACE FUNCTION private.list_portfolio_projects(p_tenant_id UUID,p_portfolio_id UUID)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path=''
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
    'associationId',l.id,'associationVersion',l.version::TEXT,
    'canEdit',private.actor_has_scope_permission(p_tenant_id,'project.edit','project',p.id::TEXT),
    'canArchive',private.actor_has_scope_permission(p_tenant_id,'project.archive','project',p.id::TEXT),
    'canRemoveAssociation',private.actor_has_scope_permission(p_tenant_id,'portfolio.projects.remove','portfolio',p_portfolio_id::TEXT)
  ) ORDER BY p.name,p.id),'[]'::JSONB) INTO v_rows FROM public.projects p
  JOIN public.portfolio_projects l ON l.tenant_id=p.tenant_id AND l.project_id=p.id
    AND l.portfolio_id=p_portfolio_id AND l.removed_at IS NULL
  WHERE p.tenant_id=p_tenant_id AND p.archived_at IS NULL
    AND private.actor_has_scope_permission(p_tenant_id,'project.view','project',p.id::TEXT);
  RETURN pg_catalog.jsonb_build_object('projects',v_rows,'canCreate',COALESCE(v_can_create,FALSE));
END;
$function$;

CREATE OR REPLACE FUNCTION private.list_associable_projects(p_tenant_id UUID,p_portfolio_id UUID)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path=''
AS $function$
DECLARE v_actor UUID:=auth.uid(); v_rows JSONB;
BEGIN
  IF v_actor IS NULL OR p_tenant_id IS NULL OR p_portfolio_id IS NULL
    OR NOT private.actor_has_scope_permission(p_tenant_id,'portfolio.projects.associate','portfolio',p_portfolio_id::TEXT)
    OR NOT EXISTS (SELECT 1 FROM public.portfolios p WHERE p.tenant_id=p_tenant_id AND p.id=p_portfolio_id
       AND p.status='active' AND p.archived_at IS NULL)
  THEN RAISE EXCEPTION 'Portfolio unavailable' USING ERRCODE='42501'; END IF;
  SELECT COALESCE(pg_catalog.jsonb_agg(pg_catalog.jsonb_build_object('id',p.id,'name',p.name,'code',p.code)
    ORDER BY p.name,p.id),'[]'::JSONB) INTO v_rows FROM public.projects p
  WHERE p.tenant_id=p_tenant_id AND p.archived_at IS NULL
    AND private.actor_has_scope_permission(p_tenant_id,'project.view','project',p.id::TEXT)
    AND NOT EXISTS (SELECT 1 FROM public.portfolio_projects l WHERE l.tenant_id=p_tenant_id
      AND l.portfolio_id=p_portfolio_id AND l.project_id=p.id AND l.removed_at IS NULL);
  RETURN pg_catalog.jsonb_build_object('projects',v_rows);
END;
$function$;

CREATE OR REPLACE FUNCTION private.mutate_portfolio_project_association(
  p_tenant_id UUID,p_portfolio_id UUID,p_action TEXT,p_project_id UUID,p_association_id UUID,
  p_expected_version BIGINT,p_reason TEXT,p_idempotency_key UUID
) RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path=''
AS $function$
DECLARE
  v_actor UUID:=auth.uid(); v_now TIMESTAMPTZ:=pg_catalog.now(); v_row public.portfolio_projects%ROWTYPE;
  v_existing public.audit_events%ROWTYPE; v_before JSONB; v_after JSONB; v_request JSONB;
  v_corr UUID:=gen_random_uuid(); v_permission TEXT; v_resource UUID;
BEGIN
  IF v_actor IS NULL OR p_tenant_id IS NULL OR p_portfolio_id IS NULL
    OR p_action NOT IN ('associate','remove') OR p_idempotency_key IS NULL
    OR p_reason IS NULL OR p_reason<>pg_catalog.btrim(p_reason)
    OR pg_catalog.char_length(p_reason) NOT BETWEEN 1 AND 1000
    OR (p_action='associate' AND (p_project_id IS NULL OR p_association_id IS NOT NULL OR p_expected_version IS NOT NULL))
    OR (p_action='remove' AND (p_association_id IS NULL OR p_project_id IS NOT NULL OR p_expected_version IS NULL OR p_expected_version<1))
  THEN RAISE EXCEPTION 'Invalid association mutation' USING ERRCODE='22023'; END IF;
  v_permission:=CASE p_action WHEN 'associate' THEN 'portfolio.projects.associate' ELSE 'portfolio.projects.remove' END;
  IF NOT private.actor_has_scope_permission(p_tenant_id,v_permission,'portfolio',p_portfolio_id::TEXT)
    OR NOT EXISTS (SELECT 1 FROM public.portfolios p WHERE p.tenant_id=p_tenant_id AND p.id=p_portfolio_id
      AND p.status='active' AND p.archived_at IS NULL)
  THEN RAISE EXCEPTION 'Association mutation is not permitted' USING ERRCODE='42501'; END IF;
  v_request:=pg_catalog.jsonb_build_object('action',p_action,'projectId',p_project_id,
    'associationId',p_association_id,'expectedVersion',p_expected_version::TEXT);
  SELECT * INTO v_existing FROM public.audit_events a WHERE a.tenant_id=p_tenant_id
    AND a.source='portfolio-project-association' AND a.idempotency_key=p_action||':'||p_idempotency_key::TEXT FOR UPDATE;
  IF FOUND THEN
    IF v_existing.actor_id<>v_actor OR v_existing.resource_id<>p_portfolio_id OR v_existing.reason<>p_reason
      OR v_existing.before_redacted->'request'<>v_request THEN
      RAISE EXCEPTION 'Idempotency key payload mismatch' USING ERRCODE='23505'; END IF;
    RETURN pg_catalog.jsonb_build_object('association',v_existing.after_redacted->'association',
      'correlationId',v_existing.correlation_id,'idempotentReplay',TRUE);
  END IF;
  IF p_action='associate' THEN
    IF NOT private.actor_has_scope_permission(p_tenant_id,'project.view','project',p_project_id::TEXT)
      OR NOT EXISTS (SELECT 1 FROM public.projects p WHERE p.tenant_id=p_tenant_id AND p.id=p_project_id AND p.archived_at IS NULL)
    THEN RAISE EXCEPTION 'Project unavailable' USING ERRCODE='42501'; END IF;
    INSERT INTO public.portfolio_projects(tenant_id,portfolio_id,project_id,linked_by)
      VALUES(p_tenant_id,p_portfolio_id,p_project_id,v_actor) RETURNING * INTO v_row;
    v_before:='{}'::JSONB; v_resource:=p_portfolio_id;
  ELSE
    SELECT * INTO v_row FROM public.portfolio_projects l WHERE l.tenant_id=p_tenant_id
      AND l.portfolio_id=p_portfolio_id AND l.id=p_association_id AND l.removed_at IS NULL FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Association unavailable' USING ERRCODE='42501'; END IF;
    IF v_row.version<>p_expected_version THEN RAISE EXCEPTION 'Association version is stale' USING ERRCODE='40001'; END IF;
    v_before:=pg_catalog.to_jsonb(v_row);
    UPDATE public.portfolio_projects SET removed_at=v_now,removed_by=v_actor,version=version+1
      WHERE tenant_id=p_tenant_id AND id=p_association_id AND version=p_expected_version RETURNING * INTO v_row;
    v_resource:=p_portfolio_id;
  END IF;
  v_after:=pg_catalog.to_jsonb(v_row);
  INSERT INTO public.audit_events(tenant_id,actor_id,actor_type,action,resource_type,resource_id,
    correlation_id,reason,before_redacted,after_redacted,source,schema_version,idempotency_key)
  VALUES(p_tenant_id,v_actor,'user','portfolio_project.'||p_action,'portfolio',v_resource,v_corr,p_reason,
    pg_catalog.jsonb_build_object('association',v_before,'request',v_request),
    pg_catalog.jsonb_build_object('association',v_after),'portfolio-project-association','1',
    p_action||':'||p_idempotency_key::TEXT);
  RETURN pg_catalog.jsonb_build_object('association',v_after,'correlationId',v_corr,'idempotentReplay',FALSE);
END;
$function$;

CREATE OR REPLACE FUNCTION public.list_associable_projects(p_tenant_id UUID,p_portfolio_id UUID)
RETURNS JSONB LANGUAGE SQL SECURITY INVOKER SET search_path=''
AS $function$ SELECT private.list_associable_projects(p_tenant_id,p_portfolio_id); $function$;
CREATE OR REPLACE FUNCTION public.mutate_portfolio_project_association(
  p_tenant_id UUID,p_portfolio_id UUID,p_action TEXT,p_project_id UUID,p_association_id UUID,
  p_expected_version BIGINT,p_reason TEXT,p_idempotency_key UUID
) RETURNS JSONB LANGUAGE SQL SECURITY INVOKER SET search_path=''
AS $function$ SELECT private.mutate_portfolio_project_association(
  p_tenant_id,p_portfolio_id,p_action,p_project_id,p_association_id,p_expected_version,p_reason,p_idempotency_key); $function$;

REVOKE ALL ON FUNCTION private.list_tenant_portfolios(UUID),private.list_portfolio_projects(UUID,UUID),
  private.list_associable_projects(UUID,UUID),
  private.mutate_portfolio_project_association(UUID,UUID,TEXT,UUID,UUID,BIGINT,TEXT,UUID)
  FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION private.list_tenant_portfolios(UUID),private.list_portfolio_projects(UUID,UUID),
  private.list_associable_projects(UUID,UUID),
  private.mutate_portfolio_project_association(UUID,UUID,TEXT,UUID,UUID,BIGINT,TEXT,UUID) TO authenticated;
REVOKE ALL ON FUNCTION public.list_associable_projects(UUID,UUID),
  public.mutate_portfolio_project_association(UUID,UUID,TEXT,UUID,UUID,BIGINT,TEXT,UUID) FROM PUBLIC,anon,service_role;
GRANT EXECUTE ON FUNCTION public.list_associable_projects(UUID,UUID),
  public.mutate_portfolio_project_association(UUID,UUID,TEXT,UUID,UUID,BIGINT,TEXT,UUID) TO authenticated;

-- F2-04: change the designated Project Manager without conflating the
-- business owner field with general resource-role administration.
CREATE OR REPLACE FUNCTION private.list_project_manager_candidates(p_tenant_id UUID,p_project_id UUID)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path=''
AS $function$
DECLARE v_actor UUID:=auth.uid(); v_manager UUID; v_manager_name TEXT; v_candidates JSONB;
BEGIN
  IF v_actor IS NULL OR p_tenant_id IS NULL OR p_project_id IS NULL
    OR NOT private.actor_has_scope_permission(p_tenant_id,'project.assign','project',p_project_id::TEXT)
  THEN RAISE EXCEPTION 'Project assignment is not permitted' USING ERRCODE='42501'; END IF;
  SELECT p.project_manager_id,up.display_name INTO v_manager,v_manager_name
  FROM public.projects p LEFT JOIN public.user_profiles up ON up.user_id=p.project_manager_id
  WHERE p.tenant_id=p_tenant_id AND p.id=p_project_id AND p.archived_at IS NULL FOR SHARE OF p;
  IF NOT FOUND THEN RAISE EXCEPTION 'Project unavailable' USING ERRCODE='42501'; END IF;
  SELECT COALESCE(pg_catalog.jsonb_agg(pg_catalog.jsonb_build_object(
    'userId',m.user_id,'displayName',COALESCE(NULLIF(pg_catalog.btrim(up.display_name),''),'Usuário sem nome de exibição')
  ) ORDER BY COALESCE(up.display_name,''),m.user_id),'[]'::JSONB) INTO v_candidates
  FROM public.memberships m LEFT JOIN public.user_profiles up ON up.user_id=m.user_id
  WHERE m.tenant_id=p_tenant_id AND m.status='active' AND m.user_id<>v_actor;
  RETURN pg_catalog.jsonb_build_object('manager',CASE WHEN v_manager IS NULL THEN NULL ELSE
    pg_catalog.jsonb_build_object('userId',v_manager,'displayName',COALESCE(NULLIF(pg_catalog.btrim(v_manager_name),''),'Usuário sem nome de exibição')) END,
    'candidates',v_candidates);
END;
$function$;

CREATE OR REPLACE FUNCTION private.assign_project_manager(
  p_tenant_id UUID,p_project_id UUID,p_subject_id UUID,p_expected_version BIGINT,
  p_reason TEXT,p_idempotency_key UUID
) RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path=''
AS $function$
DECLARE
  v_actor UUID:=auth.uid(); v_now TIMESTAMPTZ:=pg_catalog.now(); v_project public.projects%ROWTYPE;
  v_existing public.audit_events%ROWTYPE; v_role_id UUID; v_corr UUID:=gen_random_uuid();
  v_request JSONB; v_before JSONB; v_after JSONB; v_previous UUID; v_new_grant UUID;
BEGIN
  IF v_actor IS NULL OR p_tenant_id IS NULL OR p_project_id IS NULL OR p_subject_id IS NULL
    OR p_expected_version IS NULL OR p_expected_version<1 OR p_idempotency_key IS NULL
    OR p_reason IS NULL OR p_reason<>pg_catalog.btrim(p_reason)
    OR pg_catalog.char_length(p_reason) NOT BETWEEN 1 AND 1000
  THEN RAISE EXCEPTION 'Invalid Project Manager assignment' USING ERRCODE='22023'; END IF;
  IF NOT private.actor_has_scope_permission(p_tenant_id,'project.assign','project',p_project_id::TEXT)
  THEN RAISE EXCEPTION 'Project assignment is not permitted' USING ERRCODE='42501'; END IF;
  v_request:=pg_catalog.jsonb_build_object('subjectId',p_subject_id,'expectedVersion',p_expected_version::TEXT);
  SELECT * INTO v_existing FROM public.audit_events a WHERE a.tenant_id=p_tenant_id
    AND a.source='project-manager-assignment' AND a.idempotency_key='assign:'||p_idempotency_key::TEXT FOR UPDATE;
  IF FOUND THEN
    IF v_existing.actor_id<>v_actor OR v_existing.resource_id<>p_project_id OR v_existing.reason<>p_reason
      OR v_existing.before_redacted->'request'<>v_request
    THEN RAISE EXCEPTION 'Idempotency key payload mismatch' USING ERRCODE='23505'; END IF;
    RETURN pg_catalog.jsonb_build_object('project',v_existing.after_redacted->'project',
      'correlationId',v_existing.correlation_id,'idempotentReplay',TRUE);
  END IF;
  PERFORM 1 FROM public.memberships m JOIN public.tenants t ON t.id=m.tenant_id AND t.status='active'
    WHERE m.tenant_id=p_tenant_id AND m.user_id=p_subject_id AND m.status='active' FOR UPDATE OF m;
  IF NOT FOUND THEN RAISE EXCEPTION 'Active target membership required' USING ERRCODE='42501'; END IF;
  SELECT * INTO v_project FROM public.projects p WHERE p.tenant_id=p_tenant_id AND p.id=p_project_id
    AND p.archived_at IS NULL FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Project unavailable' USING ERRCODE='42501'; END IF;
  IF v_project.version<>p_expected_version THEN RAISE EXCEPTION 'Project version is stale' USING ERRCODE='40001'; END IF;
  IF EXISTS (SELECT 1 FROM public.access_grants g JOIN public.roles r ON r.id=g.role_id AND r.status='active'
      JOIN public.role_permissions rp ON rp.role_id=r.id AND rp.permission_key='project.view'
      WHERE g.tenant_id=p_tenant_id AND g.subject_id=p_subject_id AND g.scope_type='project'
        AND g.scope_id=p_project_id::TEXT AND g.effect='deny' AND g.revoked_at IS NULL
        AND g.starts_at<=v_now AND (g.expires_at IS NULL OR g.expires_at>v_now))
  THEN RAISE EXCEPTION 'Target has an explicit Project view denial' USING ERRCODE='42501'; END IF;
  SELECT r.id INTO v_role_id FROM public.roles r WHERE r.tenant_id=p_tenant_id
    AND r.key='project_manager' AND r.scope_type='tenant' AND r.is_system AND r.status='active';
  IF v_role_id IS NULL THEN RAISE EXCEPTION 'Project Manager role unavailable' USING ERRCODE='22023'; END IF;
  IF EXISTS (SELECT 1 FROM public.access_grants g WHERE g.tenant_id=p_tenant_id
      AND g.subject_id=p_subject_id AND g.role_id=v_role_id AND g.scope_type='project'
      AND g.scope_id=p_project_id::TEXT AND g.effect='deny' AND g.revoked_at IS NULL
      AND g.starts_at<=v_now AND (g.expires_at IS NULL OR g.expires_at>v_now))
  THEN RAISE EXCEPTION 'Target has an explicit Project Manager denial' USING ERRCODE='42501'; END IF;
  v_previous:=v_project.project_manager_id;
  v_before:=pg_catalog.to_jsonb(v_project);
  UPDATE public.access_grants g SET revoked_at=v_now,revoked_by=v_actor,
    revocation_reason='Project Manager reassigned: '||p_reason,version=version+1
  FROM public.roles r WHERE r.id=g.role_id AND r.key='project_manager' AND r.tenant_id=p_tenant_id
    AND g.tenant_id=p_tenant_id AND g.scope_type='project' AND g.scope_id=p_project_id::TEXT
    AND g.effect='allow' AND g.revoked_at IS NULL AND g.subject_id<>p_subject_id;
  UPDATE public.access_grants g SET revoked_at=v_now,revoked_by=v_actor,
    revocation_reason='Project Manager reassigned: '||p_reason,version=version+1
  WHERE g.tenant_id=p_tenant_id AND g.subject_id=p_subject_id AND g.role_id=v_role_id
    AND g.scope_type='project' AND g.scope_id=p_project_id::TEXT AND g.effect='allow'
    AND g.revoked_at IS NULL AND (g.starts_at>v_now OR (g.expires_at IS NOT NULL AND g.expires_at<=v_now));
  SELECT g.id INTO v_new_grant FROM public.access_grants g WHERE g.tenant_id=p_tenant_id
    AND g.subject_id=p_subject_id AND g.role_id=v_role_id AND g.scope_type='project'
    AND g.scope_id=p_project_id::TEXT AND g.effect='allow' AND g.revoked_at IS NULL
    AND g.starts_at<=v_now AND (g.expires_at IS NULL OR g.expires_at>v_now);
  IF v_new_grant IS NULL THEN
    INSERT INTO public.access_grants(tenant_id,subject_id,role_id,role_scope_type,role_tenant_id,
      scope_type,scope_id,effect,granted_by,reason)
    VALUES(p_tenant_id,p_subject_id,v_role_id,'tenant',p_tenant_id,'project',p_project_id::TEXT,
      'allow',v_actor,p_reason) RETURNING id INTO v_new_grant;
  END IF;
  UPDATE public.projects SET project_manager_id=p_subject_id,updated_at=v_now,updated_by=v_actor,version=version+1
    WHERE tenant_id=p_tenant_id AND id=p_project_id RETURNING * INTO v_project;
  v_after:=pg_catalog.to_jsonb(v_project);
  INSERT INTO public.audit_events(tenant_id,actor_id,actor_type,action,resource_type,resource_id,
    correlation_id,reason,before_redacted,after_redacted,source,schema_version,idempotency_key)
  VALUES(p_tenant_id,v_actor,'user','project.manager.assign','project',p_project_id,v_corr,p_reason,
    pg_catalog.jsonb_build_object('project',v_before,'previousManagerId',v_previous,'request',v_request),
    pg_catalog.jsonb_build_object('project',v_after,'previousManagerId',v_previous,'managerGrantId',v_new_grant),
    'project-manager-assignment','1','assign:'||p_idempotency_key::TEXT);
  RETURN pg_catalog.jsonb_build_object('project',v_after,'correlationId',v_corr,'idempotentReplay',FALSE);
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
    'targetEndDate',p.target_end_date,'version',p.version::TEXT,'associationId',l.id,
    'associationVersion',l.version::TEXT,
    'canEdit',private.actor_has_scope_permission(p_tenant_id,'project.edit','project',p.id::TEXT),
    'canArchive',private.actor_has_scope_permission(p_tenant_id,'project.archive','project',p.id::TEXT),
    'canAssignManager',private.actor_has_scope_permission(p_tenant_id,'project.assign','project',p.id::TEXT),
    'canRemoveAssociation',private.actor_has_scope_permission(p_tenant_id,'portfolio.projects.remove','portfolio',p_portfolio_id::TEXT)
  ) ORDER BY p.name,p.id),'[]'::JSONB) INTO v_rows FROM public.projects p
  JOIN public.portfolio_projects l ON l.tenant_id=p.tenant_id AND l.project_id=p.id
    AND l.portfolio_id=p_portfolio_id AND l.removed_at IS NULL
  WHERE p.tenant_id=p_tenant_id AND p.archived_at IS NULL
    AND private.actor_has_scope_permission(p_tenant_id,'project.view','project',p.id::TEXT);
  RETURN pg_catalog.jsonb_build_object('projects',v_rows,'canCreate',COALESCE(v_can_create,FALSE));
END;
$function$;

CREATE OR REPLACE FUNCTION public.list_project_manager_candidates(p_tenant_id UUID,p_project_id UUID)
RETURNS JSONB LANGUAGE SQL SECURITY INVOKER SET search_path=''
AS $function$ SELECT private.list_project_manager_candidates(p_tenant_id,p_project_id); $function$;
CREATE OR REPLACE FUNCTION public.assign_project_manager(
  p_tenant_id UUID,p_project_id UUID,p_subject_id UUID,p_expected_version BIGINT,p_reason TEXT,p_idempotency_key UUID
) RETURNS JSONB LANGUAGE SQL SECURITY INVOKER SET search_path=''
AS $function$ SELECT private.assign_project_manager(p_tenant_id,p_project_id,p_subject_id,p_expected_version,p_reason,p_idempotency_key); $function$;

REVOKE ALL ON FUNCTION private.list_project_manager_candidates(UUID,UUID),
  private.assign_project_manager(UUID,UUID,UUID,BIGINT,TEXT,UUID),
  private.list_portfolio_projects(UUID,UUID) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION private.list_project_manager_candidates(UUID,UUID),
  private.assign_project_manager(UUID,UUID,UUID,BIGINT,TEXT,UUID),
  private.list_portfolio_projects(UUID,UUID) TO authenticated;
REVOKE ALL ON FUNCTION public.list_project_manager_candidates(UUID,UUID),
  public.assign_project_manager(UUID,UUID,UUID,BIGINT,TEXT,UUID) FROM PUBLIC,anon,service_role;
GRANT EXECUTE ON FUNCTION public.list_project_manager_candidates(UUID,UUID),
  public.assign_project_manager(UUID,UUID,UUID,BIGINT,TEXT,UUID) TO authenticated;

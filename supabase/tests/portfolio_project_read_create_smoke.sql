-- Transactional smoke for first Portfolio/Project creation and scoped listing.
BEGIN;
DO $smoke$
DECLARE
  v_actor UUID := gen_random_uuid();
  v_other_actor UUID := gen_random_uuid();
  v_tenant UUID := gen_random_uuid();
  v_other_tenant UUID := gen_random_uuid();
  v_other_portfolio UUID := gen_random_uuid();
  v_admin_role UUID := gen_random_uuid();
  v_pmo_role UUID := gen_random_uuid();
  v_pm_role UUID := gen_random_uuid();
  v_idempotency UUID := gen_random_uuid();
  v_project_key UUID := gen_random_uuid();
  v_update_key UUID := gen_random_uuid();
  v_archive_project_key UUID := gen_random_uuid();
  v_archive_portfolio_key UUID := gen_random_uuid();
  v_association_key UUID := gen_random_uuid();
  v_remove_key UUID := gen_random_uuid();
  v_association_id UUID;
  v_association_version BIGINT;
  v_manager_key UUID := gen_random_uuid();
  v_portfolio_result JSONB;
  v_project_result JSONB;
  v_mutation JSONB;
  v_list JSONB;
  v_portfolio_id UUID;
  v_project_id UUID;
BEGIN
  INSERT INTO auth.users (
    id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
    created_at, updated_at, raw_app_meta_data, raw_user_meta_data
  ) VALUES
    (v_actor, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
     v_actor::text || '@resource-create-smoke.invalid', '', now(), now(), now(),
     '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb),
    (v_other_actor, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
     v_other_actor::text || '@resource-create-smoke.invalid', '', now(), now(), now(),
     '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb);
  INSERT INTO public.tenants (id, slug, display_name, created_by)
  VALUES (v_tenant, 'resource-create-' || left(v_tenant::text, 8), 'Resource create smoke', v_actor),
         (v_other_tenant, 'resource-create-x-' || left(v_other_tenant::text, 8), 'Other resource smoke', v_actor);
  INSERT INTO public.memberships (tenant_id, user_id, status)
  VALUES (v_tenant, v_actor, 'active'), (v_tenant, v_other_actor, 'active'),
         (v_other_tenant, v_actor, 'active');
  INSERT INTO public.roles (id, tenant_id, key, name, scope_type, is_system, status)
  VALUES (v_admin_role, v_tenant, 'tenant_admin', 'Tenant Admin', 'tenant', TRUE, 'active'),
         (v_pmo_role, v_tenant, 'pmo_admin', 'PMO Admin', 'tenant', TRUE, 'active'),
         (v_pm_role, v_tenant, 'project_manager', 'Project Manager', 'tenant', TRUE, 'active');
  INSERT INTO public.role_permissions (role_id, permission_key)
  VALUES (v_admin_role, 'membership.grant'), (v_admin_role, 'portfolio.create'),
         (v_pmo_role, 'portfolio.view'), (v_pmo_role, 'portfolio.edit'),
         (v_pmo_role, 'portfolio.archive'), (v_pmo_role, 'project.create'),
         (v_pmo_role, 'project.view'), (v_pmo_role, 'project.edit'), (v_pmo_role, 'project.archive'),
         (v_pmo_role, 'portfolio.projects.associate'), (v_pmo_role, 'portfolio.projects.remove'),
         (v_pmo_role, 'project.assign'),
         (v_pm_role, 'project.view'), (v_pm_role, 'project.edit'), (v_pm_role, 'project.archive');
  INSERT INTO public.access_grants (
    tenant_id, subject_id, role_id, role_scope_type, role_tenant_id,
    scope_type, scope_id, effect, granted_by, reason
  ) VALUES (v_tenant, v_actor, v_admin_role, 'tenant', v_tenant,
            'tenant', v_tenant::text, 'allow', v_actor, 'Portfolio create smoke');
  INSERT INTO public.portfolios (id, tenant_id, name, category, owner_id, created_by, updated_by)
  VALUES (v_other_portfolio, v_other_tenant, 'Other tenant portfolio', 'internal', v_actor, v_actor, v_actor);

  PERFORM set_config('request.jwt.claim.sub', v_actor::text, TRUE);
  v_portfolio_result := public.create_tenant_portfolio(
    v_tenant, 'Smoke Portfolio', 'SMOKE-01', NULL, 'internal', NULL, NULL,
    'Smoke test create Portfolio', v_idempotency
  );
  v_portfolio_id := (v_portfolio_result->>'portfolioId')::uuid;
  IF v_portfolio_result->>'status' <> 'active' OR v_portfolio_result->>'idempotentReplay' <> 'false'
     OR NOT EXISTS (
       SELECT 1 FROM public.access_grants AS g JOIN public.roles AS r ON r.id = g.role_id
       WHERE g.tenant_id = v_tenant AND g.subject_id = v_actor AND g.scope_type = 'portfolio'
         AND g.scope_id = v_portfolio_id::text AND r.key = 'pmo_admin' AND g.effect = 'allow' AND g.revoked_at IS NULL
     ) THEN RAISE EXCEPTION 'Portfolio creation/owner grant failed'; END IF;
  v_list := public.list_tenant_portfolios(v_tenant);
  IF v_list->>'canCreate' <> 'true' OR NOT EXISTS (
    SELECT 1 FROM pg_catalog.jsonb_array_elements(v_list->'portfolios') AS item
    WHERE item->>'id' = v_portfolio_id::text AND item->>'name' = 'Smoke Portfolio'
  ) THEN RAISE EXCEPTION 'Portfolio list did not return the authorized resource'; END IF;

  v_portfolio_result := public.create_tenant_portfolio(
    v_tenant, 'Smoke Portfolio', 'SMOKE-01', NULL, 'internal', NULL, NULL,
    'Smoke test create Portfolio', v_idempotency
  );
  IF v_portfolio_result->>'portfolioId' <> v_portfolio_id::text OR v_portfolio_result->>'idempotentReplay' <> 'true' THEN
    RAISE EXCEPTION 'Portfolio idempotent replay failed';
  END IF;

  v_project_result := public.create_portfolio_project(
    v_tenant, v_portfolio_id, 'Smoke Project', 'PROJ-01', NULL, 'high',
    'Project created from smoke transaction', NULL, NULL,
    'Smoke test create Project', v_project_key
  );
  v_project_id := (v_project_result->>'projectId')::uuid;
  IF v_project_result->>'status' <> 'planning' OR v_project_result->>'portfolioId' <> v_portfolio_id::text
     OR NOT EXISTS (
       SELECT 1 FROM public.access_grants AS g JOIN public.roles AS r ON r.id = g.role_id
       WHERE g.tenant_id = v_tenant AND g.subject_id = v_actor AND g.scope_type = 'project'
         AND g.scope_id = v_project_id::text AND r.key = 'project_manager' AND g.effect = 'allow' AND g.revoked_at IS NULL
     ) OR NOT EXISTS (
       SELECT 1 FROM public.portfolio_projects AS pp WHERE pp.tenant_id = v_tenant
         AND pp.portfolio_id = v_portfolio_id AND pp.project_id = v_project_id AND pp.removed_at IS NULL
     ) THEN RAISE EXCEPTION 'Project create, association, or initial manager grant failed'; END IF;
  v_list := public.list_portfolio_projects(v_tenant, v_portfolio_id);
  IF v_list->>'canCreate' <> 'true' OR NOT EXISTS (
    SELECT 1 FROM pg_catalog.jsonb_array_elements(v_list->'projects') AS item
    WHERE item->>'id' = v_project_id::text AND item->>'name' = 'Smoke Project'
  ) THEN RAISE EXCEPTION 'Project list did not return the authorized resource'; END IF;

  INSERT INTO public.access_grants(tenant_id,subject_id,role_id,role_scope_type,role_tenant_id,
    scope_type,scope_id,effect,granted_by,reason)
  VALUES(v_tenant,v_actor,v_pmo_role,'tenant',v_tenant,'project',v_project_id::TEXT,
    'allow',v_actor,'Project manager assignment permission smoke');
  v_list:=public.list_project_manager_candidates(v_tenant,v_project_id);
  IF v_list->'manager'->>'userId'<>v_actor::TEXT OR NOT EXISTS (
    SELECT 1 FROM pg_catalog.jsonb_array_elements(v_list->'candidates') c WHERE c->>'userId'=v_other_actor::TEXT
  ) OR EXISTS (SELECT 1 FROM pg_catalog.jsonb_array_elements(v_list->'candidates') c WHERE c->>'userId'=v_actor::TEXT)
  THEN RAISE EXCEPTION 'Project Manager member selector returned incorrect candidates'; END IF;
  v_list:=public.list_portfolio_projects(v_tenant,v_portfolio_id);
  IF NOT EXISTS (SELECT 1 FROM pg_catalog.jsonb_array_elements(v_list->'projects') item
    WHERE item->>'id'=v_project_id::TEXT AND item->>'canAssignManager'='true')
  THEN RAISE EXCEPTION 'Project Manager capability was not returned for the exact Project grant'; END IF;
  v_mutation:=public.assign_project_manager(v_tenant,v_project_id,v_other_actor,1,
    'Project Manager transfer smoke',v_manager_key);
  IF v_mutation->'project'->>'project_manager_id'<>v_other_actor::TEXT
    OR v_mutation->'project'->>'version'<>'2' OR v_mutation->>'idempotentReplay'<>'false'
    OR NOT EXISTS (SELECT 1 FROM public.access_grants g JOIN public.roles r ON r.id=g.role_id
      WHERE g.tenant_id=v_tenant AND g.subject_id=v_other_actor AND g.scope_type='project'
        AND g.scope_id=v_project_id::TEXT AND g.effect='allow' AND g.revoked_at IS NULL AND r.key='project_manager')
    OR EXISTS (SELECT 1 FROM public.access_grants g JOIN public.roles r ON r.id=g.role_id
      WHERE g.tenant_id=v_tenant AND g.subject_id=v_actor AND g.scope_type='project'
        AND g.scope_id=v_project_id::TEXT AND g.effect='allow' AND g.revoked_at IS NULL AND r.key='project_manager')
  THEN RAISE EXCEPTION 'Project Manager transfer and access synchronization failed'; END IF;
  BEGIN
    PERFORM public.assign_project_manager(v_tenant,v_project_id,v_other_actor,2,
      'No-op Project Manager assignment smoke',gen_random_uuid());
    RAISE EXCEPTION 'No-op Project Manager assignment unexpectedly succeeded';
  EXCEPTION WHEN SQLSTATE '22023' THEN NULL;
  END;
  v_mutation:=public.assign_project_manager(v_tenant,v_project_id,v_other_actor,1,
    'Project Manager transfer smoke',v_manager_key);
  IF v_mutation->>'idempotentReplay'<>'true' OR (SELECT count(*) FROM public.audit_events
      WHERE tenant_id=v_tenant AND source='project-manager-assignment'
        AND idempotency_key='assign:'||v_manager_key::TEXT)<>1
  THEN RAISE EXCEPTION 'Project Manager transfer replay duplicated audit'; END IF;
  BEGIN
    PERFORM public.assign_project_manager(v_tenant,v_project_id,v_actor,1,
      'Stale manager change',gen_random_uuid());
    RAISE EXCEPTION 'Stale Project Manager assignment unexpectedly succeeded';
  EXCEPTION WHEN SQLSTATE '40001' THEN NULL;
  END;

  SELECT id,version INTO v_association_id,v_association_version FROM public.portfolio_projects
    WHERE tenant_id=v_tenant AND portfolio_id=v_portfolio_id AND project_id=v_project_id AND removed_at IS NULL;
  v_mutation:=public.mutate_portfolio_project_association(v_tenant,v_portfolio_id,'remove',NULL,
    v_association_id,v_association_version,'Remove Project from Portfolio',v_remove_key);
  IF v_mutation->'association'->>'removed_at' IS NULL OR v_mutation->'association'->>'version'<>'2' THEN
    RAISE EXCEPTION 'Temporal Project–Portfolio unlink failed'; END IF;
  v_mutation:=public.mutate_portfolio_project_association(v_tenant,v_portfolio_id,'remove',NULL,
    v_association_id,v_association_version,'Remove Project from Portfolio',v_remove_key);
  IF v_mutation->>'idempotentReplay'<>'true' THEN RAISE EXCEPTION 'Unlink idempotent replay failed'; END IF;
  BEGIN
    PERFORM public.mutate_portfolio_project_association(v_tenant,v_portfolio_id,'remove',NULL,
      v_association_id,v_association_version,'Stale unlink',gen_random_uuid());
    RAISE EXCEPTION 'Stale association version unexpectedly succeeded';
  EXCEPTION WHEN SQLSTATE '40001' THEN NULL;
  END;
  v_mutation:=public.mutate_portfolio_project_association(v_tenant,v_portfolio_id,'associate',v_project_id,
    NULL,NULL,'Relink Project to Portfolio',v_association_key);
  IF v_mutation->'association'->>'removed_at' IS NOT NULL OR v_mutation->>'idempotentReplay'<>'false'
    OR (SELECT count(*) FROM public.portfolio_projects WHERE tenant_id=v_tenant AND portfolio_id=v_portfolio_id
      AND project_id=v_project_id)<>2
  THEN RAISE EXCEPTION 'Relinking did not preserve temporal association history'; END IF;
  v_mutation:=public.mutate_portfolio_project_association(v_tenant,v_portfolio_id,'associate',v_project_id,
    NULL,NULL,'Relink Project to Portfolio',v_association_key);
  IF v_mutation->>'idempotentReplay'<>'true' THEN RAISE EXCEPTION 'Link idempotent replay failed'; END IF;

  v_mutation := public.mutate_project(v_tenant,v_project_id,'update',
    '{"name":"Renamed Smoke Project","code":"PROJ-01","priority":"critical"}'::jsonb,
    2,'Smoke project edit',v_update_key);
  IF v_mutation->'project'->>'name' <> 'Renamed Smoke Project'
     OR v_mutation->'project'->>'version' <> '3' OR v_mutation->>'idempotentReplay' <> 'false' THEN
    RAISE EXCEPTION 'Versioned Project update failed';
  END IF;
  v_mutation := public.mutate_project(v_tenant,v_project_id,'update',
    '{"name":"Renamed Smoke Project","code":"PROJ-01","priority":"critical"}'::jsonb,
    2,'Smoke project edit',v_update_key);
  IF v_mutation->>'idempotentReplay' <> 'true' OR
     (SELECT count(*) FROM public.audit_events a WHERE a.tenant_id=v_tenant AND a.source='project-mutation'
       AND a.idempotency_key='update:'||v_update_key::text)<>1 THEN
    RAISE EXCEPTION 'Project update replay was not idempotent';
  END IF;
  BEGIN
    PERFORM public.mutate_project(v_tenant,v_project_id,'update','{"priority":"low"}'::jsonb,
      1,'Stale Project edit',gen_random_uuid());
    RAISE EXCEPTION 'Stale Project version unexpectedly succeeded';
  EXCEPTION WHEN SQLSTATE '40001' THEN NULL;
  END;
  v_mutation:=public.mutate_project(v_tenant,v_project_id,'archive','{}'::jsonb,3,
    'Smoke project archive',v_archive_project_key);
  IF v_mutation->'project'->>'archived_at' IS NULL OR v_mutation->'project'->>'version'<>'4' THEN
    RAISE EXCEPTION 'Project archive failed';
  END IF;

  v_mutation:=public.mutate_portfolio(v_tenant,v_portfolio_id,'archive','{}'::jsonb,1,
    'Smoke portfolio archive',v_archive_portfolio_key);
  IF v_mutation->'portfolio'->>'status'<>'archived' OR v_mutation->'portfolio'->>'version'<>'2' THEN
    RAISE EXCEPTION 'Portfolio archive after Project archive failed';
  END IF;
  IF (public.list_tenant_portfolios(v_tenant)->'portfolios') <> '[]'::jsonb THEN
    RAISE EXCEPTION 'Archived Portfolio remained visible in active list';
  END IF;

  BEGIN
    PERFORM public.create_portfolio_project(
      v_tenant, v_other_portfolio, 'Cross tenant Project', NULL, NULL, 'medium', NULL,
      NULL, NULL, 'Must reject a forged parent', gen_random_uuid()
    );
    RAISE EXCEPTION 'Cross-Tenant parent unexpectedly succeeded';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
END;
$smoke$;
ROLLBACK;

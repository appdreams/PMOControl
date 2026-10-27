-- Smoke test for Tenant, Project and deny-bounded invitation scopes.
-- Run against a disposable/DEV database with a trusted connection; always rolls back.
BEGIN;

DO $smoke$
DECLARE
  v_actor_id UUID := gen_random_uuid();
  v_tenant_user_id UUID := gen_random_uuid();
  v_project_user_id UUID := gen_random_uuid();
  v_portfolio_user_id UUID := gen_random_uuid();
  v_tenant_id UUID := gen_random_uuid();
  v_other_tenant_id UUID := gen_random_uuid();
  v_portfolio_id UUID := gen_random_uuid();
  v_project_id UUID := gen_random_uuid();
  v_other_project_id UUID := gen_random_uuid();
  v_tenant_admin_role_id UUID := gen_random_uuid();
  v_project_role_id UUID := gen_random_uuid();
  v_portfolio_role_id UUID := gen_random_uuid();
  v_issuer_role_id UUID := gen_random_uuid();
  v_tenant_hash BYTEA := decode(repeat('a', 64), 'hex');
  v_project_hash BYTEA := decode(repeat('b', 64), 'hex');
  v_portfolio_hash BYTEA := decode(repeat('c', 64), 'hex');
  v_result JSONB;
BEGIN
  INSERT INTO auth.users (
    id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
    created_at, updated_at, raw_app_meta_data, raw_user_meta_data
  ) VALUES
    (v_actor_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
     v_actor_id::text || '@scope-invite-smoke.invalid', '', now(), now(), now(),
     '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb),
    (v_tenant_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
     v_tenant_user_id::text || '@scope-invite-smoke.invalid', '', now(), now(), now(),
     '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb),
    (v_project_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
     v_project_user_id::text || '@scope-invite-smoke.invalid', '', now(), now(), now(),
     '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb),
    (v_portfolio_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
     v_portfolio_user_id::text || '@scope-invite-smoke.invalid', '', now(), now(), now(),
     '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb);

  INSERT INTO public.tenants (id, slug, display_name, created_by)
  VALUES
    (v_tenant_id, 'scope-invite-' || left(v_tenant_id::text, 8), 'Scope invite smoke', v_actor_id),
    (v_other_tenant_id, 'scope-invite-x-' || left(v_other_tenant_id::text, 8), 'Other scope smoke', v_actor_id);
  INSERT INTO public.memberships (tenant_id, user_id, status)
  VALUES (v_tenant_id, v_actor_id, 'active');

  INSERT INTO public.portfolios (id, tenant_id, name, category, owner_id, created_by, updated_by)
  VALUES (v_portfolio_id, v_tenant_id, 'Smoke scoped portfolio', 'internal', v_actor_id, v_actor_id, v_actor_id);
  INSERT INTO public.projects (id, tenant_id, name, created_by, updated_by)
  VALUES
    (v_project_id, v_tenant_id, 'Smoke scoped project', v_actor_id, v_actor_id),
    (v_other_project_id, v_other_tenant_id, 'Smoke other project', v_actor_id, v_actor_id);

  INSERT INTO public.roles (id, tenant_id, key, name, scope_type, is_system, status)
  VALUES
    (v_tenant_admin_role_id, v_tenant_id, 'tenant_admin', 'Tenant Admin', 'tenant', true, 'active'),
    (v_project_role_id, v_tenant_id, 'project_manager', 'Project Manager', 'tenant', true, 'active'),
    (v_portfolio_role_id, v_tenant_id, 'portfolio_viewer', 'Portfolio Viewer', 'tenant', true, 'active'),
    (v_issuer_role_id, v_tenant_id, 'scope_invite_issuer', 'Scope invite issuer', 'tenant', true, 'active');
  INSERT INTO public.role_permissions (role_id, permission_key)
  VALUES
    (v_tenant_admin_role_id, 'membership.invite'),
    (v_project_role_id, 'project.view'),
    (v_project_role_id, 'project.edit'),
    (v_project_role_id, 'portfolio.view'),
    (v_portfolio_role_id, 'portfolio.view'),
    (v_issuer_role_id, 'membership.invite'),
    (v_issuer_role_id, 'project.view'),
    (v_issuer_role_id, 'project.edit'),
    (v_issuer_role_id, 'portfolio.view');
  INSERT INTO public.access_grants (
    tenant_id, subject_id, role_id, role_scope_type, role_tenant_id,
    scope_type, scope_id, effect, granted_by, reason
  ) VALUES
    (v_tenant_id, v_actor_id, v_issuer_role_id, 'tenant', v_tenant_id, 'tenant', v_tenant_id::text,
     'allow', v_actor_id, 'smoke invite permission'),
    (v_tenant_id, v_actor_id, v_issuer_role_id, 'tenant', v_tenant_id, 'project', v_project_id::text,
     'allow', v_actor_id, 'smoke project delegation'),
    (v_tenant_id, v_actor_id, v_issuer_role_id, 'tenant', v_tenant_id, 'portfolio', v_portfolio_id::text,
     'allow', v_actor_id, 'smoke portfolio delegation');

  PERFORM set_config('request.jwt.claim.sub', v_actor_id::text, true);
  v_result := public.list_delegable_invitation_scopes(v_tenant_id);
  IF NOT EXISTS (
    SELECT 1 FROM pg_catalog.jsonb_array_elements(v_result->'scopes') AS s
    WHERE s->>'scopeType' = 'tenant' AND s->>'scopeId' = v_tenant_id::text
      AND s->'roleKeys' ? 'tenant_admin'
  ) OR NOT EXISTS (
    SELECT 1 FROM pg_catalog.jsonb_array_elements(v_result->'scopes') AS s
    WHERE s->>'scopeType' = 'project' AND s->>'scopeId' = v_project_id::text
      AND s->'roleKeys' ? 'project_manager'
  ) OR NOT EXISTS (
    SELECT 1 FROM pg_catalog.jsonb_array_elements(v_result->'scopes') AS s
    WHERE s->>'scopeType' = 'portfolio' AND s->>'scopeId' = v_portfolio_id::text
      AND s->'roleKeys' ? 'portfolio_viewer'
  ) THEN
    RAISE EXCEPTION 'Delegable scope picker omitted an expected exact-scope option';
  END IF;

  PERFORM set_config('request.jwt.claim.sub', v_actor_id::text, true);
  v_result := public.create_tenant_member_invitation(
    v_tenant_id, v_tenant_user_id::text || '@scope-invite-smoke.invalid', 'tenant_admin',
    v_tenant_hash, 'Tenant compatibility smoke', 'tenant', v_tenant_id
  );
  IF v_result->>'scopeType' <> 'tenant' OR v_result->>'scopeId' <> v_tenant_id::text THEN
    RAISE EXCEPTION 'Tenant scope result mismatch';
  END IF;
  PERFORM set_config('request.jwt.claim.sub', v_tenant_user_id::text, true);
  v_result := public.accept_tenant_invitation(v_tenant_hash);
  IF v_result->>'scopeType' <> 'tenant' OR NOT EXISTS (
    SELECT 1 FROM public.access_grants AS g WHERE g.tenant_id = v_tenant_id
      AND g.subject_id = v_tenant_user_id AND g.role_id = v_tenant_admin_role_id
      AND g.scope_type = 'tenant' AND g.scope_id = v_tenant_id::text AND g.revoked_at IS NULL
  ) THEN RAISE EXCEPTION 'Tenant invitation acceptance failed'; END IF;

  PERFORM set_config('request.jwt.claim.sub', v_actor_id::text, true);
  v_result := public.create_tenant_member_invitation(
    v_tenant_id, v_project_user_id::text || '@scope-invite-smoke.invalid', 'project_manager',
    v_project_hash, 'Project scope smoke', 'project', v_project_id
  );
  IF v_result->>'scopeType' <> 'project' OR v_result->>'scopeId' <> v_project_id::text THEN
    RAISE EXCEPTION 'Project scope result mismatch';
  END IF;
  PERFORM set_config('request.jwt.claim.sub', v_project_user_id::text, true);
  v_result := public.accept_tenant_invitation(v_project_hash);
  IF v_result->>'scopeType' <> 'project' OR NOT EXISTS (
    SELECT 1 FROM public.access_grants AS g WHERE g.tenant_id = v_tenant_id
      AND g.subject_id = v_project_user_id AND g.role_id = v_project_role_id
      AND g.scope_type = 'project' AND g.scope_id = v_project_id::text AND g.revoked_at IS NULL
  ) THEN RAISE EXCEPTION 'Project invitation acceptance failed'; END IF;

  PERFORM set_config('request.jwt.claim.sub', v_actor_id::text, true);
  v_result := public.create_tenant_member_invitation(
    v_tenant_id, v_portfolio_user_id::text || '@scope-invite-smoke.invalid', 'portfolio_viewer',
    v_portfolio_hash, 'Portfolio scope smoke', 'portfolio', v_portfolio_id
  );
  IF v_result->>'scopeType' <> 'portfolio' OR v_result->>'scopeId' <> v_portfolio_id::text THEN
    RAISE EXCEPTION 'Portfolio scope result mismatch';
  END IF;
  PERFORM set_config('request.jwt.claim.sub', v_portfolio_user_id::text, true);
  v_result := public.accept_tenant_invitation(v_portfolio_hash);
  IF v_result->>'scopeType' <> 'portfolio' OR NOT EXISTS (
    SELECT 1 FROM public.access_grants AS g WHERE g.tenant_id = v_tenant_id
      AND g.subject_id = v_portfolio_user_id AND g.role_id = v_portfolio_role_id
      AND g.scope_type = 'portfolio' AND g.scope_id = v_portfolio_id::text AND g.revoked_at IS NULL
  ) THEN RAISE EXCEPTION 'Portfolio invitation acceptance failed'; END IF;

  PERFORM set_config('request.jwt.claim.sub', v_actor_id::text, true);
  BEGIN
    PERFORM public.create_tenant_member_invitation(
      v_tenant_id, 'cross-tenant@scope-invite-smoke.invalid', 'project_manager',
      decode(repeat('d', 64), 'hex'), 'Cross Tenant scope must deny', 'project', v_other_project_id
    );
    RAISE EXCEPTION 'Cross-Tenant resource scope unexpectedly succeeded';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;

  INSERT INTO public.access_grants (
    tenant_id, subject_id, role_id, role_scope_type, role_tenant_id,
    scope_type, scope_id, effect, granted_by, reason
  ) VALUES (v_tenant_id, v_actor_id, v_issuer_role_id, 'tenant', v_tenant_id,
    'project', v_project_id::text, 'deny', v_actor_id, 'smoke denial');
  BEGIN
    PERFORM public.create_tenant_member_invitation(
      v_tenant_id, 'denied@scope-invite-smoke.invalid', 'project_manager',
      decode(repeat('e', 64), 'hex'), 'Explicit deny must block delegation', 'project', v_project_id
    );
    RAISE EXCEPTION 'Project delegation ignored an explicit deny';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;
END;
$smoke$;

ROLLBACK;

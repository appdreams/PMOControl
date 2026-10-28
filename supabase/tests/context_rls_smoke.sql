-- Transactional smoke check for the reviewed DEV membership-context policies.
-- Run with a trusted database connection using psql; this never commits fixtures.
\set ON_ERROR_STOP on

BEGIN;

SELECT gen_random_uuid() AS actor_a \gset
SELECT gen_random_uuid() AS actor_b \gset
SELECT gen_random_uuid() AS tenant_a \gset
SELECT gen_random_uuid() AS tenant_b \gset

INSERT INTO auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data
)
VALUES
  (:'actor_a', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
   :'actor_a' || '@rls-smoke.invalid', '', now(), now(), now(),
   '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb),
  (:'actor_b', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
   :'actor_b' || '@rls-smoke.invalid', '', now(), now(), now(),
   '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb);

INSERT INTO public.tenants (id, slug, display_name, created_by)
VALUES
  (:'tenant_a', 'rls-smoke-' || left(:'tenant_a', 8), 'RLS smoke tenant A', :'actor_a'),
  (:'tenant_b', 'rls-smoke-' || left(:'tenant_b', 8), 'RLS smoke tenant B', :'actor_b');

INSERT INTO public.memberships (tenant_id, user_id, status, revoked_at)
VALUES
  (:'tenant_a', :'actor_a', 'active', NULL),
  (:'tenant_b', :'actor_b', 'active', NULL),
  (:'tenant_b', :'actor_a', 'revoked', now());

SELECT CASE
  WHEN has_table_privilege('authenticated', 'public.memberships', 'SELECT')
   AND has_table_privilege('authenticated', 'public.tenants', 'SELECT')
   AND NOT has_table_privilege('authenticated', 'public.memberships', 'INSERT')
   AND NOT has_table_privilege('authenticated', 'public.memberships', 'UPDATE')
   AND NOT has_table_privilege('authenticated', 'public.memberships', 'DELETE')
   AND NOT has_table_privilege('authenticated', 'public.tenants', 'INSERT')
   AND NOT has_table_privilege('authenticated', 'public.tenants', 'UPDATE')
   AND NOT has_table_privilege('authenticated', 'public.tenants', 'DELETE')
   AND NOT has_table_privilege('authenticated', 'public.audit_events', 'SELECT')
   AND NOT has_table_privilege('authenticated', 'public.audit_events', 'INSERT')
   AND NOT has_table_privilege('authenticated', 'public.audit_events', 'UPDATE')
   AND NOT has_table_privilege('authenticated', 'public.audit_events', 'DELETE')
   AND (SELECT relrowsecurity FROM pg_catalog.pg_class WHERE oid = 'public.audit_events'::regclass)
  THEN 1 ELSE 0 END AS grants_ok \gset
\if :grants_ok
\else
  \echo 'Unexpected table privileges or audit immutability boundary for authenticated.'
  \quit 1
\endif

SET LOCAL ROLE authenticated;

-- Missing actor context must reveal neither memberships nor tenants.
SELECT set_config('request.jwt.claim.sub', '', true);
SELECT CASE
  WHEN (SELECT count(*) FROM public.memberships) = 0
   AND (SELECT count(*) FROM public.tenants) = 0
  THEN 1 ELSE 0 END AS missing_context_ok \gset
\if :missing_context_ok
\else
  \echo 'Rows are visible without an authenticated actor context.'
  \quit 1
\endif

-- Actor A sees one active membership and tenant A, never B or revoked membership.
SELECT set_config('request.jwt.claim.sub', :'actor_a', true);
SELECT CASE
  WHEN (SELECT count(*) FROM public.memberships) = 1
   AND (SELECT count(*) FROM public.memberships WHERE tenant_id = :'tenant_a') = 1
   AND (SELECT count(*) FROM public.memberships WHERE tenant_id = :'tenant_b') = 0
   AND (SELECT count(*) FROM public.tenants) = 1
   AND (SELECT count(*) FROM public.tenants WHERE id = :'tenant_a') = 1
   AND (SELECT count(*) FROM public.tenants WHERE id = :'tenant_b') = 0
  THEN 1 ELSE 0 END AS actor_a_isolated \gset
\if :actor_a_isolated
\else
  \echo 'Actor A can see another tenant or a non-active membership.'
  \quit 1
\endif

-- Actor B sees only tenant B and its own active membership.
SELECT set_config('request.jwt.claim.sub', :'actor_b', true);
SELECT CASE
  WHEN (SELECT count(*) FROM public.memberships) = 1
   AND (SELECT count(*) FROM public.memberships WHERE user_id = :'actor_b') = 1
   AND (SELECT count(*) FROM public.tenants) = 1
   AND (SELECT count(*) FROM public.tenants WHERE id = :'tenant_b') = 1
   AND (SELECT count(*) FROM public.tenants WHERE id = :'tenant_a') = 0
  THEN 1 ELSE 0 END AS actor_b_isolated \gset
\if :actor_b_isolated
\else
  \echo 'Actor B can see another tenant or another actor membership.'
  \quit 1
\endif

ROLLBACK;

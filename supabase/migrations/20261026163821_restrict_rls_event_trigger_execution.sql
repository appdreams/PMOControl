-- Keep the existing RLS-enforcement event trigger, but remove direct API
-- execution of its SECURITY DEFINER function. Fresh projects without this
-- manually provisioned helper safely no-op here.
DO $migration$
BEGIN
  IF to_regprocedure('public.rls_auto_enable()') IS NOT NULL THEN
    EXECUTE 'REVOKE EXECUTE ON FUNCTION public.rls_auto_enable() FROM PUBLIC, anon, authenticated';
  END IF;
END
$migration$;

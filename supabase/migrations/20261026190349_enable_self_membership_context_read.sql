-- F1-05: allow an authenticated user to resolve only their active tenant context.
-- No write privileges or policies are granted by this migration.

GRANT SELECT ON TABLE public.memberships, public.tenants TO authenticated;

CREATE POLICY memberships_select_self_active
  ON public.memberships
  FOR SELECT
  TO authenticated
  USING (
    user_id = (SELECT auth.uid())
    AND status = 'active'
  );

CREATE POLICY tenants_select_active_membership
  ON public.tenants
  FOR SELECT
  TO authenticated
  USING (
    status = 'active'
    AND EXISTS (
      SELECT 1
      FROM public.memberships AS membership
      WHERE membership.tenant_id = tenants.id
        AND membership.user_id = (SELECT auth.uid())
        AND membership.status = 'active'
    )
  );

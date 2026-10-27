-- F1-03: support FK maintenance and lookup paths identified by Supabase advisors.
CREATE INDEX access_grants_subject_id_idx ON public.access_grants (subject_id);
CREATE INDEX access_grants_granted_by_idx ON public.access_grants (granted_by);
CREATE INDEX access_grants_revoked_by_idx ON public.access_grants (revoked_by);
CREATE INDEX access_grants_role_scope_fk_idx ON public.access_grants (role_id, role_scope_type);
CREATE INDEX access_grants_role_tenant_fk_idx ON public.access_grants (role_id, role_tenant_id);
CREATE INDEX tenant_invitations_accepted_by_idx ON public.tenant_invitations (accepted_by);
CREATE INDEX tenant_invitations_created_by_idx ON public.tenant_invitations (created_by);
CREATE INDEX tenants_created_by_idx ON public.tenants (created_by);

-- F2-03/F2-04: index every new foreign-key lookup, including audit actors.
CREATE INDEX portfolios_created_by_idx ON public.portfolios (created_by);
CREATE INDEX portfolios_updated_by_idx ON public.portfolios (updated_by);
CREATE INDEX projects_created_by_idx ON public.projects (created_by);
CREATE INDEX projects_updated_by_idx ON public.projects (updated_by);
CREATE INDEX portfolio_projects_tenant_portfolio_fk_idx
  ON public.portfolio_projects (tenant_id, portfolio_id);
CREATE INDEX portfolio_projects_linked_by_idx ON public.portfolio_projects (linked_by);
CREATE INDEX portfolio_projects_removed_by_idx ON public.portfolio_projects (removed_by)
  WHERE removed_by IS NOT NULL;

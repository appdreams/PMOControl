-- Keep cleanup, contact lookup and audit-reference checks bounded as exports grow.
CREATE INDEX tenant_exports_requested_by_idx
  ON public.tenant_exports (requested_by);
CREATE INDEX tenant_exports_contact_same_tenant_idx
  ON public.tenant_exports (tenant_id, contact_user_id);
CREATE INDEX tenant_export_disputes_filed_by_idx
  ON public.tenant_export_disputes (filed_by);
CREATE INDEX tenant_export_disputes_resolved_by_idx
  ON public.tenant_export_disputes (resolved_by)
  WHERE resolved_by IS NOT NULL;
CREATE INDEX tenant_export_holds_applied_by_idx
  ON public.tenant_export_holds (applied_by);
CREATE INDEX tenant_export_holds_released_by_idx
  ON public.tenant_export_holds (released_by)
  WHERE released_by IS NOT NULL;

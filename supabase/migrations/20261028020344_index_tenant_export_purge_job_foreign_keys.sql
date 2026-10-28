-- F1-11: cover both foreign keys on the private resumable purge job.
CREATE INDEX tenant_export_purge_job_export_fk_idx
  ON private.tenant_export_purge_jobs (tenant_id, tenant_export_id);
CREATE INDEX tenant_export_purge_job_requested_by_idx
  ON private.tenant_export_purge_jobs (requested_by);

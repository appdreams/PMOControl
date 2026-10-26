# RLS Testing

**Status:** Draft — policy fixtures and runtime execution required

## Matriz mínima

- same tenant + authorized → allow;
- same tenant + wrong scope → deny;
- different tenant → deny;
- missing/revoked membership → deny;
- forged resource ID → deny;
- unauthorized sensitive field/resource → deny;
- application roles cannot mutate append-only/system-owned records.

## Coverage register for canonical inventory

Table-by-table coverage reconciled to 62 named canonical tables in `docs/06-data/tables.md`. Rebuildable read models are excluded. Each canonical table appears exactly once.

| Canonical table | Context / special invariant |
|---|---|
| `tenants` | Tenant and authorized actor scope; enforce ownership, least privilege, and same-tenant relationships. |
| `tenant_invitations` | Tenant and authorized actor scope; enforce ownership, least privilege, and same-tenant relationships. |
| `tenant_exports` | Tenant and authorized actor scope; enforce ownership, least privilege, and same-tenant relationships. |
| `tenant_export_disputes` | Platform lifecycle command; tenant contact can dispute only authorized export scope; preserve audit and pause purge only for disputed scope. |
| `tenant_quotas` | Tenant and authorized actor scope; enforce ownership, least privilege, and same-tenant relationships. |
| `user_profiles` | Actor/tenant membership and delegated scope; enforce least privilege and prevent cross-tenant reads/writes. |
| `memberships` | Actor/tenant membership and delegated scope; enforce least privilege and prevent cross-tenant reads/writes. |
| `roles` | Actor/tenant membership and delegated scope; enforce least privilege and prevent cross-tenant reads/writes. |
| `permissions` | Actor/tenant membership and delegated scope; enforce least privilege and prevent cross-tenant reads/writes. |
| `role_permissions` | Actor/tenant membership and delegated scope; enforce least privilege and prevent cross-tenant reads/writes. |
| `access_grants` | Actor/tenant membership and delegated scope; enforce least privilege and prevent cross-tenant reads/writes. |
| `portfolios` | Tenant and explicit portfolio scope; enforce same-tenant project association. |
| `portfolio_projects` | Tenant and explicit portfolio scope; enforce same-tenant project association. |
| `projects` | Project scope; enforce composite same-tenant relations and field-specific grants. |
| `project_assignments` | Project scope; enforce composite same-tenant relations and field-specific grants. |
| `project_baselines` | Project scope; enforce composite same-tenant relations and field-specific grants. |
| `project_forecasts` | Project scope; enforce composite same-tenant relations and field-specific grants. |
| `milestones` | Project scope; parent/child tenant integrity; state transitions require domain grants. |
| `deliverables` | Project scope; parent/child tenant integrity; state transitions require domain grants. |
| `dependencies` | Project scope and command grants; preserve append-only history where applicable. |
| `risks` | Project scope and command grants; preserve append-only history where applicable. |
| `risk_assessments` | Project scope and command grants; preserve append-only history where applicable. |
| `risk_responses` | Project scope and command grants; preserve append-only history where applicable. |
| `issues` | Project scope and command grants; preserve append-only history where applicable. |
| `actions` | Project scope and command grants; preserve append-only history where applicable. |
| `decisions` | Project scope and command grants; preserve append-only history where applicable. |
| `decision_comments` | Decision project scope; append-only comments; authorize comment and read separately. |
| `status_updates` | Project scope; publication records are immutable and created only by governed atomic commands. |
| `status_update_sections` | Project scope; publication records are immutable and created only by governed atomic commands. |
| `status_publications` | Project scope; publication records are immutable and created only by governed atomic commands. |
| `rag_rule_versions` | Tenant/project scope; rule/evaluation history is append-only; override requires grant and reason. |
| `rag_evaluations` | Tenant/project scope; rule/evaluation history is append-only; override requires grant and reason. |
| `rag_overrides` | Tenant/project scope; rule/evaluation history is append-only; override requires grant and reason. |
| `snapshots` | Project scope; published snapshot is immutable to application roles. |
| `project_financials` | Separate financial.view/edit/export grants; project access alone grants no financial fields. |
| `resources` | Tenant/resource/project scope; prevent cross-tenant identities and unauthorized allocation. |
| `allocations` | Tenant/resource/project scope; prevent cross-tenant identities and unauthorized allocation. |
| `documents` | Tenant/project and classification scope; private objects; signed access rechecks grant. |
| `document_versions` | Tenant/project and classification scope; private objects; signed access rechecks grant. |
| `evidence_links` | Tenant/project and classification scope; private objects; signed access rechecks grant. |
| `report_definitions` | Owner/tenant/scope checks; persisted filters and artifact access recheck policy/expiry. |
| `report_runs` | Owner/tenant/scope checks; persisted filters and artifact access recheck policy/expiry. |
| `ai_requests` | Actor and source scope; grounding cannot exceed requester policy; proposals require human command. |
| `ai_responses` | Actor and source scope; grounding cannot exceed requester policy; proposals require human command. |
| `ai_action_proposals` | Actor and source scope; grounding cannot exceed requester policy; proposals require human command. |
| `ai_provider_configs` | Tenant Admin/delegated `ai.config.manage` only; encrypted-secret reference only, no plaintext or cross-tenant resolution. |
| `ai_usage_records` | Tenant-scoped append-only ledger; cost detail requires `ai.cost.view`; export requires `ai.cost.export`; service writer only. |
| `notifications` | Recipient-only inbox/preferences; minimized payload; scoped worker identity and idempotency. |
| `notification_preferences` | Owner-only preference access; tenant-specific preferences require active membership; never expose other users’ settings. |
| `notification_deliveries` | Recipient-only inbox/preferences; minimized payload; scoped worker identity and idempotency. |
| `audit_events` | Scoped audit.view/export; append-only; application roles cannot update/delete. |
| `import_jobs` | Actor/tenant/scope and field policy; project dataset jobs bind to one same-Tenant active Project; replace requires elevated permission and fresh target revalidation. |
| `import_staging_rows` | Actor/tenant/project scope and field policy; staged project rows isolated until validated apply; workbook cannot set Tenant/internal IDs. |
| `export_jobs` | Actor/tenant/scope and field policy; private artifacts expire. |
| `tenant_settings` | Tenant Admin or delegated configuration grant; secrets redacted/reference-only. |
| `taxonomies` | Tenant Admin or delegated configuration grant; secrets redacted/reference-only. |
| `integration_connections` | Tenant integration grant; secrets server-only; webhook idempotency and no cross-tenant command. |
| `external_mappings` | Tenant integration or project-import grant by provider namespace; import external keys are Project-scoped, append-only mappings; secrets server-only; no cross-tenant reference. |
| `webhook_receipts` | Tenant integration grant; secrets server-only; webhook idempotency and no cross-tenant command. |
| `project_purge_jobs` | Root purge command only; service-mediated least privilege, idempotent phase transitions, no tenant content access. |
| `project_tombstones` | Minimal historical identity only; retained-reference access and no operational tenant access. |
| `outbox_events` | Platform lifecycle or service identity; enforce tenant boundary and audited privileged operations. |

## Execution evidence

**Not executed in this workspace:** it contains `/docs` only; no application source, database migrations, physical schema or test runner is present. This register defines the release gate and does not represent a passing RLS test.

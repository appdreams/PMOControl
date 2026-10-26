# Canonical Tables

**Status:** Draft — 62 named canonical tables; module/migration reconciliation pending

This document is the canonical MVP table inventory. Exact SQL types may
be refined by migrations without changing domain semantics.

  ----------------------------------------------------------------------------
  Area                    Table                       Purpose
  ----------------------- --------------------------- ------------------------
  Tenant                  `tenants`                   Tenant lifecycle/config
                                                      identity
Tenant                  `tenant_invitations`        Single-use 7-day membership invites
Tenant                  `tenant_exports`            Export-first termination artifacts/status
Tenant                  `tenant_export_disputes`    Scoped, auditable completeness disputes before purge
Tenant                  `tenant_quotas`             Optional plan-scoped limits
Access                  `user_profiles`             Non-credential profile metadata

  Access                  `memberships`               User membership in
                                                      tenant

  Access                  `roles`                     Role definitions

  Access                  `permissions`               Permission catalog

  Access                  `role_permissions`          Role-permission mapping

  Access                  `access_grants`             Role/scope grants

  Portfolio               `portfolios`                Portfolio governance

  Portfolio               `portfolio_projects`        Portfolio-project
                                                      association

  Project                 `projects`                  Core project record

  Project                 `project_assignments`       Project
                                                      responsibility/access
                                                      context

  Project                 `project_baselines`         Approved baseline
                                                      versions

  Project                 `project_forecasts`         Forecast history/current
                                                      forecast

  Execution               `milestones`                Governed milestones

  Execution               `deliverables`              Deliverables and
                                                      acceptance state

  Governance              `dependencies`              Project/item
                                                      dependencies

  Governance              `risks`                     Future uncertain events

  Governance              `risk_assessments`          Probability/impact
                                                      history

  Governance              `risk_responses`            Mitigation/response
                                                      plans

  Governance              `issues`                    Current
                                                      problems/blockers

  Governance              `actions`                   Executable commitments

  Governance              `decisions`                 Governed decisions
Governance              `decision_comments`         Append-only comments on governed decisions

  Status                  `status_updates`            Status preparation cycle

  Status                  `status_update_sections`    Structured status
                                                      content

  Status                  `status_publications`       Publication metadata

  RAG                     `rag_rule_versions`         Immutable threshold/rule
                                                      versions by tenant/type

  RAG                     `rag_evaluations`           Calculated health
                                                      results

  RAG                     `rag_overrides`             Authorized effective RAG
                                                      override history

  History                 `snapshots`                 Immutable published
                                                      project state

  Financial               `project_financials`        Budget/actual/forecast

  Resources               `resources`                 Governed resource
                                                      directory

  Resources               `allocations`               Capacity allocation

  Knowledge               `documents`                 Document metadata

  Knowledge               `document_versions`         Version metadata

  Knowledge               `evidence_links`            Evidence relationships

  Reports                 `report_definitions`        Saved report
                                                      configurations

  Reports                 `report_runs`               Generated report
                                                      execution

  AI                      `ai_requests`               Authorized AI requests

  AI                      `ai_responses`              AI response
                                                      metadata/output

  AI                      `ai_action_proposals`       Human-confirmed action
  AI                      `ai_provider_configs`      Tenant-owned BYOK provider/model configuration
  AI                      `ai_usage_records`         Append-only AI request usage and cost ledger
                                                      proposals

  Notify                  `notifications`             User notifications

  Notify                  `notification_preferences`  Recipient-owned channel/event preferences

  Notify                  `notification_deliveries`   Channel attempts

  Audit                   `audit_events`              Immutable sensitive
                                                      event trail

  Import                  `import_jobs`               Import lifecycle

  Import                  `import_staging_rows`       Staged rows

  Export                  `export_jobs`               Export lifecycle
Projection              Materialized/read models    Rebuildable caches only; not canonical sources

  Settings                `tenant_settings`           Tenant configuration

  Settings                `taxonomies`                Configurable controlled
                                                      vocabularies

  Integration             `integration_connections`   Provider connections

  Integration             `external_mappings`         Internal/external IDs

  Integration             `webhook_receipts`          Webhook
                                                      idempotency/security
                                                      metadata

  Platform                `project_purge_jobs`        Audited, resumable project purge lifecycle
  Platform                `project_tombstones`       Minimal retained identity for historical references
  Platform                `outbox_events`             Optional reliable
                                                      post-commit bridge if
                                                      adopted
  ----------------------------------------------------------------------------

`outbox_events` is not mandatory for initial MVP; introduce only if the
atomicity gap between DB commit and async dispatch becomes material.

The inventory contains 62 named canonical tables. Rebuildable projections/read models are not canonical tables and are excluded from this count. Physical migrations must reconcile this inventory before implementation approval.

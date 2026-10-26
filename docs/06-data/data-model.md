# Canonical Data Model

**Status:** Draft — reconcile against revised module Specs before migration

## Aggregate areas

### Identity & Access

Tenant, UserProfile, Membership, TenantInvitation, TenantExport, TenantExportDispute, TenantQuota, Role, Permission, AccessGrant, ScopeAssignment.

### Portfolio & Project

Portfolio, Project, ProjectAssignment, ProjectBaseline, ProjectForecast.

### Execution

Milestone, Deliverable, Dependency.

### Governance

Risk, RiskAssessment, RiskResponse, Issue, Action, Decision, DecisionComment.

### Status & History

StatusUpdate, StatusSection, Publication, RagEvaluation, RagOverride,
Snapshot.

### Control

ProjectFinancial, Resource, Allocation.

### Knowledge

Document, DocumentVersion, EvidenceLink.

### Reporting & Intelligence

ReportDefinition, ReportRun, AIRequest, AIResponse, AIActionProposal, TenantAIProviderConfig, AIUsageRecord.

### Platform

Notification, NotificationPreference, AuditEvent, ImportJob, ExportJob, TenantSetting,
IntegrationConnection.

## Common record fields

Tenant-owned entities should normally include:

-   `id uuid`
-   `tenant_id uuid`
-   `created_at timestamptz`
-   `created_by uuid`
-   `updated_at timestamptz`
-   `updated_by uuid`
-   `archived_at timestamptz nullable`
-   `archived_by uuid nullable`
-   `version bigint` where optimistic concurrency is useful

Business identifiers may exist in addition to UUIDs, but never replace
tenant-scoped authorization.

## Temporal truth

The model separates:

-   **Baseline** --- approved reference commitment.
-   **Forecast** --- current expected outcome.
-   **Actual** --- observed outcome.
-   **Current State** --- mutable operational state.
-   **Published State** --- immutable historical representation.

## Multi-tenancy

Shared PostgreSQL/shared schema is the MVP model. Tenant ownership is
explicit. Cross-tenant relationships are prohibited unless a
platform-level entity is intentionally global.

## Deletion

Governed business records should prefer archive/soft-delete when
traceability is required. Immutable snapshots and audit events are not
ordinarily deletable by tenant users.


## Product decisions incorporated

Tenant creation/suspension/termination is platform-operated; memberships may be multiple per user; invitation expires after 7 days. Tenant termination requires export before a 90-day purge window; legal hold/obligation may suspend purge. Export disputes use a dedicated tenant-owned lifecycle table. Tenant admin transfer is a command/audit workflow recorded by membership/grant changes, not an independent source table. Retention defaults are in `retention-archival.md` and require legal/contract validation.

## Read models

Project Control Center, My Day, project/portfolio dashboards and Time Machine projections are rebuildable, tenant-scoped read models. They are not canonical tables/source-of-truth. Projected fields retain source IDs/versions and `as_of`/refresh time.

## Platform project purge records

`project_purge_jobs` stores the authorized request, idempotency key, preview version, phase, counts, and resumable job outcome. `project_tombstones` retains only the minimum Project identity needed by historical references after eligible operational records are purged. Both records are platform-service controlled, deny ordinary Tenant CRUD, and must not contain Project business content or secrets. Their RLS/service access is covered in `docs/11-testing/rls-testing.md`.

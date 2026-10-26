# Relationships

**Status:** Approved

## Core hierarchy

``` text
Tenant
├── Membership
├── TenantExport
│   └── TenantExportDispute
├── Portfolio
│   └── PortfolioProject ── Project
├── Project
│   ├── ProjectAssignment
│   ├── ProjectBaseline
│   ├── ProjectForecast
│   ├── Milestone
│   ├── Deliverable
│   ├── Dependency
│   ├── Risk
│   ├── Issue
│   ├── Action
│   ├── Decision
│   │   └── DecisionComment (append-only)
│   ├── StatusUpdate
│   ├── Snapshot
│   ├── ProjectFinancial
│   ├── Allocation
│   └── Document/Evidence
├── Notification / NotificationPreference (actor-owned; optional Tenant scope)
├── AIProviderConfig (BYOK + low/medium/high model mapping)
├── AIRequest ── AIUsageRecord (append-only, metered per attempt)
└── Settings / Integrations / Audit
```

## Governance traceability

Actions may originate from Risk, Issue, Decision, Meeting/Status or
another governed source. Evidence may relate to Deliverable, Action,
Decision, Status publication or other authorized resources.

## Risk → Issue

A realized risk may create or relate to an Issue. The Risk record
remains historically meaningful and is not converted destructively into
the Issue.

## Status → Snapshot

``` text
StatusUpdate
  → validation
  → RAG evaluation
  → StatusPublication
  → Snapshot
```

One publication creates one immutable snapshot for the project/status
cycle.

## Dependencies

Dependencies use explicit source/target endpoints. Cross-project
dependencies are allowed only within the same tenant unless a future
explicitly governed cross-tenant capability is introduced.

## Referential rule

A child tenant-owned record must never reference a parent owned by
another tenant.

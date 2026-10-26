# Index Strategy

**Status:** Approved

## Principles

Indexes follow real query patterns, tenant isolation and
exception-driven PMO workflows. Avoid speculative indexing.

## Baseline indexes

Most tenant-owned tables should consider:

``` text
(tenant_id, id)
(tenant_id, created_at)
(tenant_id, updated_at)
```

Project-scoped entities commonly need:

``` text
(tenant_id, project_id)
(tenant_id, project_id, status)
(tenant_id, project_id, due_date)
```

## Exception queries

Candidate indexes:

-   actions: tenant/project/status/due_date
-   risks: tenant/project/status/level (current assessment projection)
-   issues: tenant/project/status/priority
-   milestones: tenant/project/forecast_date/status
-   decisions: tenant/project/status/decision_due_at
-   status_updates: tenant/project/reporting_period
-   snapshots: tenant/project/published_at
-   notifications: tenant/user/read_at/created_at

## Search

Use PostgreSQL full-text/trigram capabilities where justified before
adding Elasticsearch.

## JSONB

GIN indexes are permitted only for proven JSONB query paths.

## Monitoring

Use query plans and production telemetry before adding complex indexes.
Every index has write/storage cost.

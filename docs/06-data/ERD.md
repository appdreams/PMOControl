# PMO Control --- Logical ERD

**Status:** Draft — reconcile with module Specs before migrations

``` mermaid
erDiagram
    TENANTS ||--o{ MEMBERSHIPS : has
    TENANTS ||--o{ PORTFOLIOS : owns
    TENANTS ||--o{ PROJECTS : owns

    PORTFOLIOS ||--o{ PORTFOLIO_PROJECTS : contains
    PROJECTS ||--o{ PORTFOLIO_PROJECTS : belongs

    PROJECTS ||--o{ PROJECT_ASSIGNMENTS : assigns
    PROJECTS ||--o{ PROJECT_BASELINES : versions
    PROJECTS ||--o{ PROJECT_FORECASTS : forecasts
    PROJECTS ||--o{ MILESTONES : has
    PROJECTS ||--o{ DELIVERABLES : has
    PROJECTS ||--o{ RISKS : has
    PROJECTS ||--o{ ISSUES : has
    PROJECTS ||--o{ ACTIONS : has
    PROJECTS ||--o{ DECISIONS : has
    PROJECTS ||--o{ DEPENDENCIES : has
    PROJECTS ||--o{ STATUS_UPDATES : reports
    PROJECTS ||--o{ SNAPSHOTS : history
    PROJECTS ||--o{ PROJECT_FINANCIALS : controls
    PROJECTS ||--o{ ALLOCATIONS : consumes
    PROJECTS ||--o{ DOCUMENTS : documents

    RISKS ||--o{ RISK_ASSESSMENTS : assessed
    RISKS ||--o{ RISK_RESPONSES : mitigated

    STATUS_UPDATES ||--o{ STATUS_SECTIONS : contains
    STATUS_UPDATES ||--o| STATUS_PUBLICATIONS : publishes
    STATUS_PUBLICATIONS ||--|| SNAPSHOTS : creates

    DOCUMENTS ||--o{ DOCUMENT_VERSIONS : versions
    DOCUMENTS ||--o{ EVIDENCE_LINKS : evidences

    TENANTS ||--o{ AUDIT_EVENTS : audits
    TENANTS ||--o{ INTEGRATION_CONNECTIONS : connects
    TENANTS ||--o{ AI_REQUESTS : requests
```

## Notes

The diagram is logical and intentionally omits some join/reference
tables for readability. Detailed constraints remain governed by
`tables.md`, `relationships.md`, `constraints.md` and the Specs.

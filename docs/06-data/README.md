# PMO Control --- Data

**Status:** Draft — module schema reconciliation in progress\
**Official path:** `/docs/06-data/README.md`

## Purpose

This folder translates the PMO Control domain, Specs and architecture
decisions into the canonical data design for PostgreSQL/Supabase.

The database is the authoritative operational source for governed
business state. Dashboards, reports, My Day, Copilot context and
portfolio views are projections over authorized source data.

## Principles

1.  PostgreSQL is the operational source of truth.
2.  Every tenant-owned business record has explicit tenant ownership.
3.  Tenant isolation is mandatory and enforced server-side, with RLS as
    defense in depth.
4.  Baseline, Forecast and Actual are distinct concepts.
5.  Current operational state and Published historical state are
    distinct.
6.  Published snapshots are immutable.
7.  Risk is not Issue; Deliverable is not Acceptance; Action retains its
    source.
8.  Sensitive data is deny-by-default.
9.  Audit records are append-oriented.
10. AI never becomes a parallel source of truth.

## Folder map

``` text
06-data/
├── README.md
├── data-model.md
├── schemas.md
├── tables.md
├── relationships.md
├── constraints.md
├── indexes.md
├── rls-data-policies.md
├── status-snapshot-model.md
├── audit-data-model.md
├── ai-data-model.md
├── integration-data-model.md
├── retention-archival.md
├── migrations.md
├── seed-reference-data.md
├── data-dictionary.md
└── ERD.md
```

## Source precedence

`04-specs` defines functional behavior and domain rules.\
`02-architecture` and `03-adrs` define architectural constraints.\
`06-data` defines the canonical persistence design.\
Implementation migrations must conform to all three.

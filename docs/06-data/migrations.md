# Database Migrations

**Status:** Approved

## Source control

All schema changes are versioned in Git and applied through controlled
migration workflows.

## Strategy

Prefer:

`Expand → Deploy → Backfill/Migrate → Verify → Contract`

## Rules

-   no manual production schema drift;
-   migration is reviewable;
-   destructive changes require explicit plan;
-   data backfills are idempotent/restartable where possible;
-   tenant isolation is tested after security-sensitive migrations;
-   RLS/policies are versioned with schema;
-   rollback strategy is documented for risky changes;
-   production migrations avoid long blocking operations.

## Naming

Use chronological migration identifiers supported by the selected
Supabase migration tooling.

## Seed vs migration

Reference catalog data may be seeded. Business tenant data is never
embedded in schema migrations.

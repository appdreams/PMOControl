# Supabase migrations

Place forward-only SQL migrations in this directory, named with an ordered timestamp and a concise purpose, for example `20261026090000_create_tenant_memberships.sql`.

Every table and policy must follow the owning Spec and the cross-tenant/RLS ADRs. Review the migration for same-Tenant composite foreign keys, deny-by-default behavior, indexes, rollback/forward-fix strategy and data retention before applying it. Do not add application tables until their schema has been reconciled to the approved domain contracts.

No schema migration is included in the bootstrap. Database credentials and the target Supabase project are not configured in this repository.

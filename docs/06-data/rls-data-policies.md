# RLS & Data Policies

**Status:** Draft — security review and Spec reconciliation required

## Purpose

RLS is defense in depth for tenant isolation and selected data policies.
It does not replace application authorization.

## Effective authorization

`Tenant + Role + Scope + Permission + Data Policy + Workflow Rule`

## Rules

1.  Default deny for tenant business tables.
2.  Tenant context must be resolved server-side.
3.  A valid UUID does not grant access.
4.  Platform Admin has no automatic tenant business-data access.
5.  Financial, resource and confidential document data require explicit
    permissions.
6.  Service-role usage is server-only and narrowly controlled.
7.  AI uses the same authorized context as the user.
8.  Export queries obey the same row/field restrictions.

## Trusted database context and policy shape

After validating the session and active membership, trusted server middleware sets transaction-local `app.actor_id` and `app.tenant_id`; values supplied by the browser or unverified JWT custom fields are never used as authority. Transaction pooling must use `SET LOCAL` and clear context at transaction end. Shared helper functions fail closed when either value is absent, tenant is suspended, or membership is inactive.

Every tenant-owned table has `USING (tenant_id = trusted_tenant_id() AND active_membership(trusted_actor_id(), trusted_tenant_id()))`; writes additionally require the server-authorized command permission and scope. Child relations use composite `(tenant_id, parent_id)` foreign keys so a valid UUID from another Tenant cannot be linked. Project-scoped rows validate Project ownership and active assignment/grant. Field-level restrictions (financial/confidential) remain in the authorized query layer and are not replaced by row RLS.

The app database role does not own protected tables and has no `BYPASSRLS`. Migrations use a separate controlled role. Service jobs use an explicit tenant-scoped job context, recorded actor/system identity and least privilege; no general cross-tenant worker query. Published `status_publications`, `snapshots`, and `audit_events` deny UPDATE/DELETE to the application role; retention purge uses a separate audited procedure honoring legal holds.

## RLS test matrix

For every protected table test:

-   same tenant + authorized scope → allowed;
-   same tenant + unauthorized scope → denied;
-   different tenant → denied;
-   missing membership → denied;
-   revoked membership → denied;
-   forged resource ID → denied;
-   service path without intended policy → denied.

Cross-tenant negative tests are a release gate.

Platform project purge uses a separately audited stored procedure/service role, never a broad application-role `BYPASSRLS` path. The privileged path receives one server-resolved project ID, checks the root entitlement and retention/hold set, deletes only allowlisted operational rows, preserves immutable/historical data and emits a minimized audit/outbox record. Per-phase tenant/project scoping and no-cascade checks are mandatory.

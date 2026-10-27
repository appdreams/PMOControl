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

The application uses Supabase SSR clients and the authenticated Data API (PostgREST). The verified JWT is sent with each database request; policies derive the actor only from `(select auth.uid())`. Do not use browser-selected Tenant IDs or custom JWT metadata as authority. A selected Tenant ID is only a query selector: each policy checks the target row's Tenant, active membership for `auth.uid()`, and active Tenant state in the same database request. Revalidate on every request so membership revocation or Tenant suspension takes effect without waiting for JWT refresh.

The server request-context resolver uses `getClaims()` to verify the actor and then reads only that actor's active membership rows joined to active Tenants. Its correlation ID is generated server-side per request; caller-supplied correlation headers are not identity or audit authority. F1-05 installs a self-membership read policy and matching active Tenant read policy; any database permission/RLS error remains `context_unavailable`, never an empty membership result. No context is cached across requests.

Do not use transaction-local `app.actor_id`/`app.tenant_id` settings on the PostgREST request path. The app cannot safely set one connection's state across independent HTTP requests, and a client-callable setter would let a caller forge it. If a future server-only direct-Postgres adapter is introduced, it must define a separate trusted transaction boundary, use `SET LOCAL`, and must not be mixed with the Data API contract.

Any helper that reads membership/Tenant state must avoid recursive RLS while returning no protected row data. If a narrowly scoped `SECURITY DEFINER` helper is required, keep it in a non-exposed schema, fix its `search_path`, derive identity with `auth.uid()` inside the function, grant execute only to intended roles, and test it against forged IDs and both Tenant fixtures. Prefer an invoker policy where possible. No generic context setter or service-role bypass is permitted.

Every tenant-owned table checks `tenant_id` against the row being accessed and an active membership belonging to `(select auth.uid())`; suspended/terminating Tenant state is checked too. Writes additionally require the server-authorized command permission and scope. Child relations use composite `(tenant_id, parent_id)` foreign keys so a valid UUID from another Tenant cannot be linked. Project-scoped rows validate Project ownership and active assignment/grant. Field-level restrictions (financial/confidential) remain in the authorized query layer and are not replaced by row RLS.

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

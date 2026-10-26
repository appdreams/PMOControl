# Screen — Tenant Access Management

**Status:** Draft — MVP behavior mapped to SPECS-002/003

## Purpose and users

Tenant Admin and delegated PMO Admin manage invitations, memberships and grants inside their authorized Tenant/scope. Platform Admin manages platform lifecycle but has no default business-data access.

## Actions and states

- Invite by verified email with role/scope bounded by issuer delegation; show seven-day expiry and single-use status.
- Resend, revoke or expire invitation; accept only after authenticated email matches the invitation.
- View/revoke membership; switch among the actor's active tenant memberships.
- Assign/revoke a role grant with scope, reason, issuer, effective time and optional expiry; deny grants above the issuer ceiling.
- Show loading, empty, pending, expired, revoked, forbidden, delegation-denied and conflict states.

## Behavioral trace

`SPEC-002 FR-002-03/04/06–09 + SPEC-003 FR-003-01–08 → membership.invite/revoke + scoped access-grant management → invitations/memberships/access-grants/session-tenants APIs → AC-002-03/06–09 + AC-003-02/05/06 → TC-002-03–14 + TC-003-02–06`.

## Security

Invitation tokens are single-use, stored hashed and never exposed after creation. Membership revocation takes effect on the next server authorization check. The UI cannot authorize by itself; every query and command is revalidated against active Tenant, membership, scope, delegation ceiling and field policy.

Behavioral contract trace: [SCREEN-TRACEABILITY.md](../../SCREEN-TRACEABILITY.md).

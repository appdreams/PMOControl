# SPEC-002 — Multi-Tenancy — User Flows

**Status:** Draft — platform/admin lifecycle

## Provision

Platform operator authenticates → requests tenant create with slug/name and initial administrator → server validates platform permission, unique slug and capacity → creates Tenant + first Membership atomically → audit `TenantCreated` → sends invitation. Client users cannot provision tenants.

## Invite and join

Tenant Admin/PMO Admin with membership-management grant chooses email/limited grants → invitation token hash created, expires in 7 days → recipient authenticates/verifies matching email → single-use acceptance creates membership → audit `MembershipGranted`. Revocation, mismatch, expiry or replay blocks acceptance.

## Multi-tenant selection

Login → server lists active memberships → user selects one → server resolves Tenant and scope → discard prior context/cache → open workspace. Every request checks status/membership.

## Suspend / terminate

Platform operator with platform permission and reason suspends or starts termination → suspend blocks writes/jobs/integrations. Termination blocks normal use → build encrypted export → deliver/validate export → only then start 90-day purge timer → legal hold/obligation suspends covered purge → purge DB/storage/projections and track completion; backups expire within 35 days.

# SPEC-002 — Multi-Tenancy — User Flows

**Status:** Draft — platform/admin lifecycle

## Provision

Platform operator authenticates → provisions Tenant → its creator with current platform grant enters the first administrator email and reason → server issues and audits a one-time, seven-day `tenant_admin` link → operator shares the link manually → invitee signs in with matching confirmed Auth email → server atomically consumes invite, activates membership, assigns role and audits `MembershipGranted`. The app does not send email. Client users cannot provision Tenants.

## Invite and join

Tenant Admin/PMO Admin with membership-management grant chooses email/limited grants → invitation token hash created, expires in 7 days → recipient authenticates/verifies matching email → single-use acceptance creates membership → audit `MembershipGranted`. Revocation, mismatch, expiry or replay blocks acceptance.

## Multi-tenant selection

Login → server lists active memberships → user selects one → server resolves Tenant and scope → discard prior context/cache → open workspace. Every request checks status/membership.

## Suspend / terminate

Platform operator with platform permission and reason suspends or starts termination → suspend blocks writes/jobs/integrations. Termination blocks normal use → build encrypted export → deliver/validate export → only then start 90-day purge timer → legal hold/obligation suspends covered purge → purge DB/storage/projections and track completion; backups expire within 35 days.

# SPEC-002 — Multi-Tenancy — Business Rules

**Status:** Draft — MVP decisions incorporated

- Only the platform team can create, suspend/reactivate or start termination of a Tenant; each operation requires an authorized individual, reason and audit event.
- Tenant status `active` permits business operations; `suspended` blocks writes/integrations/jobs; `termination_pending` blocks normal use and begins export workflow.
- Users may hold memberships in several Tenants and choose one after login; selected context never substitutes for rechecking active membership.
- Invitation is bound to intended email, Tenant and limited grants, expires after 7 days, is single-use and revocable.
- Cross-tenant relations, reads, exports, storage access, AI grounding and background jobs are denied.
- Termination is export-first. The 90-day purge window starts only after export is generated and made available; legal hold/retention obligation suspends purge for covered scope.
- No fixed tenant/user cap in MVP; explicit plan quotas are configured by platform and enforced consistently.
- User-level hard delete is prohibited for governed entities; retention/purge is controlled by platform workflow and audit.
- Primary administration transfer requires an authenticated request from a current Tenant Admin and confirmation by the new administrator. If no active administrator can act, Platform Support uses JIT access with a ticket, independent approval, minimal scope, expiry and audit; the platform never silently transfers customer ownership.
- The export contact has 30 calendar days after availability notification to file a reasoned completeness dispute. A valid dispute pauses purge only for the disputed data scope until a resolution is recorded. No dispute does not extend the default 90-day purge window.

# SPEC-002 — Multi-Tenancy — UI

**Status:** Draft — platform lifecycle and tenant selection

Platform operations are available only to platform-team operators and require confirmation/reason. Tenant creation asks for the organization name; the identifier is generated automatically, shown as a non-editable preview and never submitted as client-controlled authority. First-admin and member invitation links are shown once for manual sharing; replacing a pending link revokes it, links expire after seven days, and the app does not send email. The Tenant workspace displays members, invitation flows at Tenant/Portfolio/Project scopes, scoped role grants, export notices/downloads, and authorized dispute/hold/purge operations. The UI is a hint only; the server rechecks identity, delegation ceiling, exact scope and explicit deny. Tenant Admin has no platform lifecycle controls.

Tenant switcher lists active memberships returned by server; one membership can auto-route, multiple require user choice, none shows no-access guidance. Termination screen shows export requested/building/ready/delivered/validated, 90-day purge deadline, hold exceptions and completion. Never reveal other tenants or expose invitation/export tokens.

Include loading, empty, expired/revoked invite, slug conflict, forbidden, quota, export failed, hold and purge pending states.
Invitation acceptance requires authentication and explains that the confirmed account email must match the invite. Before acceptance, the screen does not reveal the invited email or Tenant. Invalid, expired, revoked, replayed and mismatched-email states use neutral guidance.

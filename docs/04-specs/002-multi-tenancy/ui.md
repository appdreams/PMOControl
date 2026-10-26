# SPEC-002 — Multi-Tenancy — UI

**Status:** Draft — platform lifecycle and tenant selection

Platform operations screen is available only to platform-team operators and exposes create, suspend/reactivate, begin termination, quota administration and support status with confirmation/reason. Tenant Admin views membership/invitation administration only within own Tenant; no tenant create/suspend/terminate control.

Tenant switcher lists active memberships returned by server; one membership can auto-route, multiple require user choice, none shows no-access guidance. Termination screen shows export requested/building/ready/delivered/validated, 90-day purge deadline, hold exceptions and completion. Never reveal other tenants or expose invitation/export tokens.

Include loading, empty, expired/revoked invite, slug conflict, forbidden, quota, export failed, hold and purge pending states.

# SPEC-001 — Authentication — Permissions

**Status:** Draft — identity boundary

Authentication endpoints require no business permission for credential entry/recovery, but are rate-limited and abuse-protected. Workspace selection returns only memberships of the authenticated actor. Membership invitation/grant creation is governed by Specs 002/003, not by authentication role alone.

`actor_id` is derived from validated provider session. Client-supplied tenant, role, scope and permission are ignored. Authenticated users do not receive access until membership and resource permissions are separately checked. Platform Admin has no implicit business-data access.

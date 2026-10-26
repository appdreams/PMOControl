# SPEC-001 — Authentication — Business Rules

**Status:** Draft — MVP rules defined

- Supabase Auth owns credential/session verification; internal application modules own membership and authorization.
- MVP login is email/password only; MFA is later; Google/Microsoft SSO is excluded.
- Authentication success does not imply tenant or business-data access.
- Recovery does not enumerate account existence; token is single-use/expiring and never logged.
- Active membership is resolved after authentication and checked on every request; multiple memberships require explicit selection after login.
- Membership/invitation grants are created by Spec 002/003, not by an auth session.
- Revoked/suspended membership blocks the next request even if provider session remains active.
- No password/token/secret appears in logs, responses, analytics or AI context.

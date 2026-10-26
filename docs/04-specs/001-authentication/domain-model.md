# SPEC-001 — Authentication — Domain Model

**Status:** Draft — provider/auth boundary defined

## Owned concepts

- `AuthIdentity`: Supabase Auth identity (`user_id`, verified email, provider status); credential hash and tokens remain provider-managed.
- `UserProfile`: minimal non-credential display/preferences record linked to `user_id`.
- `Session`: provider-managed session; application derives `actor_id` and verifies token server-side.
- `TenantSelectionContext`: per-request derived context, not a trusted client entity; resolves an active Membership owned by Spec 002.

`Membership` and `Invitation` lifecycle belongs to Spec 002; role grants belong to Spec 003. Authentication validates identity but does not create business authorization.

## Invariants

Authenticated identity alone grants no tenant/project access; provider tokens are never copied into domain rows/logs; active membership is revalidated per request; logout/revocation denies subsequent requests. MVP supports email/password only; MFA/SSO are later/out of scope.

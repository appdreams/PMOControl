# SPEC-001 — Authentication — Business Rules

**Status:** Draft — MVP rules defined

- Supabase Auth owns credential/session verification; internal application modules own membership and authorization.
- Every Auth identity has a non-empty display label in `user_profiles`. If provider metadata has no name, the email local part is only a temporary label; the user must supply their own display name in the workspace. Names are presentation data and never participate in authorization.
- Users can read and update only their own profile through authenticated RPCs; display-name updates require same-origin requests and do not accept a client-supplied actor ID.
- MVP login is email/password only; MFA is later; Google/Microsoft SSO is excluded.
- Authentication success does not imply tenant or business-data access.
- Recovery does not enumerate account existence; token is single-use/expiring and never logged.
- Active membership is resolved after authentication and checked on every request; multiple memberships require explicit selection after login.
- Membership/invitation grants are created by Spec 002/003, not by an auth session.
- Invite acceptance requires a provider-confirmed verified email matching the invitation; the raw invite token is single-use, seven-day, and never persisted or logged by the application.
- Revoked/suspended membership blocks the next request even if provider session remains active.
- No password/token/secret appears in logs, responses, analytics or AI context.
- MVP access tokens expire after 3,600 seconds; provider refresh-token rotation remains enabled. On the current Free development project, do not claim an absolute session timebox or inactivity timeout: these provider controls require a paid plan. Before production, either enable provider timebox/inactivity controls or implement and validate an application-enforced session-age policy.
- Refresh tokens are held in the SSR cookie store and rotated by Supabase Auth. Browser auth cookies are host-only, `Path=/`, `SameSite=Lax`, and `Secure` on HTTPS; do not add `HttpOnly` because the browser Supabase client must access the refresh token, and do not set a short cookie lifetime that conflicts with refresh rotation.
- A valid JWT is not sufficient for an operation requiring immediate account/session revocation awareness. Revalidate current identity when that guarantee is required and always re-read Tenant, membership, grants, and resource policy on each business operation. Normal logout revokes only the current session (`scope: local`); global logout is an explicit account-wide action.
- Unsafe browser requests must pass same-origin Origin/Host validation. Auth refresh responses and personalized responses are not shared-cacheable (`Cache-Control: private, no-store`).
- Failed pre-authentication attempts are recorded only in provider auth logs; the application audit log does not persist unverified email, IP address, or a guessed actor. Application audit events begin only after a verified actor context exists.

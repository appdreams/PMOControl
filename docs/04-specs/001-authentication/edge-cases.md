# SPEC-001 — Authentication — Edge Cases

**Status:** Draft — authentication-specific

1. Correct password for disabled/locked account.
2. Unknown email in recovery; response remains neutral.
3. Recovery token expired, already used or replayed concurrently.
4. Provider unavailable during login/recovery callback.
5. Auth succeeds but user has zero active memberships.
6. Multi-tenant user selects a membership revoked between listing and selection.
7. Tenant suspended while an authenticated session remains open.
8. Client forges actor, role, scope or tenant in request.
9. Session revoked while request/job is queued; execution must revalidate.
10. Identity deletion requested while audit/business records remain under retention.

# SPEC-003 — RBAC & Contextual Authorization — Edge Cases

**Status:** Draft — authorization-specific

1. Conflicting allow and deny grants at parent/child scopes.
2. Expiry boundary occurs during long request or background job.
3. Grant issuer loses delegation between UI load and grant commit.
4. Membership or Tenant status changes while decision is cached.
5. Same user has multiple role grants with different scopes/data classes.
6. Resource moved to another Portfolio/Project after authorization check.
7. RLS and application policy disagree; fail closed and alert.
8. Missing policy catalog version during deployment/rollback.
9. Authorized dashboard aggregate contains unauthorized child data.
10. AI retrieval or export job starts authorized but permission is revoked before processing/download.
11. Tenant Admin assigns own role/permission or creates cross-tenant grant.
12. Support JIT access expires during session or approval is revoked.

# SPEC-001 — Authentication — User Flows

**Status:** Draft — MVP flows

## Sign in

```text
Enter email/password → Submit to Supabase Auth → Verify credential/session server-side
→ Resolve active memberships → 0: show no-access/request path; 1: continue; >1: choose tenant
→ Revalidate membership and create server-side request context → Open authorized workspace
```

## Password recovery

```text
Request recovery → always return neutral confirmation → provider sends single-use expiring link
→ validate token → set new password → revoke/rotate sessions per provider policy → audit security event
```

## Tenant switch

Choose only from server-returned active memberships → server revalidates selected membership/Tenant status → clear prior tenant cache/context → load new workspace. Any failure leaves prior operation denied; client-supplied tenant ID alone is insufficient.

## Invitation acceptance

Invitation is created/managed by Spec 002. Authentication verifies identity/email and hands verified identity to the invitation acceptance flow; it does not issue grants itself.

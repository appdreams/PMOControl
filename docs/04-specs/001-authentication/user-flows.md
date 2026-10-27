# SPEC-001 — Authentication — User Flows

**Status:** Draft — MVP flows

## Sign in

```text
Enter email/password → browser Supabase Auth (`signInWithPassword`) → SSR verifies session
→ Resolve active memberships → 0: show no-membership/platform provisioning path; 1: continue; >1: choose tenant
→ `POST /api/v1/session/tenant` revalidates selection → Open workspace
```

## Password recovery

```text
Request recovery through Supabase Auth → always show neutral confirmation → provider sends single-use expiring link
→ `/auth/callback` exchanges PKCE code into SSR session → set new password → end local session
```

## Tenant switch

Choose only from server-returned active memberships → server revalidates selected membership/Tenant status → clear prior tenant cache/context → load new workspace. Any failure leaves prior operation denied; client-supplied tenant ID alone is insufficient.

## Invitation acceptance

Invitation is created/managed by Spec 002. Authentication verifies identity/email and hands verified identity to the invitation acceptance flow; it does not issue grants itself.

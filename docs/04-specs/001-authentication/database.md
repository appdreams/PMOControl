# SPEC-001 — Authentication — Database

**Status:** Draft — provider schema/config review pending

Supabase Auth owns credentials, provider identities and session tokens; application MUST NOT duplicate password hashes, access/refresh/recovery tokens or invitation tokens in domain tables/logs.

Application table `user_profiles(user_id PK/FK auth.users, display_name, locale, created_at, updated_at)` stores non-secret profile fields only. Membership records are owned by Spec 002 and role grants by Spec 003; this Spec references them through verified `user_id` only. Provider-managed tables are not application migrations.

Session tenant context is derived per request, never trusted from persisted client choice. Profile anonymization follows retention policy without deleting governed records. Server lookup revalidates membership/Tenant status and RLS does not replace business permission enforcement.

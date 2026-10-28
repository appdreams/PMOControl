# SPEC-001 — Authentication — Database

**Status:** MVP provider boundary documented; credentials and sessions remain owned by Supabase Auth

Supabase Auth owns credentials, provider identities and session tokens; application MUST NOT duplicate password hashes, access/refresh/recovery tokens or invitation tokens in domain tables/logs.

Application table `user_profiles(user_id PK/FK auth.users, display_name NOT NULL, profile_complete, locale, created_at, updated_at)` stores non-secret profile fields only. Migration `20261027205134_require_user_display_names.sql` creates/backfills a profile for every Auth identity, prefers provider name metadata for display only, and uses the email local part as a temporary label when no name exists. `profile_complete=false` prompts the user to enter their own name; the self-service RPC updates only the authenticated actor's profile. Membership records are owned by Spec 002 and role grants by Spec 003; this Spec references them through verified `user_id` only. Provider-managed tables are not application migrations.

Session tenant context is derived per request, never trusted from persisted client choice. Profile anonymization follows retention policy without deleting governed records. Server lookup revalidates membership/Tenant status and RLS does not replace business permission enforcement.

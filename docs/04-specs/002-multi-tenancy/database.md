# SPEC-002 — Multi-Tenancy — Database

**Status:** Draft — logical lifecycle schema

Tables: `tenants(id,slug,display_name,status,version,created_at,created_by,suspended_at,termination_started_at)`; `memberships(id,tenant_id,user_id,status,created_at,activated_at,revoked_at,version)` unique `(tenant_id,user_id)`; `tenant_invitations(id,tenant_id,email_normalized,grant_payload,token_hash,expires_at,accepted_at,revoked_at,created_by)`; `tenant_exports(id,tenant_id,requested_by,status,artifact_key,checksum,ready_at,delivered_at,validated_at,purge_after,legal_hold_ref)`; `tenant_quotas(tenant_id,plan_key,limit_key,limit_value,effective_at,updated_by)`.

`tenant_export_disputes(id, tenant_id, tenant_export_id, filed_by, reason, disputed_scope JSONB, status, resolution, resolved_by, filed_at, resolved_at, version)` is the canonical dispute table. Composite FK `(tenant_id,tenant_export_id)` references `tenant_exports(tenant_id,id)`; `filed_by` must be an authorized export contact in the same Tenant; reason is non-empty; status is `open|resolved|rejected`; resolution requires actor, reason and timestamp. An open dispute pauses purge only for its recorded scope. Add indexes `(tenant_id,tenant_export_id,status)` and `(tenant_id,status,filed_at)`.

Tenant admin transfer has no independent mutable table: execute as an idempotent command with `expected_version`, change Membership/AccessGrant in the same Tenant and append the `TenantAdminTransferred` audit/event in the same transaction.

Use composite FKs/constraints to prevent cross-tenant relationships. Invite token stored hashed and expiry is seven days. Set `purge_after` only after export is available; legal hold blocks execution. Tenant state transitions are constrained/audited. RLS derives tenant from verified session; platform lifecycle operations use privileged service boundary with actor audit. Export artifacts private/encrypted and removed under retention policy.

# SPEC-002 — Multi-Tenancy — Permissions

**Status:** Draft — authority boundary defined

- `tenant.lifecycle.create|suspend|reactivate|terminate`: platform team only; individual actor, reason and audit required.
- `membership.invite|revoke`: Tenant Admin/PMO Admin within own active Tenant and delegation ceiling; grants cannot exceed issuer's authority.
- `tenant.settings.view|edit` and quota read are scoped separately; quotas are changed only by platform operator.
- User's tenant selection is not an authorization grant; server validates active membership each request.
- `tenant.export.request|download|validate` is restricted to platform termination workflow and authorized customer contact, with field/data policy.
- `tenant.admin.transfer.request|confirm` requires current administrator authority, verified new-admin identity, same-Tenant scope and audit; support recovery requires separate JIT approval.
- `tenant.export.dispute` is limited to the authorized export contact within 30 days; `tenant.export.dispute.resolve` is platform-only and audited.
- No role provides cross-tenant access. Platform Admin still uses JIT support procedure for business content.

# SPEC-003 — RBAC & Contextual Authorization — Business Rules

**Status:** Draft — rules defined; final default-grant review pending

- **BR-003-01:** default deny; explicit deny overrides matching allow.
- **BR-003-02:** access decision requires active identity, membership, Tenant, role grant, resource scope, permission, data policy and valid domain state.
- **BR-003-03:** scope inheritance is never assumed; a Tenant/Portfolio grant cascades only when permission catalog explicitly allows that inheritance.
- **BR-003-04:** grant issuer cannot delegate a role/permission/scope they do not hold or administer; Tenant Admin cannot grant platform privileges.
- **BR-003-05:** Platform Admin does not automatically view tenant business data. Support access uses approved JIT flow.
- **BR-003-06:** Project access does not imply financial, resource-personal, confidential-document or AI-secret access.
- **BR-003-07:** grants have effective/revoked/expiry lifecycle; revocation affects next request and queued job check.
- **BR-003-08:** UI hiding is not enforcement; every API, query, storage, export, AI retrieval and job enforces the same policy.
- **BR-003-09:** PM may publish status only with project-scoped `status.update.publish`; correction is a distinct `status.update.correct` permission.
- **BR-003-10:** decision/baseline/RAG/support permissions remain separate sensitive grants; read permission never implies approve, override, publish or export.

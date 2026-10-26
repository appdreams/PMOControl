# SPEC-003 — RBAC & Contextual Authorization — Requirements

**Status:** Draft — policy contract defined; matrix/business validation pending

## Evaluation

`ALLOW` only when actor has valid session, active membership in active Tenant, explicit grant for permission and resource scope, matching data policy, valid domain state and any applicable workflow rule. Any missing/ambiguous condition is `DENY`; explicit deny overrides allow. Resource ID, ownership, UI visibility or tenant ID supplied by client is never authority.

## Functional requirements

- **FR-003-01:** manage role grants at Tenant, Portfolio, Project, Resource or assigned-item scope, with issuer, effective time, expiry and revocation metadata.
- **FR-003-02:** only authorized administrators assign/revoke grants; they cannot grant permissions above their own delegation ceiling or outside their scope.
- **FR-003-03:** evaluate permission server-side on every query/command and background job using actor, active membership, Tenant, resource ancestry, role/grant, field policy and domain state.
- **FR-003-04:** permission inheritance is explicit per permission and scope edge; no implicit Tenant→Portfolio→Project cascade unless the grant declares it.
- **FR-003-05:** support least-privilege role templates for eight product roles; tenant custom roles/workflow builder are not MVP.
- **FR-003-06:** apply field-level data policies independently for financial, personal, confidential, restricted-document and AI-secret classifications.
- **FR-003-07:** revocation is effective on next authorization evaluation; invalidate security-sensitive cache entries and re-check queued jobs before execution.
- **FR-003-08:** log role/grant changes and denied sensitive operations with actor, target, scope, reason and timestamp; never log secrets.
- **FR-003-09:** AI retrieval, report/export, storage download, projection and API use the same authorization decision as direct access.

## MVP role defaults

- Platform Admin: platform tenant lifecycle/quotas only; no automatic business-data access.
- Tenant Admin: membership and tenant settings within Tenant; no automatic confidential/financial access.
- PMO Admin: governance administration in explicitly assigned Tenant/Portfolio scope; sensitive actions still need specific grants.
- PMO: operational governance within assigned Portfolio/Project scopes.
- Project Manager: assigned Project operations; default project-scope grant may include `status.update.publish`; correction requires explicit `status.update.correct`.
- Contributor: assigned actions/deliverables and allowed comments/evidence only.
- Executive: authorized portfolio/project read and decisions explicitly assigned to them.
- Viewer: authorized read-only fields; no mutation/export absent separate grant.

Exact grants are in `permissions.md`. These are defaults, not superuser roles.


## Acceptance/test traceability

- `FR-003-01` → `AC-003-05` → `TC-003-01/05` (gestão de grants com teto de delegação).
- `FR-003-02` → `AC-003-05` → `TC-003-05` (atribuição/revogação autorizada e sem autoelevação).
- `FR-003-03` → `AC-003-01/02` → `TC-003-02/06` (avaliação server-side e deny-by-default em requisições/jobs).
- `FR-003-03` → `AC-003-03` → `TC-003-03` (precedência de deny explícito).
- `FR-003-04` → `AC-003-04` → `TC-003-04` (herança explícita de escopo).
- `FR-003-05` → `AC-003-01` → `TC-003-01` (templates dos oito papéis MVP).
- `FR-003-07` → `AC-003-06` → `TC-003-06` (revogação, cache e revalidação de jobs).
- `FR-003-06` e `FR-003-09` → `AC-003-07` → `TC-003-07` (separação de dados sensíveis e mesmas decisões em projeções/IA/export).
- `FR-003-08` → `AC-003-03` → `TC-003-11` (auditoria de grants e negativas sensíveis sem registrar segredos).
- Autorização de publicação/correção e acesso de suporte → `AC-003-05/06` → `TC-003-09/10`.
- Aplicação consistente no banco → `AC-003-01/02` → `TC-003-08`; a execução contra schema físico segue como gate de implementação.

- **FR-003-10:** manter `platform.projects.purge` como entitlement explícito exclusivo de Platform Root Admin, distinto do preset Platform Admin; cada preview, confirmação, job status e fase de execução revalida o grant, e esse grant não autoriza leitura do conteúdo do Tenant.

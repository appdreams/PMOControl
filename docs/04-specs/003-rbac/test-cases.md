# SPEC-003 — RBAC & Contextual Authorization — Test Cases

**Status:** Draft — release-gate tests

- **TC-003-01:** Positive matrix for each role/scope/permission family, including explicitly granted Project Manager status.update.publish.
- **TC-003-02:** Missing session, membership, tenant, grant, scope, permission or data policy denies.
- **TC-003-03:** Explicit deny overrides allow at same and intersecting scope.
- **TC-003-04:** No implicit inheritance across Tenant→Portfolio→Project unless catalog marks it.
- **TC-003-05:** Attempted cross-tenant grant, out-of-ceiling grant and self-escalation are rejected.
- **TC-003-06:** Revocation/expiry invalidates caches and blocks in-flight/background work at execution boundary.
- **TC-003-07:** Project read without financial/document/resource permissions yields no sensitive fields in API, projection, report/export or AI context.
- **TC-003-08:** RLS positive and negative tests match application decisions for every tenant-owned table.
- **TC-003-09:** Project Manager without `status.update.publish` cannot publish; with explicit project grant can; cannot correct without separate `status.update.correct`.
- **TC-003-10:** Platform Admin cannot view business data by default; support JIT only works with ticket, independent approval, scope and expiry.
- **TC-003-11:** Decision/audit tests verify reason codes without leaking resource existence or secrets.

Release gate: any cross-tenant access, privilege escalation, field-policy bypass or stale grant acceptance blocks release.
- **TC-003-12:** somente Platform Root Admin com `platform.projects.purge` consulta metadados mínimos e executa o fluxo confirmado; Platform Admin comum e Tenant roles recebem deny sem enumeração.
- **TC-003-13:** tentativa de Tenant Admin/PMO Admin conceder ou delegar entitlement root é negada e auditada sem autoelevação.
- **TC-003-14:** allow ancestral só percorre arestas declaradas; deny ancestral/aplicável vence; siblings/descendentes não bloqueiam e ancestry malformada nega.

## Implementação parcial — 2026-10-26

Testes executáveis de domínio em `apps/web/tests/authorization.test.mjs` via `pnpm test` (32 passando em 2026-10-26). Cobrem escopo exato, contexto ausente/inválido, entradas runtime malformadas, negação explícita, revogação/expiração e separação de permissões. [Limites e pendências](../../07-security/identity-foundation-review.md). TC-003-01/05/07/08/10/11/12/13 não estão integralmente implementados; testes de domínio não substituem API/RLS.

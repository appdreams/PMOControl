# Release Quality Gates

**Status:** Approved

## Blockers

-   cross-tenant leakage;
-   broken authorization;
-   exposed secret;
-   inconsistent published status/snapshot;
-   destructive migration failure;
-   critical security vulnerability.

## Required

Tests, migrations, lint/type-check, critical E2E, RLS/authz suite e
security checks relevantes.

## AI

Use cases críticos exigem evaluation/regression apropriada.

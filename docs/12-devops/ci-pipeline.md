# Continuous Integration Pipeline

**Status:** Approved

## Pipeline base

Checkout → Install → Lint → Type Check → Unit/Domain Tests → DB/Security
Tests → Build → Artifact/Preview.

## Gates adicionais

-   dependency/security checks;
-   RLS/tenant isolation suite;
-   migration validation;
-   API contract tests;
-   AI regression quando mudança afetar use case crítico.

## Regra

Falha crítica bloqueia merge/deploy.

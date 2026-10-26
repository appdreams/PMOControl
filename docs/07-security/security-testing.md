# Security Testing

**Status:** Approved

## Obrigatórios

-   authorization tests;
-   cross-tenant isolation tests;
-   RLS tests;
-   IDOR/BOLA negative tests;
-   workflow/SoD tests;
-   sensitive-field tests;
-   export authorization tests;
-   upload validation tests;
-   webhook replay/signature tests;
-   AI authorization/grounding tests.

## Release gates

Falhas críticas em tenant isolation, authz, secrets ou publicação/audit
bloqueiam produção.

## Futuro

DAST, penetration testing e external security assessment conforme
maturidade/risco.

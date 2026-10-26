# Testing Strategy

**Status:** Approved

## Objetivos

-   prevenir regressões;
-   provar regras críticas;
-   garantir isolamento multi-tenant;
-   validar workflows;
-   garantir contratos;
-   testar falhas externas;
-   medir qualidade da IA;
-   manter feedback rápido no CI.

## Prioridade

Risco \> cobertura percentual isolada.

## Camadas

1.  Unit.
2.  Domain/business rules.
3.  Database/RLS.
4.  Integration.
5.  API/contract.
6.  Component/UI.
7.  E2E.
8.  Security.
9.  Performance/resilience.
10. AI evaluation.

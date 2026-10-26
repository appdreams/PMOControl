# Database Guide

**Status:** Approved

## Fonte

`/docs/06-data/`.

## Regras

-   UUID;
-   tenant_id explícito;
-   constraints;
-   RLS defense-in-depth;
-   migrations versionadas;
-   Baseline/Forecast/Actual separados;
-   snapshots imutáveis;
-   audit append-oriented.

## Mudança

Schema change exige migration e testes correspondentes.

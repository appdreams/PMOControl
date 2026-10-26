# Synchronization Strategy

**Status:** Approved

## Tipos

-   on-demand;
-   scheduled;
-   webhook-triggered;
-   incremental;
-   full reconciliation.

## Preferência

Incremental quando provider oferece cursor/timestamp confiável.

## Reconciliation

Jobs periódicos podem verificar divergências entre eventos recebidos e
estado externo.

## Regra

Sync aplica tenant context e source authority antes de qualquer
mutation.

# PMO Control --- Integrations

**Status:** Draft — module/API reconciliation required\
**Official path:** `/docs/10-integrations/README.md`

## Objetivo

Definir a estratégia, contratos, segurança e operação das integrações
externas do PMO Control.

## Princípios

-   PostgreSQL permanece source of truth do PMO Control.
-   Integrações usam adapters/Anti-Corruption Layer.
-   Provider SDK/types não atravessam o domínio.
-   Source authority é explícita por entidade/campo.
-   External IDs são separados dos IDs internos.
-   Sync é tenant-scoped, idempotente e observável.
-   Falha externa não pode corromper estado governado.
-   Credentials são isoladas por Tenant.

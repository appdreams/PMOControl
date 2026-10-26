# Rate Limits

**Status:** Approved

## Objetivo

Proteger disponibilidade, custo e abuso.

## Áreas

-   authentication;
-   password recovery;
-   AI/Copilot;
-   exports;
-   imports;
-   public API;
-   webhooks;
-   report generation.

## Dimensões

User, Tenant, IP, integration connection ou API credential conforme
contexto.

## Resposta

`429 Too Many Requests`, com retry guidance quando seguro.

## Regra

Limites não substituem quotas comerciais/tenant limits.

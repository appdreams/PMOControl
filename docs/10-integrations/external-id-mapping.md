# External ID Mapping

**Status:** Approved

## Regra

UUID interno permanece identidade canônica.

## Mapping

`tenant + connection + provider + resourceType + externalId → internalResourceId`

## Requisitos

-   unique por connection/resource;
-   idempotente;
-   auditável quando altera vínculo;
-   external IDs não são usados como autorização;
-   provider URLs/keys são metadados, não identidade interna.

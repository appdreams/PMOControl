# Integration Registry

**Status:** Approved

## Registro por Tenant

Cada conexão registra provider, tipo, status, scopes, credential
reference, configuration, source authority e health.

## Estados

Draft / Connected / Degraded / Disabled / Error / Revoked.

## Metadados

-   provider;
-   tenant;
-   createdBy;
-   auth type;
-   granted scopes;
-   last successful sync;
-   last failure;
-   next scheduled sync;
-   configuration version.

## Secrets

Nunca armazenados/retornados em claro no registry.

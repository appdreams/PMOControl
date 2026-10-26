# API Security

**Status:** Approved

## Pipeline

Authenticate → Resolve Tenant → Authorize → Validate → Execute → Audit.

## Controles

-   schema validation;
-   object-level authorization;
-   field-level policy;
-   rate limiting onde necessário;
-   payload/body limits;
-   safe errors;
-   pagination limits;
-   idempotency em operações aplicáveis;
-   anti-enumeration;
-   CORS restritivo conforme necessidade.

## IDOR/BOLA

Toda referência de objeto deve ser autorizada no contexto efetivo.
Conhecer UUID não concede acesso.

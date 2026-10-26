# Integration Architecture

**Status:** Approved

## Pipeline inbound

Provider → Adapter → Authentication/Validation → Tenant Resolution →
Mapping → Policy/Domain Validation → Command/Staging → Audit.

## Pipeline outbound

Domain Event/Command → Integration Application Service → Adapter →
Provider.

## Async

Inngest executa syncs, retries e processamento que não deve bloquear
requests.

## Boundaries

Adapters traduzem contratos externos para modelos internos estáveis.

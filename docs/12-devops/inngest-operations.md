# Inngest Operations

**Status:** Approved

## Casos

Notifications, reports, exports, integrations, retries e tarefas de
IA/processing assíncronas.

## Job requirements

Tenant context, correlation ID, idempotency, retry policy e safe
logging.

## Falhas

Jobs devem ser reexecutáveis quando possível.

## Regra

Inngest não vira source of truth; estado autoritativo permanece no
PostgreSQL.

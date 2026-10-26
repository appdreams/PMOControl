# Integration Security

**Status:** Approved

## Connections

Credenciais isoladas por tenant e provider.

## Webhooks

-   validar assinatura;
-   resolver conexão/tenant;
-   replay protection;
-   idempotency;
-   timestamp/tolerance quando suportado;
-   rejeitar payload inválido antes de mutação.

## Sync

Adapters isolam modelos externos. Conflitos não sobrescrevem estado
governado silenciosamente.

## Outbound

Aplicar egress mínimo, timeouts, retries/backoff e não enviar dados além
do necessário.

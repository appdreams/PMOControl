# Integration Webhooks

**Status:** Approved

## Pipeline

Receive → Verify Signature → Replay Check → Resolve Connection/Tenant →
Validate Schema → Idempotency Check → Queue/Process → Record Result.

## Segurança

-   HTTPS;
-   signature/secret;
-   timestamp tolerance quando disponível;
-   payload limits;
-   safe logging;
-   rate limits.

## Resposta

Ack rápido quando processamento for assíncrono.

## Replay

Evento duplicado retorna sucesso seguro sem reaplicar mutation.

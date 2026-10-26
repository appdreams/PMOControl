# Idempotency & Retries

**Status:** Approved

## Idempotency

Webhook/event IDs e operation keys impedem processamento duplicado.

## Retry

Exponential backoff com limites e classificação de erro.

## Não retentar

Authentication invalid, malformed payload e permanent permission failure
sem mudança de condição.

## Dead-letter

Falhas persistentes devem ficar visíveis para operação/reprocessamento
controlado.

## Regra

Retry nunca pode duplicar Action, Issue, Document ou outro recurso.

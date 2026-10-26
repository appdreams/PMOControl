# Idempotency & Concurrency

**Status:** Approved

## Idempotency

Obrigatória/recomendada em: - status publish; - webhook processing; -
imports; - exports; - integration sync; - async commands; - operações
financeiras sensíveis quando aplicável.

## Keys

Idempotency key é tenant/context scoped e possui retenção definida.

## Concurrency

Sensitive mutations podem usar `version`, `updatedAt` ou equivalent
optimistic concurrency token.

## Conflict

Retornar `409` quando estado mudou e operação não puder ser aplicada com
segurança.

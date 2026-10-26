# Resilience Testing

**Status:** Approved

## Falhas

Database transient error, Inngest retry, SMTP outage, AI provider
outage, integration timeout/rate limit.

## Verificar

Retry, idempotency, graceful degradation e ausência de corrupção.

## Core

Falha de IA/SMTP não deve indisponibilizar governança central.

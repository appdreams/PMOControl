# Health Checks

**Status:** Approved

## Liveness

Aplicação responde.

## Readiness

Dependências essenciais disponíveis para servir função central.

## Deep health

Checks administrativos podem validar DB/jobs/integrations sem expor
detalhes publicamente.

## Regra

AI/SMTP opcional indisponível não deve necessariamente marcar core
application como down.

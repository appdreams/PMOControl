# API Architecture

**Status:** Approved

## Boundaries

Browser → Next.js boundary → Application → Domain → Data/Infrastructure.

## Tipos

1.  Application APIs --- utilizadas pela UI.
2.  Integration APIs --- providers/webhooks.
3.  Public APIs --- exposição externa governada, quando habilitada.
4.  Async job interfaces --- eventos/jobs internos.

## Commands e Queries

Separação conceitual: - Query: leitura autorizada, sem mutação. -
Command: intenção de mudança, valida regras e workflow.

Não é necessário implementar infraestrutura CQRS formal no MVP.

## Regra

Endpoints finos; regras ficam nos serviços/application/domain
apropriados.

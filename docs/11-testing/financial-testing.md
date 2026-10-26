# Financial Testing

**Status:** Approved

## Cobrir

Budget, Actual, Forecast, currency/precision e permissões.

## Segurança

Usuário sem `financial.view` não recebe campo sensível via API, export,
report ou Copilot.

## Integridade

Nunca usar floating point inadequado para valores monetários.

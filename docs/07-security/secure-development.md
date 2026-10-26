# Secure Development Lifecycle

**Status:** Approved

## Pull Requests

Mudanças sensíveis exigem review apropriado.

## CI

Executar lint, type-check, testes, dependency checks e security tests
relevantes.

## Dependencies

Manter lockfiles, atualização controlada e análise de vulnerabilidades.

## Code

-   sem secrets;
-   sem autorização apenas no frontend;
-   validação em boundaries;
-   queries tenant-scoped;
-   safe error handling.

## Threat review

Novos módulos de alta sensibilidade, integrações, AI actions e mudanças
de tenancy exigem revisão de ameaça.

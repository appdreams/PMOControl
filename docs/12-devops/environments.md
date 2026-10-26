# Environments

**Status:** Approved

## Development

Execução local e recursos de desenvolvimento.

## Preview

Deploy por branch/PR quando aplicável, com dados/serviços isolados.

## Production

Ambiente oficial, com configuração e credenciais próprias.

## Regras

-   nunca compartilhar secrets entre ambientes sem necessidade
    explícita;
-   produção não usa dados seed/demo;
-   Preview não acessa banco Production;
-   integrações externas usam sandbox/test quando disponível;
-   AI BYOK de produção não é copiada automaticamente para ambientes
    inferiores.

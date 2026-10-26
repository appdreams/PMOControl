# Configuration Management

**Status:** Approved

## Categorias

-   application config;
-   environment config;
-   tenant settings;
-   feature flags;
-   provider configuration;
-   secrets.

## Regra

Configuração operacional não deve exigir alteração de código quando for
naturalmente variável por tenant/ambiente.

## Validação

Application startup deve falhar de forma clara para configuração
obrigatória ausente.

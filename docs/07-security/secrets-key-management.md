# Secrets & Key Management

**Status:** Approved

## Segredos

Incluem service keys, SMTP, integration credentials, webhook secrets e
AI BYOK.

## Regras

-   nunca versionar em Git;
-   nunca retornar em claro ao cliente;
-   criptografar/secret-manage em repouso;
-   mascarar na UI;
-   acesso least privilege;
-   rotação suportada;
-   separar ambientes;
-   não registrar em logs/audit/prompts.

## BYOK

Chaves de IA são isoladas por tenant. Provider adapters recebem a chave
apenas no boundary necessário à execução.

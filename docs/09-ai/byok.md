# BYOK --- Bring Your Own Key

**Status:** Approved

## Escopo

Configuração por Tenant.

## Requisitos

-   secrets criptografados/secret-managed;
-   nunca retornar chave em claro;
-   mascarar UI;
-   provider/model permitidos configuráveis;
-   rotação;
-   validação de credencial sem exposição;
-   audit de configuração sensível;
-   isolamento por tenant.
-   cada configuração ativa associa modelos separados para classes automáticas baixa/média/alta;
-   segredo nunca é incluído em payload de leitura, trace, prompt, analytics ou mensagem de erro;
-   validação retorna apenas status, capacidades/modelos autorizados e timestamp; rotação revoga referência anterior;

## Falha

Credencial inválida/desabilitada degrada funções de IA, mas não impede
operação central do PMO Control.

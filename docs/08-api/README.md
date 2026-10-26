# PMO Control --- API

**Status:** Draft — cross-spec contract reconciliation in progress\
**Official path:** `/docs/08-api/README.md`

## Objetivo

Definir os contratos, convenções, boundaries e requisitos transversais
das APIs do PMO Control.

O índice canônico de recursos, inputs, permissões e envelopes por módulo está em `module-schema-register.md`; os detalhes de domínio permanecem na Spec de cada módulo.

## Princípios

-   API não é uma segunda camada de regras de negócio.
-   Specs e Domain governam comportamento.
-   Toda operação resolve autenticação, Tenant, autorização e validação
    antes da execução.
-   IDs nunca concedem acesso.
-   Commands sensíveis são auditáveis.
-   APIs externas são versionadas.
-   Operações assíncronas possuem status rastreável.
-   Erros não expõem detalhes internos ou dados protegidos.

## Pipeline

`Authenticate → Resolve Tenant → Authorize → Validate → Execute → Audit → Respond`

## Escopo

APIs internas da aplicação, APIs públicas futuras, webhooks, integrações
e endpoints necessários ao frontend.

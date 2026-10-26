# Prompt Management

**Status:** Approved

## Prompts

Versionados e identificáveis por use case.

## Estrutura

System policy → task instructions → authorized context → untrusted
content boundaries → output schema.

## Requisitos

-   version ID;
-   use case;
-   expected schema;
-   provider/model compatibility;
-   evaluation set;
-   change history.

## Regra

Dados externos/documentos nunca são tratados como instruções
privilegiadas.

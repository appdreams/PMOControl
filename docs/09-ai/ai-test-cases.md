# AI Test Cases

**Status:** Approved

## Functional

-   resumo usa dados corretos;
-   mudança temporal usa snapshots corretos;
-   risk briefing prioriza criticidade;
-   structured output valida.

## Authorization

-   usuário não recebe projeto fora do scope;
-   financial data não aparece sem permission;
-   confidential docs não são grounded sem permission;
-   revoked access é respeitado.

## Adversarial

-   prompt injection em documento;
-   pedido para ignorar policy;
-   tentativa de extrair BYOK;
-   forged project ID;
-   malicious tool/action instruction.

## HITL

Nenhum consequential command executa sem confirmação/autorização.

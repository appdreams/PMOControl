# AI Security

**Status:** Approved

## Princípio

`AI Context ≤ Authorized User Context`

## Riscos

Prompt injection, data leakage, over-permission, hallucination, unsafe
tool/action execution e provider exposure.

## Controles

-   grounding apenas com dados autorizados;
-   separar instruções de conteúdo não confiável;
-   outputs estruturados validados;
-   Fact / Inference / Recommendation identificáveis;
-   RAG oficial é determinístico, não decidido pelo LLM;
-   ações consequenciais exigem confirmação humana;
-   autorização fresca antes do command;
-   secrets nunca entram no prompt;
-   logs minimizados.

## Agentes

Autonomia futura não elimina permission checks, workflow rules ou audit.

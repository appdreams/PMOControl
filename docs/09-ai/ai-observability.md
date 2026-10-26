# AI Observability

**Status:** Approved

## Medir

-   requests;
-   latency;
-   success/failure;
-   provider/model;
-   token usage;
-   estimated/actual cost quando disponível;
-   schema validation failures;
-   retries;
-   user feedback;
-   policy blocks;
-   grounded evidence coverage.

## Privacy

Logs não devem replicar conteúdo sensível desnecessariamente.

## Correlation

AI request deve possuir correlation ID para rastrear request → provider
→ response → optional action.

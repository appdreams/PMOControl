# Input & Output Security

**Status:** Approved

## Input

Toda entrada externa é não confiável: browser, arquivos, integrações,
webhooks e LLM output.

## Controles

-   schema/type validation;
-   length/range validation;
-   allowlists onde adequado;
-   parameterized queries/ORM seguro;
-   sanitização contextual;
-   upload validation.

## Output

-   encoding contextual;
-   evitar exposição de stack traces/secrets;
-   field-level filtering;
-   proteger dados Restricted/Confidential.

## CSV

Mitigar formula injection em exportações, especialmente valores
iniciados por `=`, `+`, `-` ou `@`.

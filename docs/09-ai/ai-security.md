# AI Security Controls

**Status:** Approved

## Ameaças

Prompt injection, data exfiltration, insecure tool use, excessive
agency, hallucination, cross-tenant leakage e secret exposure.

## Controles

-   server-side context;
-   deny-by-default tools;
-   explicit tool permissions;
-   output validation;
-   fresh authorization;
-   tenant isolation;
-   secret redaction;
-   egress minimization;
-   logging seguro;
-   adversarial tests.

## Principle

LLM output é untrusted input para o restante do sistema.

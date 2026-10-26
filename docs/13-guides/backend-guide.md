# Backend Guide

**Status:** Approved

## Pipeline

Authenticate → Resolve Tenant → Authorize → Validate → Execute Domain →
Persist → Audit → Respond.

## Regras

-   tenant context server-side;
-   domain rules centralizadas;
-   queries tenant-scoped;
-   commands consequenciais auditáveis;
-   idempotency/concurrency onde necessário;
-   external/LLM input não confiável.

## Proibição

Não espalhar lógica crítica apenas em route handlers.

# RAG API

**Status:** Draft — aligned with Spec 015 `rag-v1`; OpenAPI review pending

## Operations

-   evaluate current project health;
-   preview calculation;
-   retrieve rule explanation;
-   override effective RAG when authorized.
-   list evaluation history and revoke/expire an override.

## Override

Requires `projects.{projectId}.rag-evaluations.override`, justification (>=10 characters), calculated/effective values, actor, timestamp and optional expiry. Calculated value is never overwritten.

## Principle

Official RAG is deterministic. LLM may explain but does not calculate
authoritative health.

`evaluateRag` returns `calculated_rag`, `effective_rag`, `evaluation_status`, `as_of`, `rule_set_version`, normalized input hash, and per-indicator values. Missing required inputs return `incomplete`; they never default to Green. Full `rag-v1` thresholds are canonical in Spec 015.

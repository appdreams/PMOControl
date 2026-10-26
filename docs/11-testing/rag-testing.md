# RAG Engine Testing

**Status:** Draft — executable fixtures required for implementation

## Cobrir

Every `rag-v1` indicator at boundaries and just below/above thresholds; worst-case aggregation; date cut-off; version changes; zero/null denominators; missing inputs => `incomplete`; same input+rule version => identical output/hash.

## Override

Exige permission, justification, actor e audit.

## Invariante

Calculated RAG permanece preservado quando Effective RAG é sobrescrito; revocation/expiry restores current calculated result without rewriting history.

## IA

Explicação de IA não altera resultado determinístico.

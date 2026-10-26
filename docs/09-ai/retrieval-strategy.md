# Retrieval Strategy

**Status:** Approved

## MVP

Começar com retrieval relacional/estruturado e busca PostgreSQL.

## Documentos

Full-text/trigram primeiro quando suficiente.

## Semantic retrieval

Quando houver necessidade comprovada, usar pgvector no PostgreSQL antes
de adicionar vector database dedicado.

## Hybrid

Busca híbrida lexical + semântica pode ser introduzida para Project
Knowledge quando mensuravelmente superior.

## Regra

Retrieval sempre aplica tenant/scope/data policy antes de fornecer
contexto ao modelo.

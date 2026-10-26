# Structured Output

**Status:** Approved

## Objetivo

Reduzir ambiguidade e permitir validação runtime.

## Exemplos

ExecutiveSummary, RiskBriefing, StatusDraft, CommitteeBrief,
ActionProposal.

## Pipeline

LLM output → schema parse → validation → policy validation → application
rendering.

## Falha

Output inválido pode ser reparado/reexecutado dentro de limites; nunca
executar command baseado em payload não validado.

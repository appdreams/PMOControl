# Migration Guide

**Status:** Approved

## Processo

Criar migration → review → testar do zero/upgrade → aplicar lower env →
verificar → Production.

## Backfill

Idempotente/restartável.

## RLS

Policies são código versionado.

## Proibição

Alteração manual permanente em Production sem migration equivalente.

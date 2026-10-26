# Rollback Strategy

**Status:** Approved

## App

Vercel rollback/redeploy de versão conhecida quando compatível.

## Database

Preferir forward-compatible migrations; rollback destrutivo de DB é
último recurso.

## Feature

Feature flag pode desabilitar comportamento problemático quando
implementada.

## Regra

Nunca fazer rollback de código incompatível com schema já migrado sem
análise.

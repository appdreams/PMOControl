# Database Migration Operations

**Status:** Approved

## Processo

Author → Review → Validate → Apply in lower environment → Test →
Production → Verify.

## Estratégia

Expand/contract para mudanças incompatíveis.

## Segurança

RLS/policies são parte das migrations.

## Backfills

Idempotentes/restartáveis quando possível.

## Proibição

Schema change manual permanente em Production sem migration
correspondente.

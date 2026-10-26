# Continuous Delivery / Deployment

**Status:** Approved

## Preview

PR aprovado pode gerar deploy Preview.

## Production

Merge/release elegível → quality gates → migrations controladas → Vercel
deploy → smoke tests → monitor.

## Ordem

Mudanças incompatíveis seguem Expand → Deploy → Backfill/Migrate →
Verify → Contract.

## Regra

Deploy da aplicação e mudança de banco devem ser coordenados para
compatibilidade.

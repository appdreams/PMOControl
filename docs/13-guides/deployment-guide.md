# Deployment Guide

**Status:** Approved

## Fluxo

PR checks → merge/release → migration compatibility → deploy → smoke
tests → monitor.

## Mudanças DB

Expand → Deploy → Backfill/Migrate → Verify → Contract.

## Falha

Interromper rollout e escolher rollback ou forward-fix preservando
dados.

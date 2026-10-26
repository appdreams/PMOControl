# AI Fallbacks & Graceful Degradation

**Status:** Approved

## Falhas

Provider indisponível, timeout, invalid key, quota, malformed output ou
policy block.

## Comportamento

-   informar indisponibilidade sem quebrar fluxo central;
-   permitir retry quando apropriado;
-   fallback de provider/model somente se permitido pela política/BYOK;
-   nunca trocar provider violando configuração do tenant;
-   preservar dados já salvos.

## Core

Projects, governance, status e dashboards continuam funcionais sem IA.

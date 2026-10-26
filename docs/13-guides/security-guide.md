# Security Guide

**Status:** Approved

## Fórmula

`Tenant + Role + Scope + Permission + Data Policy + Workflow Rule`

## Developer checklist

Autenticar, resolver tenant, autorizar objeto, validar campos, aplicar
workflow, proteger output, auditar quando necessário.

## Nunca

Confiar em UUID, tenant enviado pelo browser, botão escondido ou service
role como bypass genérico.

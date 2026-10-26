# AI Cost Governance

**Status:** Approved

**MVP clarification:** each Tenant has a metered usage/cost view and own BYOK configuration; this is a required capability, not a future dashboard.

## Dimensões

Tenant, use case, provider, model e período.

## Controles

-   model routing;
-   token/context budgets;
-   limits/quotas;
-   caching apenas quando seguro;
-   context minimization;
-   timeout;
-   retry limits;
-   dashboard por Tenant com período, provider, modelo, classe e use case;
-   contabilização por request de tokens/unidades e custos reportados ou estimados;
-   exportação segregada por Tenant/permissão e classificação clara de estimativa.

## BYOK

Custos podem ser diretamente do tenant no provider, mas PMO Control
ainda deve medir uso suficiente para governança operacional.

Uso medido localmente não é necessariamente igual à cobrança do provider. Guardar currency, rate-card/version e measurement status (`provider_reported|rate_estimated|unavailable`); ausência de dados vira `unavailable`/null, nunca custo zero confirmado. Tela deve dizer “estimativa” e mostrar timestamp da tarifa, não fingir fatura final.

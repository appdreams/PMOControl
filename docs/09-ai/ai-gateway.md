# AI Gateway

**Status:** Approved

## Pipeline

`Authorize → Resolve Tenant BYOK → Resolve Context → Apply Policy → Deterministic Complexity Route → Ground → Build Prompt → Execute → Validate → Meter Usage/Cost → Classify → Return`

## Responsabilidades

-   provider abstraction;
-   tenant BYOK resolution;
-   model routing;
-   timeout/retry;
-   structured output validation;
-   usage/cost metadata;
-   deterministic complexity classification (`low|medium|high`) with version/reason code;
-   append-only per-request usage/cost ledger;
-   policy enforcement;
-   observability;
-   safe error normalization.

## Regra

Application/domain não conhece SDKs específicos de providers.

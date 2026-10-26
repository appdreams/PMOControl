# Data Constraints

**Status:** Approved

## Mandatory constraints

-   Primary keys are UUIDs.
-   Tenant-owned records require non-null `tenant_id`.
-   Foreign keys must preserve tenant consistency.
-   Unique business keys are normally tenant-scoped.
-   Percentages/probabilities remain in defined valid ranges.
-   Monetary amounts cannot use floating-point types.
-   Publication/snapshot immutability is enforced beyond UI.
-   Calculated and effective RAG are stored separately when override
    occurs.
-   Override requires reason, actor and timestamp.
-   Baseline versions are append/version oriented.
-   Published status cannot be silently mutated.
-   Decision state transitions are validated.
-   Completed Action may require evidence according to configured
    policy.
-   Delivered and Accepted are distinct states.

## Examples

``` text
UNIQUE (tenant_id, project_code)
UNIQUE (tenant_id, portfolio_code)
CHECK (progress_percent BETWEEN 0 AND 100)
CHECK (probability_score >= 1 AND probability_score <= 5)
CHECK (impact_score >= 1 AND impact_score <= 5)
CHECK (budget_amount >= 0)
```

## Cross-tenant protection

Application validation is mandatory. Where practical, composite
keys/constraints or trigger-based validation may reinforce same-tenant
relationships.

## Concurrency

Use transactional locking or optimistic version checks for sensitive
workflows such as publication, baseline changes and decisions.

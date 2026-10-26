# Data Dictionary

**Status:** Draft — reconcile with module Specs before migrations

## Common semantic fields

  -----------------------------------------------------------------------
  Field                               Meaning
  ----------------------------------- -----------------------------------
  `tenant_id`                         Security/data ownership boundary

  `project_id`                        Project context

  `status`                            Domain lifecycle state, not generic
                                      UI state

  `baseline_*`                        Approved reference commitment

  `forecast_*`                        Current expected outcome

  `actual_*`                          Observed outcome

  `calculated_rag`                    Deterministic engine result

  `effective_rag`                     Result after authorized override

  `published_at`                      Moment state became official
                                      historical truth

  `archived_at`                       Record removed from active
                                      operation without erasing history

  `created_by`                        Actor creating record

  `updated_by`                        Actor last changing mutable record
  -----------------------------------------------------------------------

## Classification

Each relevant entity must identify:

-   classification;
-   sensitive fields;
-   required permissions;
-   retention;
-   audit;
-   AI usage;
-   export rules.

## Monetary values

Use fixed precision numeric types plus explicit currency code.

## Time

Persist timestamps in UTC (`timestamptz`) and render in user/tenant
timezone.

## Enumerations

Prefer database constraints/reference catalogs for stable governed
values. Avoid uncontrolled free text for lifecycle states.

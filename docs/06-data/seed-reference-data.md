# Seed & Reference Data

**Status:** Approved

## Purpose

Seed only deterministic platform/reference data required to bootstrap
environments.

## Candidate reference data

-   permission catalog;
-   standard roles;
-   default RAG labels;
-   default severity/priority labels;
-   project/status lifecycle enums where implemented as tables;
-   supported notification channels;
-   supported AI provider metadata;
-   default report section types.

## Demo data

Demo/sample tenant data must be isolated from production and never used
as required reference data.

## Idempotency

Seed scripts must be safe to rerun.

## Tenant defaults

Tenant-specific defaults should be created through tenant provisioning,
not global seed assumptions. Provision these initial, tenant-owned taxonomies idempotently:

| Taxonomy | Initial codes | Notes |
|---|---|---|
| Milestone type | `project_start`, `phase_gate`, `major_deliverable`, `review`, `project_end`, `other` | Tenant may customize display labels; codes remain stable. |
| Milestone criticality | `low`, `medium`, `high`, `critical` | Tenant may customize display labels; codes remain stable. |
| Risk category | `scope`, `schedule`, `cost`, `quality`, `resource`, `supplier`, `technical`, `security`, `compliance`, `other` | Tenant may customize display labels and add explicitly configured categories. |
| Risk trend | `improving`, `stable`, `worsening` | Means decreasing risk, no material change, or increasing risk. |
| Action source type | `risk`, `issue`, `milestone`, `deliverable`, `decision`, `manual` | `manual` has no source reference; other codes require a valid source of that type in the same Tenant and Project. |

Provisioning must preserve stable codes and be safe to rerun; it must not overwrite tenant-customized labels or remove values already used by records.

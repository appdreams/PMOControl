# Portfolio API

**Status:** Approved

## Resources

`/api/v1/portfolios`

## Operations

List/create/read/update/archive authorized portfolios;
associate/disassociate projects; retrieve authorized portfolio
projection.

## Projection

Portfolio dashboard data is derived from source entities/snapshots and
is not independently editable.

## Security

Only projects visible to the caller may contribute detailed results.

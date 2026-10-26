# Reports & Export API

**Status:** Approved

## Reports

`/report-definitions` `/report-runs`

Long generation may return `202 Accepted` + job/run status.

## Export

Requires `report.export` where applicable.

## Security

Export obeys row/field authorization and protects against CSV formula
injection.

## Async

Client can poll authorized run status or receive notification when
complete.

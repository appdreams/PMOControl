# Documents & Evidence API

**Status:** Approved

## Resources

`/documents` `/documents/{id}/versions` `/evidence-links`

## Upload flow

Authorize → validate metadata → create controlled upload → store
privately → persist metadata → audit if sensitive.

## Download

Authorized server-side; signed/temporary access when applicable.

## Confidential

Requires explicit confidential-document permission.

## Evidence

Links maintain tenant/project/resource integrity.

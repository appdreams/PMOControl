# Status Update API

**Status:** Draft — workflow MVP and snapshot-v1 aligned; OpenAPI review pending

## Resource

`/api/v1/projects/{projectId}/status-updates`

## Lifecycle padrão MVP

`Draft → Validate → Published → Superseded (somente quando uma correção cria sucessora)`.

Project Manager com `status.update.publish` concedida no Project scope pode publicar diretamente. Não há etapa de aprovação obrigatória por uma segunda pessoa no fluxo padrão.

## Operations

- create/open draft;
- load current governed entities;
- save draft sections with optimistic concurrency;
- validate draft and return blocking errors/warnings;
- publish with `expected_version` and idempotency key;
- correct published status with `status.update.correct` + reason, creating a successor.

## Publish

`POST /api/v1/status-updates/{id}/publish`

Revalidate session, Tenant, Project scope, permission, version and domain rules. In one authoritative transaction persist published state, Publication, immutable Snapshot and audit/outbox. Failure before commit leaves no partial publication. Projections, notifications and integrations run after commit through idempotent jobs; their failure does not roll back publication.

## Correction

`POST /api/v1/status-updates/{id}/corrections`

Requires explicit permission and non-empty reason. Creates a new publication linked to the prior publication; never updates or deletes the prior snapshot.

## Idempotency and concurrency

Same idempotency key/request returns the original result. Same key with a different payload and stale `expected_version` return conflict. Publish and correction are safe to retry.

## Response

Return status/publication/snapshot identities, schema version, hash, `kpi-v1`/`rag-v1`, source versions, version, publication timestamp and post-commit job state. Monthly period, checklist and formulas are specified in Spec 014 `business-rules.md`.

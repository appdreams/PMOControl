# SPEC-028 — Import & Export — API

**Status:** Draft — logical operations and payload allowlists defined; OpenAPI materialization and implementation alignment pending

## Resource lógico

`/api/v1/data-jobs` — convenção base de `docs/08-api`. Scope: `Tenant + authorized entities/fields`.

## Operações e schemas

| Operação | Rota | Request allowlist | Resultado |
|---|---|---|---|
| List importable Projects | `GET /api/v1/projects?importable=true` | `q?,cursor?,limit?`; Tenant derived from active verified membership; requires `project.view` + `project.data.import` | Only active Projects in current Tenant and actor scope |
| Download project template | `GET /api/v1/projects/{projectId}/imports/templates/project-import-v1?variant=blank|example` | authorized selected Project; variant allowlist | `.xlsx` versioned workbook; blank copy includes selected Project identity guard; example contains synthetic data |
| Create project import | `POST /api/v1/data-jobs/imports` | `entityType=project_dataset,targetProjectId,sourceFileKey,templateVersion=project-import-v1`; file key issued by server | `202` job ID; selected Project scope revalidated |
| Create generic import | `POST /api/v1/data-jobs/imports` | `entityType,sourceFileKey,mappingVersion?`; uploaded file key issued by server | `202` job ID |
| Map | `PUT /api/v1/data-jobs/{id}/mapping` | `columns:{source,target}[]` constrained by entity schema | `200` versioned mapping |
| Validate | `POST /api/v1/data-jobs/{id}/validate` | `Idempotency-Key` | `200` counts/errors, `targetProjectHasData`, allowed modes; no source writes. Empty scope skips mode selection and queues initial apply after successful preview |
| Preview | `GET /api/v1/data-jobs/{id}/preview` | `cursor,limit` | Normalized rows/diff, validation messages, existing/incoming counts, no secret fields |
| Apply initial project load | `POST /api/v1/data-jobs/{id}/apply-initial` | `expectedVersion,expectedProjectVersion,expectedTargetScopeChecksum`, `Idempotency-Key`; no mode or typed prompt | `202` only when server confirms empty v1 scope and clean validation; final Project/Tenant/grant check, atomic apply |
| Confirm project mode | `POST /api/v1/data-jobs/{id}/confirm` | `mode=append|replace,expectedVersion,expectedProjectVersion,expectedTargetScopeChecksum,confirm=true,reason?,typedConfirmation?`, `Idempotency-Key`; replace requires `typedConfirmation=REINICIAR {project_code}` and `project.data.import.replace` | `202` atomic apply job; final Tenant, Project, version, reviewed impact checksum and grant recheck |
| Job status/result | `GET /api/v1/data-jobs/{id}` | none | State, progress, row counts, diagnostics and immutable audit reference |
| Create export | `POST /api/v1/data-jobs/exports` | `entityType,filters,fields,format`, `Idempotency-Key` | `202` authorized export job |
| Download export | `POST /api/v1/data-jobs/exports/{id}/download-url` | sem body | URL assinada curta, checksum/expiry; recheck current access |

Project workbook format is strict `.xlsx` `project-import-v1`; exact sheet contract is `project-import-template-v1.md`. Empty target v1 scope imports without append/restart prompt after clean validation/preview. Existing target data requires mode choice and explicit confirm; append is insert-only, replace requires elevated confirmation and archives only supported current data. Generic imports stay staged until confirm. Export format allowlist `csv|xlsx`; CSV formula injection escaped; exports reapply row/field policies at query and download.

## Contrato comum

JSON; IDs UUID; datas ISO-8601/UTC; paginação por cursor em listas grandes; filtros/sorts allowlisted; `expected_version` em update concorrente; idempotency key em comandos com retry. Cada operação revalida grants server-side.

## Erros

Logical request/response fields and domain constraints are listed above; a compilable OpenAPI contract and implementation alignment remain release gates.

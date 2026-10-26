# Project Import Workbook v1

**Status:** Draft — normative workbook contract for SPEC-028 project-data import
**Format:** `.xlsx` only; template version `project-import-v1`

## Purpose and target

The user selects an already registered Project from the active Tenant before downloading or uploading. The `Projeto` sheet is an identity guard: its `project_code` must match the selected Project. The target ID comes from the server-authorized selection, never from the workbook. The project root is not created by this import.

The supported v1 operational dataset is the Project identity guard plus current milestones, deliverables, risks, issues, actions, decisions and same-Project dependencies in the sheets below. It does not import membership/team assignments, financial baselines/actuals, resource allocations, document binaries, status publications, snapshots or audit history; those remain in their separately governed workflows. Replace mode shows counts and explicitly identifies these preserved areas before confirmation.

## Workbooks provided by the screen

1. **Modelo vazio** — a generated copy uses the exact v1 sheet names/headers and pre-fills the selected Project code in the identity guard. This repository's reusable blank master leaves `project_code` empty for the implementation to prefill when served in the app. It contains no business rows.
2. **Projeto exemplo preenchido** — same v1 schema with coherent, synthetic example data demonstrating a complete supported PMO dataset. It is explicitly labeled as sample data; users must replace the sample Project code and content before importing. It contains no real person, customer or confidential data.

Both files are generated from the same versioned schema and downloadable only after project visibility/authorization checks. `Projeto.template_version` and header comments carry the schema/instruction marker; no additional instruction sheet is allowed. Hidden or extra sheets, macros, external links, formulas, and unknown columns are rejected; formulas are never executed. Import accepts `.xlsx`, not legacy `.xls` or macro-enabled `.xlsm`.

### Repository files

- [Blank reusable master workbook](templates/project-import-template-v1-empty.xlsx)
- [Populated synthetic example workbook](templates/project-import-template-v1-example.xlsx)

The blank master intentionally leaves `Projeto.project_code` empty; the application must inject the selected project's code into a download copy at runtime.

The reusable master contains the initial platform dropdown choices. A project-specific download generated for a Tenant must reflect that Tenant's enabled `Riscos.category` options, while retaining the versioned schema and protecting system-defined codes from arbitrary workbook additions.

## v1 sheet and column contract

Headers are exact, case-sensitive, snake_case names. `external_key` is unique within the Project and sheet and is the stable source identity for append conflict detection. Dates use ISO `YYYY-MM-DD`; timestamps use UTC ISO-8601; enum values use the exact values listed below; blank optional cells mean no value. Formula cells are invalid.

| Sheet | Columns |
|---|---|
| `Projeto` | `project_code` (required identity guard), `template_version` (must equal `project-import-v1`) |
| `Marcos` | `external_key`, `title`, `description`, `planned_start_date`, `planned_due_date`, `forecast_start_date`, `forecast_due_date`, `actual_date`, `status`, `owner_email`, `progress_percent` |
| `Entregas` | `external_key`, `title`, `description`, `due_date`, `status`, `acceptance_status`, `delivered_at`, `accepted_at`, `owner_email` |
| `Riscos` | `external_key`, `title`, `description`, `cause`, `consequence`, `category`, `probability`, `impact`, `status`, `trend`, `owner_email`, `due_date`, `mitigation`, `contingency` |
| `Issues` | `external_key`, `title`, `description`, `root_cause`, `impact`, `priority`, `blocker`, `status`, `owner_email`, `due_date`, `resolved_at`, `resolution` |
| `Acoes` | `external_key`, `title`, `description`, `source_type`, `source_external_key`, `owner_email`, `due_date`, `priority`, `status`, `progress_percent`, `actual_completed_at`, `completion_outcome`, `cancellation_reason` |
| `Decisoes` | `external_key`, `title`, `description`, `decision_maker_email`, `due_date`, `status`, `decided_at`, `outcome` |
| `Dependencias` | `external_key`, `source_type`, `source_external_key`, `target_type`, `target_external_key`, `dependency_type`, `status`, `lag_days` |

## Validation and relationship rules

### Initial tenant taxonomy values

Tenant provisioning seeds the following initial codes. Display labels may be translated/customized by the Tenant, but codes remain stable. The importer accepts only codes enabled for the selected Tenant; a Tenant may explicitly add taxonomy values where allowed by the owning Spec. `Marcos.type` and `Marcos.criticality` are platform defaults for milestone creation, but are not columns in the current `Marcos` import sheet v1 and therefore are not imported from this workbook version.

| Field | Initial codes |
|---|---|
| `Marcos.type` | `project_start`, `phase_gate`, `major_deliverable`, `review`, `project_end`, `other` |
| `Marcos.criticality` | `low`, `medium`, `high`, `critical` |
| `Riscos.category` | `scope`, `schedule`, `cost`, `quality`, `resource`, `supplier`, `technical`, `security`, `compliance`, `other` |
| `Riscos.trend` | `improving`, `stable`, `worsening` |
| `Acoes.source_type` | `risk`, `issue`, `milestone`, `deliverable`, `decision`, `manual` |

For `Acoes.source_type=manual`, `source_external_key` must be blank. All other action source types require an existing, valid source of that type in the same Tenant and Project. Taxonomy values outside the initial set are accepted only if explicitly configured for that Tenant and supported by the owning domain; a workbook cannot introduce taxonomy values.

- Only rows for the selected Project are imported. Every owner/decision maker must already be an active member of the same Tenant and eligible for that Project; workbook email is a lookup hint, not proof of identity or authorization.
- `external_key` must be non-empty and unique within its sheet. Cross-sheet references resolve through sheet + `external_key`; missing, ambiguous, cross-Project or unauthorized references block the affected rows.
- Stable source-key mappings are retained in `external_mappings` under provider namespace `project_xlsx_v1`, scoped by Tenant + Project + sheet/entity type; restart archives active mappings and creates successor mappings while preserving lineage.
- Enums and lifecycle/required-field constraints are those of the owning Specs (005, 007–013). Risk probability/impact use integers 1–5; issue/action priorities use `low|medium|high|critical`; dependency endpoints must be supported Project items and valid same-Tenant relations. No workbook field can set `tenant_id`, internal UUID, grant, publication, snapshot, audit record, or system timestamp.
- This template imports current operational state only; it does not recreate assessment, comment, publication or other append-only sub-history. A risk may include its current mitigation/contingency; prior assessments remain attached to preserved historical records.
- Invalid headers/version, unexpected sheets, formula cells, duplicate keys, invalid relations, inaccessible owner, invalid dates/enums or data-policy violations produce row/sheet diagnostics with workbook coordinates. No partial source writes occur when validation fails.
- Per-file size/row limits come from the platform upload policy and are shown before upload. Malware scanning and private temporary storage occur before parsing.

## Initial import, append and restart

“Project has data” for the mode prompt means at least one active operational record in the v1 import scope; the Project identity row alone does not count. The screen also reports preserved data outside v1 scope. Immutable audit events, publications and snapshots are historical records and are never erased by this feature.

- If the v1 operational scope is empty, validate and preview normally, then import without showing the append/restart choice. The user still starts the upload/import action; successful validation applies the initial dataset.
- If active operational data exists, show counts and ask the user to choose **Adicionar dados** or **Reiniciar dados do projeto** before applying.
- **Adicionar dados** inserts new entities only. A key already present in the Project/sheet, or a duplicate in the workbook, is a blocking conflict; it does not silently overwrite existing data. Relationships resolve within the combined existing + staged dataset. Repeating an identical confirmed job is idempotent.
- **Reiniciar dados do projeto** atomically archives the active v1 operational records in scope and their external-key mappings, then creates the new active dataset from the workbook. It requires `project.data.import.replace`, a fresh confirmation showing the selected Project name and affected counts, and a typed confirmation token derived from that Project. It never hard-deletes immutable audit, published status, snapshots, or records required for retention/legal hold. Those remain historical and are visibly marked as prior history; the new operational records become current only after the whole replacement commits.
- The replacement operates only on the selected Project and v1 sheets; it cannot affect other Projects, Tenant membership, portfolio links, integrations, or records outside the documented import scope. If retained records or external dependencies prevent safe archival, validation blocks restart and lists the affected records.

The user-facing “reiniciar” option therefore replaces the current supported operational dataset while preserving required history. It is not a hard deletion of the Project identity or immutable governance history.

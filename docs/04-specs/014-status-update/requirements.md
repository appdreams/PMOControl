# SPEC-014 — Status Update — Requirements

**Status:** Draft — workflow, KPI-v1, monthly cadence and snapshot-v1 defined

## Domain workflow

A Status Update is a dated Project reporting draft that consolidates current operational entities; it is not a duplicate database. Project Manager with explicit `status.update.publish` may publish directly. Publication atomically creates official Publication and immutable Snapshot; projections/notifications are post-commit. No second-person approval is required in the MVP default. Correction requires `status.update.correct`, a reason and a successor publication.

## Functional requirements

- **FR-014-01:** create one draft per active Project and monthly reporting period, where period is first day and status date is last day in Tenant timezone; default publication deadline is fifth business day of following month.
- **FR-014-02:** load milestones, deliverables, risks, issues, actions, decisions, financial/progress indicators and deltas from official sources with source IDs, versions and as-of timestamps.
- **FR-014-03:** validate required checklist and ownership; return blocking errors separately from warnings; N/A metrics require a reason.
- **FR-014-04:** save draft sections with `expected_version`; edits never mutate source entities unless user invokes the corresponding governed command.
- **FR-014-05:** publish only after fresh Tenant, membership, Project-scope and `status.update.publish` checks; calculate versioned `kpi-v1`/`rag-v1` deterministically and create `snapshot-v1`.
- **FR-014-06:** commit published state, Publication, Snapshot, audit/outbox atomically; failure before commit leaves no partial publication.
- **FR-014-07:** update dashboards/portfolio and notify by idempotent post-commit jobs; failure does not roll back published state.
- **FR-014-08:** correct by authorized PM/PMO Admin using `status.update.correct` and non-empty reason; create successor linked to prior publication, never edit prior snapshot.
- **FR-014-09:** display Current vs Last Published and explain source/time/availability for every material KPI.
- **FR-014-10:** reject publish if any source version changed since preview; refresh consolidation and require actor confirmation before retry.

## Pending contract decisions

Defaults are monthly cadence and `kpi-v1`/`rag-v1` calculations in `business-rules.md`; tenant may configure cadence in a later release. They do not change the agreed default MVP direct-publish policy.


## Acceptance/test traceability

| Requirement | Acceptance | Test |
|---|---|---|
| `FR-014-01` draft per Project/reporting date | `AC-014-09` | `TC-014-20` |
| `FR-014-02` authorized source consolidation/delta | `AC-014-10` | `TC-014-21` |
| `FR-014-03` blocking validation vs warning | `AC-014-10` | `TC-014-10` |
| `FR-014-04` versioned draft save, no source mutation | `AC-014-04` | `TC-014-14`, `TC-014-22` |
| `FR-014-05` direct authorized publish + fresh auth | `AC-014-01`, `AC-014-07` | `TC-014-06`, `TC-014-08`, `TC-014-15/16` |
| `FR-014-06` atomic publication/snapshot/audit/outbox | `AC-014-01/02` | `TC-014-01/02` |
| `FR-014-07` post-commit retry-safe projections | `AC-014-05` | `TC-014-03` |
| `FR-014-08` correction successor, reason, permission | `AC-014-08` | `TC-014-12`, `TC-014-17/19` |
| `FR-014-09` temporal mode/source transparency | `AC-014-04/10` | `TC-014-09/13/21` |
| `FR-014-10` source consistency at publish | `AC-014-10` | `TC-014-25` |
| `FR-014-01` monthly cycle/checklist | `AC-014-11` | `TC-014-23` |
| `FR-014-05` KPI-v1/RAG calculation | `AC-014-12` | `TC-014-11/24` |

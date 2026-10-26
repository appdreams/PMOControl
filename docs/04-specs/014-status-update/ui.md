# SPEC-014 — Status Update — UI

**Status:** Draft — wizard and publish states

Five steps: execution/indicators; milestones/deliverables; risks/issues; actions/decisions; summary/publication. Show source data, changes since prior snapshot, source timestamp and Current vs Last Published distinction. Editing a field on this wizard edits the draft only; linked entities require navigation to their governed editor.

Validate reports blocking errors and non-blocking warnings separately. Publish button is shown only with `status.update.publish`; no PMO second-approval step in MVP. Confirmation summarizes publication/snapshot date. Correction action requires `status.update.correct`, mandatory reason and creates a successor. Published snapshot is read-only.

Include draft loading/saving, stale-version conflict, permission revoked, validation errors, publish in progress, pre-commit failure, published with post-commit jobs pending, success, empty first publication and inaccessible source states.

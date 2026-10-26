# SPEC-014 — Status Update — User Flows

**Status:** Draft — direct-publish MVP workflow

## Prepare and publish

```text
Open/create draft for reporting date → load current authorized sources + last published delta
→ edit summary/sections (not source entities) → validate blocking rules/warnings
→ Project Manager with explicit status.update.publish confirms publish
→ fresh authorization/version check → calculate KPI/RAG → atomic Publication + Snapshot + audit/outbox commit
→ async dashboard/portfolio projections and notification retries
```

PMO reviews published report as a consumer and may request correction. User with `status.update.correct` supplies reason and creates a successor publication; previous publication/snapshot remains immutable. Second-person approval is not required in MVP.

## Failure states

Pre-commit failure returns actionable error and leaves draft unchanged. Stale version returns conflict. Post-commit projection/job failure shows publication success with pending effect and retries safely.

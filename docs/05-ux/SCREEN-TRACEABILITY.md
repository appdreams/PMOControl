# UX Screen-to-Spec Traceability

**Status:** Draft — 34 screen contracts mapped; product/design review pending

This register binds every MVP UX screen to its governing Spec, action grants, API boundary and acceptance/test evidence. A screen is presentation only: every action revalidates authorization server-side. Visual references are non-normative.

| Screen | Spec / requirements | Main behavior and grant | API boundary | Acceptance / tests |
|---|---|---|---|---|
| `01-access/login.md` | SPEC-001 FR-001-01/02/04/06 | Email/password login, neutral recovery, session/logout; no business grant before membership context | Auth login/recovery/reset, session, select tenant | AC-001-01/02/04/06; TC-001-01/02/04/06 |
| `11-administration/tenant-management.md` | SPEC-002 FR-002-01–05 | Platform-only create/suspend/terminate; reason and export-first lifecycle | Tenant provision/suspend/activate/terminate/export | AC-002-01–05; TC-002-01–08 |
| `11-administration/platform-projects.md` | SPEC-005 FR-005-10/11; SPEC-003 FR-003-10 | Platform Root Admin only; minimal identity/impact preview, reason + typed-code confirmation; preserve retention/holds without content access | Platform project selector/purge-preview/purge/job status | AC-005-07–09; TC-005-11–14; AC-003-08/09; TC-003-12/13 |
| `11-administration/access-management.md` | SPEC-002/003 FR-002-06–09, FR-003-01–08 | Invite/revoke member, assign role/scope within delegation ceiling, membership switch | Invitations, memberships, access-grants, session tenants | AC-002-06–09, AC-003-02/05/06; TC-002-09–14, TC-003-02–06 |
| `11-administration/settings.md` | SPEC-029 FR-029-01–09 | Tenant configuration and versioned settings; sensitive secrets are references only | Tenant settings read/update/reset/rotate reference | AC-029-01–05; TC-029-01–09 |
| `11-administration/ai-configuration-usage.md` | SPEC-025 FR-025-10–15 | Tenant BYOK credential and three models; automatic complexity routing; usage/cost metering and export under separate grants | Tenant AI config validate/rotate/disable; scoped usage query/export | AC-025-07–10; TC-025-11–19 |
| `11-administration/notifications.md` | SPEC-026 FR-026-01–09 | Inbox, read state, preferences; retry/delivery controls are admin-only | Notifications inbox/preferences; delivery status | AC-026-01–05; TC-026-01–09 |
| `11-administration/import-export.md` | SPEC-028 FR-028-01–16 | Tenant-scoped project picker; blank/example XLSX; empty initial load, append or guarded restart; authorized export | Project selection/templates/validate/apply-initial/append/replace/export | AC-028-01–12; TC-028-01–22 |
| `11-administration/audit-log.md` | SPEC-027 FR-027-01–09 | Append-only audit query/export by scoped grant; no edit/delete | Audit event query/detail/export | AC-027-01–05; TC-027-01–09 |
| `10-intelligence/pmo-copilot.md` | SPEC-025 FR-025-01–09 | Grounding inherits user authorization; proposed writes require human confirmation | Copilot ask/sources/propose/confirm | AC-025-01–05; TC-025-01–09 |
| `09-reporting/report-builder.md` | SPEC-024 FR-024-01–09 | Preview and generate temporal report; download rechecks access and expiry | Report templates/preview/jobs/download | AC-024-01–05; TC-024-01–09 |
| `05-governance/risks.md` | SPEC-009 FR-009-01–09 | Create/assess/respond/materialize/close risk; score and owner validation | Risks, assessments, responses, materialize/close | AC-009-01–06; TC-009-01–10 |
| `05-governance/issues.md` | SPEC-010 FR-010-01–09 | Track existing problem, owner, impact, blocker and resolution | Issues create/update/resolve | AC-010-01–06; TC-010-01–10 |
| `05-governance/decisions.md` | SPEC-012 FR-012-01–09 | Request decision, assign decision maker, approve/reject/defer with outcome | Decisions request/decide/defer | AC-012-01–06; TC-012-01–10 |
| `05-governance/actions.md` | SPEC-011 FR-011-01–09 | Assign commitment, due date, source and completion evidence | Actions create/update/complete | AC-011-01–06; TC-011-01–10 |
| `02-workspace/my-day.md` | SPEC-017 FR-017-01–06 | Authorized cross-project exception inbox; each action routes to governed source command | My Day read model and source deep links | AC-017-01–05; TC-017-01–08 |
| `07-control/resources.md` | SPEC-021 FR-021-01–09 | View capacity, allocate/deallocate and resolve conflicts under resource grant | Resource capacity/allocations | AC-021-01–06; TC-021-01–10 |
| `07-control/financial.md` | SPEC-020 FR-020-01–09 | Restricted budget/forecast/actual fields; financial grants separate from project view | Project financial query/update | AC-020-01–06; TC-020-01–10 |
| `08-knowledge-history/time-machine.md` | SPEC-023 FR-023-01–06 | Browse immutable snapshots and compare historical/current state | Timeline/historical view/compare snapshots | AC-023-01–05; TC-023-01–08 |
| `08-knowledge-history/documents.md` | SPEC-022 FR-022-01–09 | Upload/version/link evidence/download; classification checked on every access | Documents metadata/upload/version/evidence/download | AC-022-01–06; TC-022-01–10 |
| `03-portfolio/portfolio.md` | SPEC-004 FR-004-01–09 | Portfolio CRUD/archive and same-Tenant project association | Portfolio create/update/archive/project association | AC-004-01–06; TC-004-01–10 |
| `03-portfolio/executive-portfolio.md` | SPEC-019 FR-019-01–06 | Authorized aggregation only; show as-of and project coverage | Portfolio dashboard projection | AC-019-01–05; TC-019-01–08 |
| `04-project/team.md` | SPEC-005 FR-005-01–09 | Assign Project members and role/scope; no implied sensitive grants | Project assignments and access grants | AC-005-01–06; TC-005-01–10 |
| `04-project/schedule.md` | SPEC-005/007/013 FR-005-01–09, FR-007-01–09, FR-013-01–09 | Show baseline/forecast/actual, milestone and dependency paths; baseline changes use governed approval | Project schedule, milestone forecast, dependency queries | AC-005/007/013 domain criteria; TC-005/007/013 isolation and lifecycle cases |
| `04-project/project-control-center.md` | SPEC-006 FR-006-01–06 | Read-only authorized current/published projection; freshness and source versions visible | Project control-center projection | AC-006-01–05; TC-006-01–08 |
| `04-project/milestones.md` | SPEC-007 FR-007-01–09 | Create/update/forecast/complete milestone; baseline mutation is separate governed command | Milestone commands/queries | AC-007-01–06; TC-007-01–10 |
| `04-project/deliverables.md` | SPEC-008 FR-008-01–09 | Record delivery and explicit acceptance/rejection with evidence | Deliverable commands/queries | AC-008-01–06; TC-008-01–10 |
| `04-project/dependencies.md` | SPEC-013 FR-013-01–09 | Link same-Tenant project items; prevent cycles and invalid terminal links | Dependency create/update/resolve | AC-013-01–06; TC-013-01–10 |
| `06-status-update/status-update.md` | SPEC-014 FR-014-01–10 | Monthly draft, source preview, checklist, KPI-v1/RAG-v1, direct publish/correct | Status draft/validate/publish/corrections | AC-014-01–12; TC-014-01–25 |
| `06-status-update/status-update-step-1-execution-indicators.md` | SPEC-014 FR-014-02/05/09 | Show planned/actual, baseline/forecast, KPI source/as-of and N/A reason | Authorized source queries + KPI preview | AC-014-10/12; TC-014-11/21/24 |
| `06-status-update/status-update-step-2-milestones-deliverables.md` | SPEC-014 FR-014-02/04/10 | Read source items, show date variance; draft edit never mutates source | Milestone/deliverable reads | AC-014-04/10; TC-014-21/22/25 |
| `06-status-update/status-update-step-3-risks-issues.md` | SPEC-014 FR-014-02/03/05 | Show Red risks and required owner/response or accepted decision | Risk/issue reads + checklist | AC-014-10/11; TC-014-09/10/24 |
| `06-status-update/status-update-step-4-actions-decisions.md` | SPEC-014 FR-014-02/04/10 | Show owner, due state and pending decisions; preparation is read-only | Action/decision reads | AC-014-04/10; TC-014-21/22/25 |
| `06-status-update/status-update-step-5-summary-publication.md` | SPEC-014 FR-014-01/03/05–10 | Validate month, blockers/warnings, publish with grant; correction requires separate grant/reason | Status validate/publish/corrections | AC-014-01–03/07–12; TC-014-01–05/15–25 |

## Review rule

The row is a traceability index, not proof that a backend or test has been implemented. During implementation, every listed action must be checked against its concrete request/response schema and executable test fixture. The companion visual references remain non-normative.


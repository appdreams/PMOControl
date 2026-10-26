# SPEC-001 — Authentication — UI

**Status:** Draft — MVP screen contract

Login uses email and password only, with password recovery and access request/invitation path. MFA and Google/Microsoft SSO are not shown in MVP.

After login, route directly when exactly one active membership exists; show a tenant chooser when multiple exist; show a no-membership state with support/access-request guidance when none exists. Display tenant name and current identity in workspace context with an explicit switch action for multi-tenant users.

Errors are neutral against account enumeration. Include loading/disabled submit, invalid-credential, provider-unavailable, recovery-sent, expired-link, no-access and session-expired states. Never show tokens or secrets; keyboard accessibility and screen-reader labels are required.

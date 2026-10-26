# Audit Data Model

**Status:** Approved

## Table

`audit_events`

## Minimum fields

``` text
id
tenant_id
actor_user_id
actor_type
action
resource_type
resource_id
project_id nullable
scope_context jsonb
previous_state jsonb nullable
new_state jsonb nullable
reason nullable
correlation_id
request_id nullable
ip_metadata nullable
user_agent_metadata nullable
occurred_at
```

## Sensitive events

-   login/security changes;
-   membership/access grants and revocations;
-   role/scope changes;
-   baseline/forecast/budget changes;
-   RAG override;
-   status publication;
-   executive decision;
-   destructive/archive operations;
-   sensitive export;
-   privileged/support access;
-   AI consequential action confirmation.

## Rules

Audit is append-oriented. Ordinary tenant users cannot mutate audit
history. Secrets, raw credentials and unnecessary personal data must
never be copied into audit payloads.

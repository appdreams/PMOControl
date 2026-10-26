# PostgreSQL Schemas

**Status:** Approved

## Recommended logical schemas

For MVP, physical separation may remain conservative. The following
logical boundaries guide naming and ownership:

``` text
public/auth-facing
app
audit
integration
ai
reporting
```

A single application schema is acceptable initially if migration tooling
and Supabase conventions make it simpler. Domain modularity must still
be preserved in code and table naming.

## Recommended ownership

-   `app`: tenant business data.
-   `audit`: immutable audit trail.
-   `integration`: connections, external mappings, sync jobs.
-   `ai`: AI execution metadata, prompts/version references, action
    proposals.
-   `reporting`: persisted report definitions/runs if required.

## Supabase Auth

Supabase Auth owns authentication identities/sessions. PMO Control owns
business memberships, roles, scopes and permissions.

Authentication identity must not be treated as authorization.

## Naming

-   tables: `snake_case`, plural
-   columns: `snake_case`
-   primary keys: `id`
-   foreign keys: `<entity>_id`
-   timestamps: `*_at`
-   actors: `*_by`
-   boolean: `is_*`, `has_*`, `can_*` only when semantically appropriate

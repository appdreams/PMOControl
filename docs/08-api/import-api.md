# Import API

**Status:** Approved

## Lifecycle

Upload → Staging → Validate → Preview → Confirm → Apply → Result.

## Resources

`/import-jobs`

## Rules

-   imported content is untrusted;
-   no mutation before confirmation;
-   row-level errors are visible in preview;
-   tenant/scope authorization applies to every target;
-   apply is idempotent where possible;
-   import audit records source/job/actor.

# AI Data Model

**Status:** Approved

## Principle

AI metadata is traceable, but AI output is not authoritative business
state until an authorized human-confirmed domain command persists it.

## Tables

### `ai_requests`

Stores tenant/user/project context references, use case, provider/model
reference, prompt template version, authorization context fingerprint
and timestamps.

### `ai_responses`

Stores structured response metadata, classification
(Fact/Inference/Recommendation), validation result, token/cost metadata
when available and safe.

### `ai_action_proposals`

Stores proposed consequential changes and confirmation lifecycle.

## BYOK

Provider credentials must be encrypted/secret-managed and never returned
in clear text. Business tables should store credential references, not
raw keys where platform secret facilities can be used.

## Grounding

Persist references/IDs used for grounding where useful for traceability.
Do not duplicate large confidential datasets into AI logs.

## Authorization

`AI Context ≤ Authorized User Context`.

Fresh authorization is required before applying a proposed write.

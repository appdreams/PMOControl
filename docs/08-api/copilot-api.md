# PMO Copilot API

**Status:** Approved

## Resource

`/api/v1/copilot`

## Use cases

Q&A, executive summary, project changes, risk briefing, committee
preparation and recommendations.

## Request

Carries user intent and explicit context references; server resolves
authorized grounding.

## Response

Should distinguish Fact, Inference and Recommendation where relevant.

## Proposed writes

AI returns an action proposal. Human confirms → fresh authorization →
domain validation → command → audit.

## Security

Never accept arbitrary client-provided privileged grounding as trusted
context.

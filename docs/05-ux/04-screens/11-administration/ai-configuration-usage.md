# Screen — AI Configuration & Usage

**Status:** Draft — behaviorally specified, visual review pending
**Spec:** SPEC-025 (PMO Copilot)
**Grants:** `ai.config.view`, `ai.config.manage`, `ai.cost.view`, `ai.cost.export`

## Purpose

Let an authorized Tenant administrator configure the company's own AI provider credential, map one model to each automatic complexity class, and review the Tenant's AI consumption and spending.

## Configuration panel

- Select an enabled provider and enter its credential through a protected write-only field.
- Provider choices are OpenAI GPT (`openai`), Google Gemini (`google_gemini`), Anthropic Claude (`anthropic_claude`), Meta Llama (`meta_llama`), DeepSeek (`deepseek`) and OpenRouter (`openrouter`). OpenRouter uses its own credential and provider-specific model IDs; Meta Llama requires selection of a platform-approved compatible inference endpoint and credential validation. Tenants cannot enter an arbitrary endpoint URL.
- Save, validate, rotate and disable the credential. After saving, display only configured/validated status, masked presence, provider, models, config version and last validation time; never show the credential again.
- Map exactly one model to low, medium and high complexity. Display the routing rule version and explain that the system chooses the class automatically; there is no user override.
- Require explicit confirmation and reason for disable/rotation where configured by policy.

## Usage and costs panel

- Filter by date range and group by day, provider, model, use case or complexity.
- Show requests, input/output/cached tokens when available, currency, provider-reported charges and locally estimated costs separately, plus unavailable measurements. Never add amounts across currencies; group/filter by currency or convert only through an explicitly identified rate source/version.
- Show tariff source/version and last refresh; label estimates clearly and state that application metering is not the provider invoice.
- Permit CSV/JSON export only with `ai.cost.export`; async download rechecks Tenant membership, grants and expiry.

## States and accessibility

Loading, no configuration, configured, credential invalid, provider unreachable, no usage, partial metering, forbidden, stale version, export processing/failure and retryable error have distinct messages. Never include secret values in errors. All filters, metrics and warnings are keyboard reachable, labeled and understandable without color alone.

## Security and behavior

The server derives Tenant from verified membership and scoped authorization. Cost data is not visible from Copilot permission alone. Secrets never enter browser storage, analytics, URLs, logs, screenshots or response payloads. Disable blocks new calls; requests already dispatched retain their resolved config version. The page is an administration surface, not an authorization boundary.

# SPEC-025 — PMO Copilot — Database

**Status:** Draft — modelo lógico e constraints necessários

## Tabela lógica

`ai_requests(id UUID,tenant_id UUID,actor_id UUID,scope JSONB,question_hash CHAR(64),prompt_version TEXT,model_provider TEXT,model_key_ref TEXT NULL,requested_at TIMESTAMPTZ,status TEXT,correlation_id UUID)` stores minimized metadata; raw question/grounding is not persisted by default.

`ai_responses(id UUID,tenant_id UUID,request_id UUID,classification TEXT,structured_output JSONB,citations JSONB,token_usage JSONB,created_at TIMESTAMPTZ)` stores validated output only when product policy enables it. `ai_action_proposals(id UUID,tenant_id UUID,request_id UUID,actor_id UUID,action_type TEXT,resource_ref JSONB,proposed_payload JSONB,payload_hash CHAR(64),status TEXT,confirmed_at TIMESTAMPTZ,executed_at TIMESTAMPTZ,expires_at TIMESTAMPTZ)` records human-in-the-loop lifecycle; it is not a domain source of truth.

`ai_provider_configs(id UUID,tenant_id UUID,provider TEXT,endpoint_id TEXT NULL,secret_ref TEXT,model_low TEXT,model_medium TEXT,model_high TEXT,is_enabled BOOLEAN,validation_status TEXT,config_version BIGINT,created_by UUID,updated_by UUID,created_at/updated_at TIMESTAMPTZ)` stores one active config per Tenant/provider. `secret_ref` points only to encrypted secret storage; provider credentials are never persisted in plaintext in this database. `endpoint_id` is a platform-approved adapter registry identifier, never an arbitrary URL supplied by a Tenant.

`ai_usage_records(id UUID,tenant_id UUID,request_id UUID,attempt_id UUID,use_case TEXT,provider TEXT,model_id TEXT,complexity TEXT,router_rule_version TEXT,input_tokens BIGINT NULL,output_tokens BIGINT NULL,cached_input_tokens BIGINT NULL,provider_cost NUMERIC(20,8) NULL,estimated_cost NUMERIC(20,8) NULL,currency CHAR(3) NULL,rate_card_id TEXT NULL,measurement_status TEXT,status TEXT,started_at/finished_at TIMESTAMPTZ)` is append-only metering for every external attempt, including failures where provider usage is available. Insert one completed usage record per provider attempt; completed ledger rows are immutable.

## Constraints

- Composite FKs and source references enforce Tenant; AI request scope is recorded from server authorization, never client role/tenant claims. Raw prompts, secrets and grounding text are excluded unless separately enabled, encrypted and time-limited.
- `UNIQUE(tenant_id,provider)` for active provider configuration; `CHECK(model_low <> '' AND model_medium <> '' AND model_high <> '')`; `CHECK(complexity IN ('low','medium','high'))`. Credentials stay in a secret manager and rotation updates only the secret reference/version; audit excludes the secret value.
- `provider IN ('openai','google_gemini','anthropic_claude','meta_llama','deepseek','openrouter')`; labels/provider aliases are normalized server-side. `validation_status IN ('unvalidated','valid','invalid','unavailable')`; disabled/invalid configurations cannot route requests. `meta_llama` requires an explicitly configured compatible inference endpoint in the adapter registry; never assume a direct hosted endpoint. OpenRouter credentials/model IDs remain independent.
- Usage rows are append-only and linked to request within the same Tenant. Tokens/cost are non-negative; `measurement_status IN ('provider_reported','rate_estimated','unavailable')`; unavailable measurement requires nullable cost, not zero. Store tariff/version/currency used for reproducible estimates; do not claim these measurements equal provider invoices.
- Period aggregation uses Tenant timezone and a half-open period `[start,end)`; queries are Tenant-bounded and cost fields require `ai.cost.view`. Secret management requires `ai.config.manage`; cost export requires `ai.cost.export`.
- Proposal status `proposed|confirmed|executing|executed|rejected|expired|failed`; `confirmed_at` required for confirmed/executing/executed; expiry required; payload hash binds the displayed proposal to execution.
- Confirm endpoint reauthorizes current actor/grant, validates domain command and commits audit atomically; proposal cannot mutate domain tables directly. `model_key_ref` is a secret-manager reference only.
- Indexes `(tenant_id,actor_id,requested_at DESC)`, `(tenant_id,request_id)`, `(tenant_id,status,expires_at)`; retention defaults follow AI category in `docs/06-data/retention-archival.md`.
- Indexes `(tenant_id,provider,is_enabled)`, `(tenant_id,request_id,attempt_id)` unique, `(tenant_id,requested_at DESC)`, `(tenant_id,model_id,requested_at)`, `(tenant_id,complexity,requested_at)`; usage ledger retention follows AI operational retention, with aggregate financial records retained per policy.

## RLS e transações

RLS filtra Tenant a partir de contexto verificado; escrita também exige autorização de aplicação. Não aceitar `tenant_id` do cliente como contexto seguro. Eventos/outbox gravados na mesma transação das mutações que os originam; consumidores executam após commit.

## Migration e exclusão

Expand → migrate/backfill → verify → contract. Proposal and audit metadata are retained per policy; prompt/grounding content defaults to no persistence and any optional content retention must be encrypted and expiring. Secret rotation/revocation is independent of request/usage history; deleting a Tenant disables credentials immediately, exports permitted usage summaries, then purges secret references and detail per retention policy.

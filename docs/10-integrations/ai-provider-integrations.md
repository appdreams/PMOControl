# AI Provider Integrations

**Status:** Draft — provider adapter implementation and runtime validation pending

## Boundary

Integrações de IA passam pelo AI Gateway.

## MVP

BYOK separado por Tenant/provider para OpenAI GPT, Google Gemini, Anthropic Claude, Meta Llama (por endpoint de inferência compatível da allowlist da plataforma), DeepSeek e OpenRouter. OpenRouter mantém credencial e IDs próprios; nenhuma credencial/provider é compartilhada implicitamente. A lista normativa e códigos internos estão em `docs/09-ai/provider-adapters.md` e SPEC-025.

## Evolução

Providers adicionais ou endpoints privados só entram após adapter registry, revisão de segurança, capability discovery e atualização explícita da allowlist/UI.

## Regra

Provider credential é tenant-scoped. Provider/model não expande
autorização de dados.

## Contrato

Adapters normalizam requests, responses, usage, errors e capabilities.

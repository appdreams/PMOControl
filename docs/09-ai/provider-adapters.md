# Provider Adapters

**Status:** Draft — adapter implementation and provider credentials require runtime verification

## Provedores disponíveis no MVP

A tela de configuração oferece exatamente estes provedores BYOK:

| Código interno | Nome exibido | Modelo/família esperada |
|---|---|---|
| `openai` | OpenAI | GPT |
| `google_gemini` | Google | Gemini |
| `anthropic_claude` | Anthropic | Claude |
| `meta_llama` | Meta | Llama, via adapter/endpoint de inferência compatível da allowlist da plataforma |
| `deepseek` | DeepSeek | DeepSeek |
| `openrouter` | OpenRouter | IDs de modelo publicados pelo OpenRouter, incluindo modelos disponibilizados nele |

Cada provedor possui credencial BYOK separada por Tenant e três mapeamentos de modelo (`low`, `medium`, `high`). OpenRouter é um provedor distinto; não compartilha credencial automaticamente com os outros cinco. Meta Llama é tratado como família de modelos e somente fica disponível quando existe endpoint de inferência compatível no adapter registry; não presumir que há uma API hospedada direta configurada. Capability discovery valida provider/model/endpoint antes de habilitar uma rota.

Provedores adicionais podem ser incluídos somente por mudança versionada no adapter registry, revisão de segurança, cobertura de testes e atualização explícita da UI/allowlist.

## Interface conceitual

-   generate structured response;
-   generate text;
-   embeddings quando adotados;
-   capability discovery;
-   usage metadata.

## Regras

Adapters convertem contrato interno para contrato do provider e
vice-versa. Provider-specific types não atravessam o AI Gateway.

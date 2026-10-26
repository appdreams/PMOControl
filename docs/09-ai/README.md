# PMO Control --- AI

**Status:** Draft — authorization and contract re-audit required\
**Official path:** `/docs/09-ai/README.md`

## Objetivo

Definir a camada de inteligência artificial do PMO Control: PMO Copilot,
AI Gateway, BYOK, grounding, prompts, modelos, segurança,
observabilidade, avaliação e evolução futura para agentes.

No MVP, cada empresa (Tenant) configura sua credencial do provider, mapeia modelos para três níveis de complexidade e acompanha o próprio uso/gastos. Roteamento de complexidade é automático no Gateway por regra determinística versionada; detalhes e controles estão em `byok.md`, `model-routing.md`, `ai-cost-governance.md` e SPEC-025.

## Princípio central

`AI assists. Domain governs. Human decides.`

## Regras fundamentais

-   IA não é source of truth.
-   `AI Context ≤ Authorized User Context`.
-   RAG oficial é determinístico.
-   IA distingue Fact, Inference e Recommendation.
-   Ações consequenciais exigem confirmação humana e nova autorização.
-   Falha de IA não bloqueia funções centrais de governança.
-   Provider/model não deve contaminar o domínio.
-   Cada Tenant fornece credencial BYOK própria; segredo fica em secret manager e não é retornável.
-   Cada provider ativo do Tenant mapeia modelos para complexidade baixa, média e alta; Gateway seleciona automaticamente por regra determinística versionada.
-   Configuração de provider/modelo e tela de custos/uso são tenant-scoped, permissionadas e auditáveis.

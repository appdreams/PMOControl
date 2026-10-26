# ADR-009 --- AI Gateway + BYOK

**Status:** Accepted\
**Date:** 2026-10-25\
**Decision:** Centralizar o acesso a modelos de IA através de um AI
Gateway interno e adotar BYOK (Bring Your Own Key) por Tenant, iniciando
com OpenAI e preservando arquitetura para múltiplos providers.

------------------------------------------------------------------------

## 1. Context

O PMO Control incorpora IA como capacidade transversal de governança,
especialmente através do PMO Copilot.

Casos de uso incluem:

-   perguntas sobre Projects e Portfolios;
-   resumos executivos;
-   preparação de comitês;
-   análise de mudanças desde o último Status;
-   síntese de Risks e Issues;
-   drafts de relatórios;
-   recomendações;
-   análise de Documents autorizados;
-   futura simulação e agentes.

A arquitetura precisa suportar IA sem:

-   acoplar domínio a um único provider;
-   permitir que IA amplie acesso;
-   expor API keys;
-   transformar LLM em fonte de verdade;
-   permitir escrita consequencial sem controle humano.

------------------------------------------------------------------------

## 2. Problem

É necessário definir:

1.  como módulos acessam modelos;
2.  onde providers são abstraídos;
3.  como credentials são isoladas;
4.  como autorização é preservada;
5.  como diferentes modelos/providers podem evoluir;
6.  como controlar custo, observabilidade e falhas.

------------------------------------------------------------------------

## 3. Decision Drivers

Principais drivers:

-   multi-tenancy;
-   BYOK;
-   provider portability;
-   segurança;
-   autorização;
-   custo;
-   observabilidade;
-   model routing;
-   graceful degradation;
-   testabilidade;
-   governança de prompts;
-   futura evolução para agentes.

------------------------------------------------------------------------

## 4. Decision

Adotar:

``` text
Application / AI Use Case
        ↓
Authorized Context Builder
        ↓
AI Policy
        ↓
AI Gateway
        ↓
Provider Adapter
        ↓
Model Provider
```

------------------------------------------------------------------------

## 5. Initial Provider

O provider inicial será:

``` text
OpenAI
```

via chave configurada pelo Tenant quando o recurso exigir BYOK.

A arquitetura não assume OpenAI como único provider permanente.

------------------------------------------------------------------------

## 6. Future Providers

O Gateway deve permitir adapters futuros para, por exemplo:

-   Anthropic;
-   Google;
-   OpenRouter;
-   xAI;
-   DeepSeek;
-   private/local models.

Adicionar provider exige implementação e validação explícitas.

------------------------------------------------------------------------

## 7. BYOK

Cada Tenant poderá possuir sua própria configuração de IA.

Conceitualmente:

``` text
Tenant
  ↓
AI Configuration
  ↓
Provider
  ↓
Credential Reference
  ↓
Allowed Models / Policies
```

------------------------------------------------------------------------

## 8. Key Ownership

BYOK significa que o Tenant fornece a credential utilizada para chamadas
associadas ao seu contexto.

Uma chave de Tenant A nunca pode ser usada para Tenant B.

------------------------------------------------------------------------

## 9. Secret Storage

API keys são secrets.

Requisitos:

-   encrypted storage apropriado;
-   server-side access only;
-   nunca retornar chave completa ao browser;
-   nunca registrar em logs;
-   nunca incluir em prompts;
-   nunca incluir em event payloads.

A implementação física de secret storage pode receber ADR específico se
necessário.

------------------------------------------------------------------------

## 10. Credential Display

Após configuração, UI deve mostrar apenas informação segura, como:

``` text
Configured
Provider: OpenAI
Key: ••••••••abcd
```

quando apropriado.

------------------------------------------------------------------------

## 11. Credential Validation

Ao configurar uma chave, o sistema pode validar sua usabilidade de forma
controlada.

Falha de validação não deve expor detalhes sensíveis.

------------------------------------------------------------------------

## 12. Tenant AI Configuration

Configurações podem incluir:

-   provider;
-   enabled/disabled;
-   allowed models;
-   default model;
-   use-case routing;
-   spending limits futuros;
-   feature policies;
-   credential reference.

------------------------------------------------------------------------

## 13. AI Gateway Responsibility

O AI Gateway centraliza:

-   provider selection;
-   model selection;
-   request normalization;
-   response normalization;
-   timeout;
-   retry policy;
-   telemetry;
-   cost metadata;
-   safety controls;
-   error mapping.

------------------------------------------------------------------------

## 14. Gateway Is Not Business Logic

O Gateway não decide regras como:

``` text
Can this PMO view Financial data?
```

Authorization ocorre antes da chamada.

------------------------------------------------------------------------

## 15. Provider Adapter

Cada provider implementa contrato comum.

Exemplo conceitual:

``` text
generate()
stream()
embed()
```

somente para capacidades efetivamente suportadas.

------------------------------------------------------------------------

## 16. Capability Discovery

Não assumir que todos os providers suportam as mesmas features.

O Gateway deve trabalhar com capabilities explícitas.

------------------------------------------------------------------------

## 17. Model Routing

Diferentes tarefas podem utilizar diferentes modelos.

Exemplo:

``` text
Simple Classification
→ economical model

Executive Synthesis
→ stronger model

Embedding
→ embedding model
```

A estratégia concreta ficará configurável/evolutiva.

------------------------------------------------------------------------

## 18. Cost Principle

``` text
Use the least expensive model
that reliably satisfies the use case.
```

Não utilizar o modelo mais caro para todas as tarefas por padrão.

------------------------------------------------------------------------

## 19. Cost Attribution

Quando disponível, registrar metadata como:

-   Tenant;
-   feature/use case;
-   provider;
-   model;
-   input tokens;
-   output tokens;
-   estimated cost;
-   latency;
-   success/failure.

Sem registrar conteúdo sensível desnecessário.

------------------------------------------------------------------------

## 20. AI Context Boundary

Regra fundamental:

``` text
AI Context
≤
Authorized User Context
```

------------------------------------------------------------------------

## 21. Authorization Before Retrieval

Fluxo:

``` text
User Request
    ↓
Authenticate
    ↓
Resolve Tenant
    ↓
Authorize
    ↓
Build Allowed Context
    ↓
AI Gateway
```

------------------------------------------------------------------------

## 22. No Permission Expansion

LLM não pode solicitar internamente dados adicionais e receber acesso
além do usuário.

------------------------------------------------------------------------

## 23. Retrieval

Retrieval deve respeitar:

-   Tenant;
-   Scope;
-   Permission;
-   Data Policy;
-   classification;
-   workflow.

------------------------------------------------------------------------

## 24. Documents

Document retrieval respeita autorização do documento e classificação.

`documents.confidential.view` continua válido no contexto de IA.

------------------------------------------------------------------------

## 25. Financial Data

Copilot não recebe Financial data se usuário não possui
`financial.view`.

------------------------------------------------------------------------

## 26. Prompt Injection

Conteúdo recuperado deve ser tratado como dados não confiáveis.

Um documento pode conter instruções maliciosas como:

``` text
Ignore previous instructions...
```

Essas instruções não alteram autorização nem políticas do sistema.

------------------------------------------------------------------------

## 27. Trust Hierarchy

Conceitualmente:

``` text
System Policy
>
Application Policy
>
Authorized User Intent
>
Retrieved Content
```

------------------------------------------------------------------------

## 28. LLM Is Not Source of Truth

``` text
LLM Output
≠
Official Project State
```

Estado oficial vem das entidades de domínio e Snapshots.

------------------------------------------------------------------------

## 29. Facts vs Inference vs Recommendation

Respostas devem distinguir, quando relevante:

-   **Fact** --- sustentado por dados;
-   **Inference** --- interpretação;
-   **Recommendation** --- sugestão.

------------------------------------------------------------------------

## 30. Evidence

Para respostas executivas relevantes, Copilot deve apontar
evidências/origens quando possível.

------------------------------------------------------------------------

## 31. Official RAG

RAG oficial é calculado por regras determinísticas do sistema.

``` text
LLM
cannot silently set
Official RAG
```

------------------------------------------------------------------------

## 32. AI RAG Analysis

IA pode:

-   explicar;
-   questionar;
-   recomendar atenção;
-   sugerir possível override.

Mas mudança oficial segue `projects.{projectId}.rag-evaluations.override`.

------------------------------------------------------------------------

## 33. Read vs Write

MVP prioriza IA de:

``` text
Read
Analyze
Summarize
Recommend
Draft
```

antes de autonomia de escrita.

------------------------------------------------------------------------

## 34. Consequential Actions

Para alteração de estado relevante:

``` text
AI Proposal
      ↓
Human Review
      ↓
Explicit Confirmation
      ↓
Fresh Authorization
      ↓
Domain Validation
      ↓
Command
      ↓
Audit
```

------------------------------------------------------------------------

## 35. Human-in-the-Loop

IA não publica Status, muda baseline, aprova decisão ou altera RAG
silenciosamente.

------------------------------------------------------------------------

## 36. AI Autonomy

Evolução futura pode seguir níveis:

``` text
L0 — No AI
L1 — Assist
L2 — Recommend
L3 — Act with Confirmation
L4 — Bounded Autonomy
L5 — Higher Autonomy
```

MVP permanece principalmente em L1/L2, com L3 apenas onde explicitamente
projetado.

------------------------------------------------------------------------

## 37. Prompt Management

Prompts de sistema/aplicação devem ser versionáveis e não ficar
espalhados arbitrariamente pelo código.

------------------------------------------------------------------------

## 38. Prompt Version

Para operações importantes, registrar versão lógica do
prompt/configuração quando necessário para observabilidade.

------------------------------------------------------------------------

## 39. Structured Output

Quando resposta alimentar lógica de aplicação, preferir structured
output validado.

------------------------------------------------------------------------

## 40. Runtime Validation

TypeScript types não validam output em runtime.

Toda resposta estruturada deve ser validada antes de uso.

------------------------------------------------------------------------

## 41. Invalid Output

Se provider retornar estrutura inválida:

``` text
Reject / Retry safely / Degrade
```

Nunca persistir silenciosamente payload inválido.

------------------------------------------------------------------------

## 42. Hallucination

Mitigações:

-   grounded context;
-   explicit evidence;
-   bounded prompts;
-   structured output;
-   deterministic calculations outside LLM;
-   human review.

------------------------------------------------------------------------

## 43. Timeout

Toda chamada deve possuir timeout adequado.

Provider lento não deve bloquear indefinidamente o produto.

------------------------------------------------------------------------

## 44. Retry

Retry apenas quando seguro e apropriado.

Não repetir indiscriminadamente ações que possam gerar efeitos
duplicados.

------------------------------------------------------------------------

## 45. Rate Limit

Gateway deve normalizar/tratar rate-limit errors.

------------------------------------------------------------------------

## 46. Provider Failure

Se IA estiver indisponível:

``` text
Core PMO Control
remains operational
```

------------------------------------------------------------------------

## 47. Graceful Degradation

Exemplo:

``` text
Copilot unavailable
```

não impede:

-   Projects;
-   Risks;
-   Issues;
-   Actions;
-   Status;
-   Snapshots;
-   dashboards.

------------------------------------------------------------------------

## 48. Fallback Models

Fallback automático entre modelos/providers só deve ocorrer quando:

-   autorizado pela configuração do Tenant;
-   semanticamente seguro;
-   custo/política permitirem.

------------------------------------------------------------------------

## 49. No Silent Provider Switching

BYOK e políticas do Tenant devem ser respeitados.

Não enviar dados para provider diferente sem autorização/configuração.

------------------------------------------------------------------------

## 50. Background AI

Tarefas longas podem usar Inngest.

``` text
Request
 ↓
Authorized Context Reference
 ↓
Background Workflow
 ↓
Revalidate Context as needed
 ↓
AI Gateway
```

------------------------------------------------------------------------

## 51. Event Payload Security

Nunca enviar API key em evento Inngest.

Enviar referência segura/configuração identificadora.

------------------------------------------------------------------------

## 52. Data Retention

A política de retenção do provider deve ser considerada conforme
plano/configuração e requisitos do Tenant.

------------------------------------------------------------------------

## 53. Sensitive Data

Antes de enviar dados sensíveis ao provider, verificar:

-   autorização;
-   necessidade;
-   provider policy;
-   Tenant configuration;
-   classification.

------------------------------------------------------------------------

## 54. Data Minimization

Enviar somente o contexto necessário para responder à tarefa.

------------------------------------------------------------------------

## 55. Observability

Registrar metadata operacional:

-   request ID;
-   Tenant;
-   feature;
-   provider;
-   model;
-   latency;
-   token usage;
-   result status;
-   error class.

------------------------------------------------------------------------

## 56. Content Logging

Prompt/resposta completos não devem ser logados indiscriminadamente.

Quando logging de conteúdo for necessário para debugging/evaluation,
precisa de política específica e proteção.

------------------------------------------------------------------------

## 57. Audit

Ações consequenciais originadas por IA devem registrar:

-   AI suggestion/proposal;
-   human actor;
-   confirmation;
-   final command;
-   result.

------------------------------------------------------------------------

## 58. Evaluation

Casos de uso de IA devem possuir avaliações próprias.

Exemplos:

-   factuality;
-   relevance;
-   grounding;
-   authorization leakage;
-   structured output validity;
-   executive usefulness.

------------------------------------------------------------------------

## 59. Security Evaluation

Testes devem incluir:

-   cross-tenant prompt;
-   prompt injection;
-   unauthorized Financial request;
-   confidential Document request;
-   malicious retrieved content;
-   tool/action escalation.

------------------------------------------------------------------------

## 60. Option A --- Direct Provider Calls Everywhere

### Vantagens

-   implementação inicial rápida.

### Desvantagens

-   provider coupling;
-   credentials espalhadas;
-   pouca observabilidade;
-   difícil governança;
-   model routing inconsistente.

### Resultado

**Rejected.**

------------------------------------------------------------------------

## 61. Option B --- Single Global Platform Key

### Vantagens

-   simples.

### Desvantagens

-   custo centralizado;
-   baixa separação entre Tenants;
-   limita BYOK;
-   governança comercial pior.

### Resultado

**Rejected as primary model.**

------------------------------------------------------------------------

## 62. Option C --- AI Gateway + Tenant BYOK

### Vantagens

-   isolamento;
-   portabilidade;
-   governança;
-   observabilidade;
-   model routing;
-   evolução multi-provider.

### Desvantagens

-   maior implementação inicial;
-   secret management;
-   provider abstraction;
-   configuração por Tenant.

### Resultado

**Accepted.**

------------------------------------------------------------------------

## 63. BYOK Failure

Se chave do Tenant:

-   expirar;
-   for revogada;
-   ficar sem quota;
-   for inválida;

apenas recursos dependentes daquela configuração devem degradar.

------------------------------------------------------------------------

## 64. Configuration Status

Estados possíveis:

``` text
Not Configured
Configured
Validation Failed
Disabled
```

A modelagem final será definida na Spec de Settings/AI.

------------------------------------------------------------------------

## 65. Provider Lock-in Mitigation

-   internal Gateway;
-   provider adapters;
-   normalized contracts;
-   prompt isolation;
-   model capability abstraction;
-   business logic outside SDK.

------------------------------------------------------------------------

## 66. Abstraction Limit

Não criar "lowest common denominator" artificial.

Capabilities provider-specific podem existir atrás de interfaces
explícitas quando gerarem valor.

------------------------------------------------------------------------

## 67. Future Embeddings

Embeddings também devem passar pelo Gateway/configuração apropriada.

Provider de embeddings pode ser diferente do provider de geração.

------------------------------------------------------------------------

## 68. Future RAG

RAG deve respeitar:

``` text
Authorization before Retrieval
```

não apenas filtrar resultados depois da busca.

------------------------------------------------------------------------

## 69. Future Agents

Agentes futuros continuam sujeitos ao mesmo Authorization Model.

``` text
Agent Authority
≤
Delegated Human/System Authority
```

------------------------------------------------------------------------

## 70. Tool Use

Ferramentas acessíveis a agentes devem possuir:

-   explicit contract;
-   authorization;
-   input validation;
-   confirmation policy;
-   Audit;
-   bounded scope.

------------------------------------------------------------------------

## 71. Kill Switch

Tenant/Admin deve poder desabilitar recursos de IA conforme
configuração.

------------------------------------------------------------------------

## 72. Feature Flags

Recursos experimentais de IA podem ser controlados por feature
flag/configuração.

------------------------------------------------------------------------

## 73. Cost Controls

Evolução pode incluir:

-   monthly budget;
-   per-feature limits;
-   per-model limits;
-   usage alerts;
-   quotas.

------------------------------------------------------------------------

## 74. Testing

Cobrir:

-   provider success;
-   invalid credential;
-   timeout;
-   rate limit;
-   malformed response;
-   unauthorized context;
-   cross-tenant isolation;
-   prompt injection;
-   fallback rules;
-   structured output validation;
-   background execution.

------------------------------------------------------------------------

## 75. Revisit Triggers

Reavaliar se:

1.  BYOK deixar de atender modelo comercial;
2.  enterprise customers exigirem private inference;
3.  provider routing se tornar muito complexo;
4.  volume justificar gateway dedicado externo;
5.  compliance exigir arquitetura regional;
6.  local/private models se tornarem requisito;
7.  agents exigirem policy runtime mais sofisticado.

------------------------------------------------------------------------

## 76. Non-Triggers

Não adicionar novos providers apenas porque:

-   são populares;
-   possuem benchmark superior;
-   aparecem em tendências.

Adicionar quando houver:

``` text
Use Case
+
Business Value
+
Security Review
+
Operational Support
```

------------------------------------------------------------------------

## 77. Architecture Invariants

1.  IA não é source of truth.
2.  AI Context nunca excede acesso efetivo.
3.  BYOK é isolado por Tenant.
4.  Secrets permanecem server-side.
5.  Gateway centraliza provider access.
6.  Official RAG não é decidido silenciosamente por LLM.
7.  Consequential actions exigem controle humano conforme política.
8.  Structured output é validado em runtime.
9.  Provider failure não derruba o core.
10. Dados são minimizados antes do envio.
11. Provider switching não ocorre contra configuração do Tenant.
12. AI actions respeitam Audit.
13. Retrieved content é untrusted.
14. Agents futuros não ampliam autoridade.

------------------------------------------------------------------------

## 78. Relationship with ADR-006

Authorization Model define o máximo de contexto permitido à IA.

------------------------------------------------------------------------

## 79. Relationship with ADR-008

Tarefas longas de IA podem executar via Inngest sem incluir secrets nos
eventos.

------------------------------------------------------------------------

## 80. Relationship with ADR-010

Providers de IA utilizam Adapter Pattern especializado através do AI
Gateway.

------------------------------------------------------------------------

## 81. References

-   `/docs/00-foundation/permission-model.md`
-   `/docs/00-foundation/data-classification.md`
-   `/docs/02-architecture/ai-architecture.md`
-   `/docs/02-architecture/security-architecture.md`
-   `/docs/03-adrs/006-authorization-model.md`
-   `/docs/03-adrs/008-inngest-background-workflows.md`
-   `/docs/04-specs/025-pmo-copilot/`
-   `/docs/04-specs/029-settings/`

------------------------------------------------------------------------

## 82. Decision Summary

``` text
Decision:
Centralize all AI provider access through an internal
AI Gateway and use Tenant-scoped BYOK.

Initial Provider:
OpenAI

Architecture:
Authorized Context
→ AI Policy
→ AI Gateway
→ Provider Adapter
→ Model

Core Rule:
AI Context ≤ Authorized User Context

Why:
This provides security, provider portability,
cost visibility and a controlled path toward
multi-model AI and future agents.

Revisit:
When commercial, compliance, scale or private-model
requirements justify a different AI infrastructure.
```

------------------------------------------------------------------------

**ADR:** ADR-009\
**Status:** Accepted

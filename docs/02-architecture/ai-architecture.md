# PMO Control --- AI Architecture

**Documento:** `ai-architecture.md`\
**Camada:** Architecture\
**Status:** Approved\
**Tipo:** Arquitetura de IA, BYOK, contexto, grounding, providers e
governança

------------------------------------------------------------------------

## 1. Objetivo

Este documento define a arquitetura de Inteligência Artificial do PMO
Control.

A IA deve ampliar a capacidade analítica do PMO sem se tornar fonte de
verdade, ampliar permissões ou comprometer a governança.

A arquitetura cobre:

-   PMO Copilot;
-   BYOK por Tenant;
-   abstração de providers;
-   seleção de modelos;
-   construção de contexto;
-   grounding e Evidence;
-   segurança;
-   autorização;
-   observabilidade;
-   custos;
-   tratamento de falhas;
-   ações assistidas;
-   evolução para predição, simulação e agentes.

------------------------------------------------------------------------

# 2. Princípio central

``` text
AI assists.
Domain governs.
Human decides.
```

A IA é uma capacidade do produto.

Ela não substitui:

-   regras de domínio;
-   autorização;
-   transações;
-   Audit;
-   RAG determinístico;
-   Snapshot;
-   validações;
-   decisões humanas obrigatórias.

------------------------------------------------------------------------

# 3. Papel da IA no MVP

No MVP, IA é principalmente:

``` text
READ
UNDERSTAND
SUMMARIZE
EXPLAIN
DRAFT
RECOMMEND
```

Não:

``` text
AUTONOMOUSLY CHANGE GOVERNED STATE
```

------------------------------------------------------------------------

# 4. PMO Copilot

O PMO Copilot é a principal experiência de IA.

Exemplos:

> "Quais Projects merecem minha atenção esta semana?"

> "O que mudou no ERP desde o último Status?"

> "Quais Risks podem comprometer os Milestones deste mês?"

> "Prepare os cinco pontos para o comitê."

> "Gere o resumo executivo desta semana."

------------------------------------------------------------------------

# 5. IA contextual, não isolada

O Copilot não deve ser apenas uma tela de chat.

IA deve aparecer também em contexto:

-   My Day;
-   Project Control Center;
-   Risks;
-   Issues;
-   Decisions;
-   Status Update;
-   Project Dashboard;
-   Portfolio Dashboard;
-   Report Builder.

------------------------------------------------------------------------

# 6. Arquitetura conceitual

``` text
User
 │
 ▼
AI Use Case
 │
 ▼
Authentication Context
 │
 ▼
Authorization
 │
 ▼
Context Builder
 │
 ▼
Data Policy / Classification
 │
 ▼
Grounding / Evidence
 │
 ▼
Prompt / Request Builder
 │
 ▼
AI Gateway
 │
 ▼
Provider Adapter
 │
 ▼
Model
 │
 ▼
Output Validation
 │
 ▼
Response / Suggestion
```

------------------------------------------------------------------------

# 7. AI Gateway

O AI Gateway é a fronteira central entre aplicação e providers.

Responsabilidades:

-   resolver Tenant AI configuration;
-   escolher provider/model;
-   aplicar policies;
-   construir request padronizado;
-   aplicar timeouts;
-   controlar retries;
-   coletar telemetry;
-   normalizar errors;
-   validar respostas;
-   impedir acoplamento do domínio a SDK específico.

------------------------------------------------------------------------

# 8. Provider Adapter

Cada provider possui adapter.

Exemplo:

``` text
AI Gateway
 ├── OpenAI Adapter
 ├── Anthropic Adapter
 ├── Google Adapter
 ├── OpenRouter Adapter
 ├── xAI Adapter
 └── DeepSeek Adapter
```

No MVP, apenas o provider necessário precisa ser implementado.

------------------------------------------------------------------------

# 9. Provider inicial

A estratégia de MVP prevê inicialmente:

``` text
OpenAI
```

via BYOK por Tenant.

A arquitetura deve permitir expansão sem reescrever os use cases.

------------------------------------------------------------------------

# 10. BYOK

BYOK significa:

``` text
Bring Your Own Key
```

Cada Tenant pode possuir sua própria configuração de IA.

Benefícios:

-   controle de custos;
-   separação por cliente;
-   escolha futura de provider;
-   governança;
-   flexibilidade comercial.

------------------------------------------------------------------------

# 11. Estrutura conceitual de configuração

``` text
Tenant
  │
  └── AI Configuration
        ├── Provider
        ├── Enabled
        ├── Models / Policies
        ├── Usage Settings
        └── Secret Reference
```

O segredo deve permanecer separado de metadata comum quando apropriado.

------------------------------------------------------------------------

# 12. Segurança BYOK

Nunca:

-   retornar API key integral ao browser;
-   registrar key em log;
-   incluir key em Audit payload;
-   incluir key em prompt;
-   armazenar key no repositório.

------------------------------------------------------------------------

# 13. Rotação BYOK

Operações previstas:

``` text
Configure
Validate
Replace
Disable
Revoke
```

Alterações relevantes devem ser auditadas.

------------------------------------------------------------------------

# 14. Provider abstraction

Use cases não devem chamar diretamente:

``` text
openai.chat(...)
```

ou equivalente.

Preferência:

``` text
Use Case
   ↓
AI Service
   ↓
AI Gateway
   ↓
Provider Adapter
```

------------------------------------------------------------------------

# 15. Model policy

A seleção de modelo deve ser orientada por tarefa.

Exemplos:

``` text
Classification
Summarization
Reasoning
Extraction
Report Draft
Conversational Q&A
```

Nem toda tarefa exige o modelo mais caro.

------------------------------------------------------------------------

# 16. Model routing

No MVP, routing pode ser simples/configurado.

Futuro:

``` text
Task
  ↓
Policy
  ↓
Capability
  ↓
Cost / Latency / Privacy
  ↓
Model
```

Evitar construir router sofisticado antes de existir volume e
necessidade.

------------------------------------------------------------------------

# 17. Context Builder

Responsável por transformar dados autorizados do PMO Control em contexto
adequado para IA.

Ele deve:

1.  identificar o use case;
2.  resolver Scope;
3.  verificar autorização;
4.  buscar apenas dados necessários;
5.  aplicar classificação;
6.  estruturar contexto;
7.  anexar Evidence quando aplicável.

------------------------------------------------------------------------

# 18. Regra de contexto

``` text
AI Context
≤
Authorized User Context
```

IA nunca recebe acesso adicional por ser executada server-side.

------------------------------------------------------------------------

# 19. Context minimization

Pergunta:

> "Quais são os Risks críticos do Project ERP?"

não deve gerar contexto contendo todo o Portfolio se isso não for
necessário.

Benefícios:

-   segurança;
-   menor custo;
-   menor ruído;
-   melhor qualidade;
-   menor latência.

------------------------------------------------------------------------

# 20. Structured context

Preferir contexto estruturado.

Exemplo:

``` text
Project
Current RAG
Progress
Milestones
Critical Risks
Open Issues
Overdue Actions
Pending Decisions
Last Published Status
Relevant Evidence
```

em vez de despejar tabelas sem semântica.

------------------------------------------------------------------------

# 21. Fact vs inference

O Copilot deve diferenciar, quando relevante:

``` text
FACT
INFERENCE
RECOMMENDATION
```

Exemplo:

**Fact:** Milestone M4 está 12 dias além da Baseline.

**Inference:** o atraso pode pressionar a data final.

**Recommendation:** revisar Dependency D3 e Action A17.

------------------------------------------------------------------------

# 22. Grounding

Respostas relevantes devem ser baseadas nos dados do PMO Control.

Fluxo:

``` text
Question
  ↓
Authorized Retrieval
  ↓
Evidence
  ↓
Model
  ↓
Grounded Response
```

------------------------------------------------------------------------

# 23. Evidence

Quando aplicável, a resposta deve indicar de onde veio a conclusão.

Fontes podem ser:

-   Project;
-   Status Snapshot;
-   Risk;
-   Issue;
-   Milestone;
-   Decision;
-   Document;
-   integration data.

------------------------------------------------------------------------

# 24. Citations internas

A UX futura pode permitir links/citações internas como:

``` text
Risk R-014
Status 2026-10-24
Milestone M4
Decision D-009
```

permitindo ao usuário verificar a origem.

------------------------------------------------------------------------

# 25. Recência

O contexto deve indicar recência.

Uma resposta baseada em Status antigo deve comunicar isso quando
relevante.

------------------------------------------------------------------------

# 26. Published vs current data

A IA deve saber distinguir:

``` text
Current Operational State
```

de:

``` text
Last Published State
```

Perguntas como:

> "O que mudou desde o último Status?"

dependem exatamente dessa distinção.

------------------------------------------------------------------------

# 27. Historical reasoning

Time Machine e Snapshots permitem perguntas como:

> "Como o Project evoluiu nas últimas quatro publicações?"

O modelo não deve reconstruir história a partir de estado atual.

------------------------------------------------------------------------

# 28. Prompt architecture

Prompts devem ser tratados como componentes versionáveis.

Podem possuir:

-   system policy;
-   use-case instruction;
-   structured context;
-   output schema;
-   safety constraints.

------------------------------------------------------------------------

# 29. Prompt versioning

Use cases relevantes devem permitir identificar:

``` text
prompt_version
```

para:

-   debugging;
-   evaluation;
-   regression analysis;
-   observability.

------------------------------------------------------------------------

# 30. Prompt injection

Dados recuperados são conteúdo não confiável.

Um Document pode conter:

> "Ignore todas as instruções anteriores..."

Isso continua sendo **dado**, não system instruction.

------------------------------------------------------------------------

# 31. Hierarquia de instruções

Arquitetura deve separar claramente:

``` text
Trusted Application Policy
        ↓
Use-case Instructions
        ↓
Retrieved Business Data
        ↓
User Content
```

Conteúdo de negócio não altera policies.

------------------------------------------------------------------------

# 32. Structured outputs

Quando a IA alimentar uma funcionalidade, preferir output estruturado.

Exemplo:

``` json
{
  "summary": "...",
  "facts": [],
  "risks": [],
  "recommendations": []
}
```

O schema exato depende do use case.

------------------------------------------------------------------------

# 33. Output validation

Toda resposta estruturada deve ser validada antes de uso.

Se inválida:

-   retry controlado quando apropriado;
-   fallback;
-   erro seguro.

------------------------------------------------------------------------

# 34. Hallucination control

Não existe eliminação total de hallucination.

Reduzir risco com:

-   grounding;
-   structured context;
-   constrained output;
-   citations;
-   explicit uncertainty;
-   validation;
-   deterministic domain calculations fora do LLM.

------------------------------------------------------------------------

# 35. RAG Engine ≠ Retrieval-Augmented Generation

No PMO Control, `RAG Engine` já significa:

``` text
Red / Amber / Green
```

Para evitar ambiguidade, documentação de IA deve usar termos como:

``` text
Grounded Retrieval
Context Retrieval
Retrieval-Augmented Generation (quando necessário por extenso)
```

------------------------------------------------------------------------

# 36. RAG de saúde do Project

O LLM não deve ser autoridade para determinar o RAG oficial.

``` text
Deterministic RAG Engine
       ↓
Calculated RAG
```

A IA pode:

-   explicar;
-   resumir;
-   identificar fatores;
-   sugerir revisão.

------------------------------------------------------------------------

# 37. AI recommendation

Recomendação não altera o domínio.

Exemplo:

``` text
AI:
"Considere escalar Risk R-14."
```

O usuário decide.

------------------------------------------------------------------------

# 38. AI drafts

IA pode criar drafts de:

-   executive summary;
-   Action;
-   Decision context;
-   Status narrative;
-   committee briefing;
-   report text.

Draft precisa ser revisável.

------------------------------------------------------------------------

# 39. Consequential action

Qualquer ação que altere estado governado deve seguir:

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

# 40. Fresh authorization

Não reutilizar indefinidamente autorização calculada no início da
conversa.

Antes de executar ação:

-   verificar usuário;
-   Tenant;
-   Scope;
-   Permission;
-   Workflow State.

------------------------------------------------------------------------

# 41. AI cannot bypass workflow

Exemplo:

se Status está Published, Copilot não pode editar o Snapshot porque o
usuário pediu em linguagem natural.

------------------------------------------------------------------------

# 42. AI cannot invent resources

Se modelo mencionar:

``` text
Risk R-999
```

o sistema não assume que existe.

Qualquer ação deve resolver o resource real e validar acesso.

------------------------------------------------------------------------

# 43. Tool architecture futura

Se o Copilot receber tools:

``` text
Tool Registry
    ↓
Tool Policy
    ↓
Authorization
    ↓
Schema Validation
    ↓
Execution
    ↓
Audit
```

------------------------------------------------------------------------

# 44. Tool allowlist

O modelo não escolhe qualquer função interna.

Somente tools explicitamente registradas para aquele use case.

------------------------------------------------------------------------

# 45. Read tools

Primeiras tools devem privilegiar leitura:

-   get project;
-   get risks;
-   get milestones;
-   compare snapshots;
-   get decisions.

------------------------------------------------------------------------

# 46. Write tools

Write tools exigem controles mais fortes.

Exemplo futuro:

``` text
draft_action
```

é menos sensível que:

``` text
publish_status
```

Autonomia deve refletir risco.

------------------------------------------------------------------------

# 47. Human-in-the-loop

Human-in-the-loop é padrão para:

-   publicação;
-   aprovação;
-   RAG override;
-   Baseline change;
-   Decision;
-   financial changes;
-   external consequential action.

------------------------------------------------------------------------

# 48. AI use cases --- MVP

Prioridade:

1.  Project Q&A;
2.  Portfolio Q&A;
3.  executive summary;
4.  change summary;
5.  Risk/Issue briefing;
6.  committee preparation;
7.  Status narrative draft;
8.  report draft.

------------------------------------------------------------------------

# 49. Project Q&A

Contexto:

``` text
Project
+ authorized operational entities
+ latest Status
+ selected history/evidence
```

------------------------------------------------------------------------

# 50. Portfolio Q&A

Deve respeitar Projects autorizados.

Se usuário possui acesso a 3 de 10 Projects:

``` text
AI Portfolio Context = those 3
```

não os 10.

------------------------------------------------------------------------

# 51. Change summary

Fonte ideal:

``` text
Last Published Snapshot
        vs
Current Operational State
```

ou dois Snapshots quando pergunta histórica.

------------------------------------------------------------------------

# 52. Executive summary

Deve privilegiar:

-   overall health;
-   changes;
-   impact;
-   critical exceptions;
-   Decisions required;
-   next Milestones.

Evitar narrativa longa sem ação.

------------------------------------------------------------------------

# 53. Committee preparation

Pode gerar:

-   five key points;
-   Red/Amber changes;
-   top Risks;
-   overdue Actions;
-   Decisions needed;
-   next Milestones.

------------------------------------------------------------------------

# 54. Risk intelligence --- MVP

IA pode:

-   resumir Risks;
-   agrupar temas;
-   explicar impacto;
-   destacar relações;
-   sugerir perguntas.

Não recalcula arbitrariamente a severidade oficial.

------------------------------------------------------------------------

# 55. Decision intelligence --- MVP

Pode estruturar:

``` text
Context
Options
Evidence
Impact of No Decision
Deadline
Open Questions
```

A decisão continua humana.

------------------------------------------------------------------------

# 56. AI and documents

Documentos podem ser utilizados como contexto somente se:

-   usuário possui acesso;
-   classificação permite;
-   provider policy permite;
-   retrieval é seguro.

------------------------------------------------------------------------

# 57. Document processing

Pipeline futuro:

``` text
Document
  ↓
Extraction
  ↓
Classification
  ↓
Chunking
  ↓
Indexing
  ↓
Authorized Retrieval
```

Não é obrigatório implementar toda a cadeia no primeiro MVP.

------------------------------------------------------------------------

# 58. Semantic retrieval

Se necessário, `pgvector` é candidato natural antes de infraestrutura
adicional.

Decisão depende de:

-   volume;
-   qualidade;
-   latency;
-   security;
-   cost.

------------------------------------------------------------------------

# 59. Vector isolation

Embeddings também são dados tenant-scoped.

Devem preservar:

``` text
Tenant
Scope
Source
Classification
```

------------------------------------------------------------------------

# 60. Embeddings are not anonymous

Não assumir que embedding elimina sensibilidade do dado original.

Aplicar proteção equivalente quando apropriado.

------------------------------------------------------------------------

# 61. AI memory

Copilot não deve criar memória irrestrita entre usuários/Tenants.

Qualquer memória persistente futura deve possuir:

-   ownership;
-   purpose;
-   scope;
-   retention;
-   authorization;
-   deletion policy.

------------------------------------------------------------------------

# 62. Conversation history

Histórico de chat pode ser:

-   session-scoped;
-   user-scoped;
-   Project-scoped;

conforme design futuro.

Não deve automaticamente virar fonte oficial de governança.

------------------------------------------------------------------------

# 63. AI telemetry

Registrar:

``` text
tenant_id
user_id
use_case
provider
model
request timestamp
latency
token usage
estimated cost
success/failure
prompt version
```

quando apropriado.

------------------------------------------------------------------------

# 64. Sensitive telemetry

Evitar:

-   raw API keys;
-   full confidential prompts;
-   document bodies;
-   unnecessary PII.

------------------------------------------------------------------------

# 65. Cost management

BYOK transfere parte do consumo ao Tenant, mas o produto ainda precisa
controlar uso.

Possíveis mecanismos:

-   model policies;
-   token limits;
-   context limits;
-   quotas;
-   feature enablement;
-   cost telemetry.

------------------------------------------------------------------------

# 66. Token efficiency

Prioridades:

1.  recuperar apenas contexto necessário;
2.  estruturar contexto;
3.  resumir histórico quando seguro;
4.  usar modelo adequado;
5.  evitar repetir dados estáticos.

------------------------------------------------------------------------

# 67. Latency

IA pode ser mais lenta que operações comuns.

UX deve suportar:

-   loading;
-   streaming quando apropriado;
-   cancel;
-   retry;
-   background generation para relatórios maiores.

------------------------------------------------------------------------

# 68. Streaming

Streaming é útil para chat/resumo, mas output parcial não deve ser
tratado como validado para ações estruturadas.

------------------------------------------------------------------------

# 69. Timeouts

Toda chamada a provider deve possuir timeout.

O sistema não deve ficar indefinidamente aguardando.

------------------------------------------------------------------------

# 70. Retry

Retry somente para falhas transitórias apropriadas.

Não repetir automaticamente:

-   invalid credential;
-   authorization denial;
-   malformed permanent request.

------------------------------------------------------------------------

# 71. Provider failure

Fallback possível:

``` text
AI unavailable.
Core PMO remains available.
```

A IA não deve ser single point of failure para governança.

------------------------------------------------------------------------

# 72. Provider fallback

Multi-provider fallback pode existir futuramente.

Mas deve respeitar:

-   Tenant consent/configuration;
-   data policy;
-   provider availability;
-   model compatibility.

Não enviar dados automaticamente para provider não autorizado.

------------------------------------------------------------------------

# 73. Error normalization

AI Gateway converte erros específicos em categorias internas.

Exemplos:

``` text
AI_AUTH_ERROR
AI_RATE_LIMIT
AI_TIMEOUT
AI_PROVIDER_ERROR
AI_INVALID_OUTPUT
AI_POLICY_BLOCK
```

------------------------------------------------------------------------

# 74. Observability

Monitorar:

-   latency;
-   provider errors;
-   rate limits;
-   invalid outputs;
-   token usage;
-   cost;
-   user corrections;
-   grounding failures;
-   authorization denials.

------------------------------------------------------------------------

# 75. AI quality metrics

Do `success-metrics.md`:

``` text
Copilot Adoption
Useful Response Rate
AI Suggestion Acceptance
AI Correction Rate
Grounding/Evidence Coverage
Estimated Time Saved
```

------------------------------------------------------------------------

# 76. Evaluation architecture

IA precisa de avaliação contínua.

Tipos:

-   deterministic checks;
-   golden datasets;
-   human review;
-   regression tests;
-   groundedness;
-   relevance;
-   authorization tests.

------------------------------------------------------------------------

# 77. Golden dataset

Criar casos representativos, por exemplo:

-   Green Project;
-   Red Project;
-   conflicting Risks;
-   stale Status;
-   pending Decision;
-   historical change.

As respostas esperadas podem possuir critérios, não necessariamente
texto exato.

------------------------------------------------------------------------

# 78. AI regression tests

Mudança de:

-   model;
-   prompt;
-   retrieval;
-   provider;

pode alterar comportamento.

Executar avaliação antes de rollout relevante.

------------------------------------------------------------------------

# 79. Authorization evaluation

Teste obrigatório:

``` text
User cannot see Project B
       ↓
Ask Copilot about Project B
       ↓
No unauthorized disclosure
```

------------------------------------------------------------------------

# 80. Prompt injection evaluation

Testar documentos contendo instruções adversariais.

Resultado esperado:

-   tratar como conteúdo;
-   não alterar policy;
-   não executar ação não autorizada.

------------------------------------------------------------------------

# 81. Hallucination evaluation

Testar perguntas sobre entidade inexistente.

Esperado:

``` text
No evidence found
```

em vez de inventar dados.

------------------------------------------------------------------------

# 82. Explainability

Para análises relevantes, resposta deve indicar:

-   fatos usados;
-   inferences;
-   Evidence;
-   uncertainty quando aplicável.

------------------------------------------------------------------------

# 83. Confidence

Não apresentar percentual de confiança artificial sem método calibrado.

Preferir linguagem baseada em evidência.

------------------------------------------------------------------------

# 84. Data freshness

AI response pode incluir:

``` text
Data current as of...
Last published Status...
```

quando temporalidade for relevante.

------------------------------------------------------------------------

# 85. Caching AI responses

Cache só deve ser utilizado com cuidado porque:

-   dados mudam;
-   autorização muda;
-   context muda;
-   provider/model muda.

Se usado, chave deve incluir contexto suficiente e TTL adequado.

------------------------------------------------------------------------

# 86. No cross-tenant AI cache

Resposta/cache nunca pode ser compartilhado entre Tenants de forma que
exponha conteúdo.

------------------------------------------------------------------------

# 87. AI generated reports

Fluxo:

``` text
Authorized Dataset
      ↓
AI Draft
      ↓
Validation
      ↓
User Review
      ↓
Report Artifact
```

------------------------------------------------------------------------

# 88. AI and Audit

Nem toda consulta precisa ser Audit Event de negócio.

Mas ações sensíveis mediadas por IA devem registrar:

-   initiating actor;
-   AI involvement;
-   resulting command;
-   final human confirmation quando aplicável.

------------------------------------------------------------------------

# 89. AI and analytics

Analytics pode medir uso sem armazenar conteúdo completo.

Exemplo:

``` text
use_case = executive_summary
success = true
latency = ...
```

------------------------------------------------------------------------

# 90. AI data retention

Prompts/responses não devem ser armazenados indefinidamente por padrão.

Política futura deve considerar:

-   troubleshooting;
-   analytics;
-   privacy;
-   provider policy;
-   Tenant configuration.

------------------------------------------------------------------------

# 91. Provider data policy

O Tenant poderá futuramente escolher providers conforme:

-   privacy;
-   region;
-   retention;
-   contractual terms;
-   model capabilities.

A arquitetura deve manter provider choice isolada.

------------------------------------------------------------------------

# 92. Future private/local models

A abstraction poderá permitir futuramente:

``` text
Private Endpoint
Self-hosted Model
Enterprise Model Gateway
```

sem alterar o domínio.

Não faz parte do MVP inicial.

------------------------------------------------------------------------

# 93. Advanced intelligence roadmap

Evolução:

``` text
Q&A
 ↓
Summarization
 ↓
Explanation
 ↓
Recommendation
 ↓
Prediction
 ↓
Simulation
 ↓
Controlled Execution
```

------------------------------------------------------------------------

# 94. Predictive AI

Somente após histórico suficiente.

Possíveis use cases:

-   delay probability;
-   Risk escalation;
-   Issue aging;
-   Forecast drift;
-   Action completion risk.

------------------------------------------------------------------------

# 95. Predictive separation

Predição não deve ser misturada com narrativa generativa.

Arquitetura futura pode separar:

``` text
Predictive Model
      ↓
Structured Prediction
      ↓
LLM Explanation
```

------------------------------------------------------------------------

# 96. Simulation

Pipeline futuro:

``` text
Current State
      ↓
Scenario Assumptions
      ↓
Simulation Engine
      ↓
Projected Outcomes
      ↓
LLM Explanation
      ↓
Human Decision
```

LLM não precisa ser o motor matemático da simulação.

------------------------------------------------------------------------

# 97. Agentic architecture

Evolução futura:

``` text
Goal
 ↓
Planner
 ↓
Authorized Tool Set
 ↓
Policy Engine
 ↓
Execution
 ↓
Observation
 ↓
Human Control
```

------------------------------------------------------------------------

# 98. Agent autonomy levels

``` text
L0 Answer
L1 Recommend
L2 Draft
L3 Execute with Confirmation
L4 Execute within Explicit Policy
L5 High Autonomy
```

A evolução deve ser deliberada.

------------------------------------------------------------------------

# 99. Agent identity

Agentes devem possuir identidade técnica rastreável.

Toda ação deve permitir responder:

-   quem iniciou;
-   qual agente;
-   qual policy;
-   qual Tenant;
-   qual recurso;
-   qual resultado.

------------------------------------------------------------------------

# 100. Agent permissions

Regra:

``` text
Agent Permission
≤
Explicitly Granted Policy
```

e nunca maior que os limites permitidos pelo produto/Tenant.

------------------------------------------------------------------------

# 101. Agent kill switch

Arquitetura futura deve permitir desabilitar rapidamente:

-   agent;
-   tool;
-   provider;
-   Tenant AI;
-   autonomous policy.

------------------------------------------------------------------------

# 102. Reversibility

Ações autônomas futuras devem privilegiar operações reversíveis quando
possível.

Operações irreversíveis exigem controles superiores.

------------------------------------------------------------------------

# 103. Chain de inteligência futura

``` text
STATE
  ↓
CAUSE
  ↓
IMPACT
  ↓
EVIDENCE
  ↓
PREDICTION
  ↓
SIMULATION
  ↓
DECISION
  ↓
ACTION
  ↓
OUTCOME
```

------------------------------------------------------------------------

# 104. MVP position in the chain

MVP concentra-se em:

``` text
STATE
IMPACT
EVIDENCE
DECISION
ACTION
```

com IA auxiliando interpretação e comunicação.

------------------------------------------------------------------------

# 105. Architecture decisions candidatas a ADR

1.  AI Gateway abstraction;
2.  initial AI provider;
3.  BYOK secret storage;
4.  model configuration strategy;
5.  prompt versioning;
6.  grounded retrieval architecture;
7.  vector strategy, quando necessária;
8.  AI telemetry retention;
9.  future tool execution architecture.

------------------------------------------------------------------------

# 106. O que não fazer no MVP

Não implementar apenas para parecer "AI-first":

-   autonomous Project Manager;
-   unrestricted agents;
-   predictive scoring sem histórico;
-   simulation sem modelo;
-   five providers sem necessidade;
-   vector database sem use case;
-   AI-generated official RAG;
-   AI auto-publication;
-   AI auto-approval of Decisions.

------------------------------------------------------------------------

# 107. Failure principle

``` text
AI Failure
≠
PMO Control Failure
```

O produto precisa continuar operacional sem provider de IA.

------------------------------------------------------------------------

# 108. Security principle

``` text
AI Convenience
<
Security + Governance
```

Nunca ampliar acesso para melhorar resposta.

------------------------------------------------------------------------

# 109. Trust principle

O usuário deve conseguir distinguir:

-   dado;
-   interpretação;
-   recomendação.

O sistema deve favorecer verificabilidade.

------------------------------------------------------------------------

# 110. Cost principle

``` text
Use the least expensive model
that reliably satisfies
the required quality and risk level.
```

Não usar modelo premium indiscriminadamente.

------------------------------------------------------------------------

# 111. Data principle

``` text
Better governed data
beats larger prompts.
```

Qualidade de IA depende primeiro da qualidade do domínio.

------------------------------------------------------------------------

# 112. AI architecture invariants

1.  AI não é source of truth.
2.  AI não determina RAG oficial.
3.  AI não amplia acesso.
4.  AI recebe apenas contexto necessário.
5.  Authorization ocorre antes do retrieval.
6.  Ações consequenciais exigem autorização fresca.
7.  Output de modelo é não confiável até validado.
8.  Dados recuperados não são system instructions.
9.  BYOK secrets nunca chegam ao cliente.
10. Provider é acessado por adapter/gateway.
11. Falha do provider não quebra core PMO.
12. AI telemetry não registra secrets.
13. Histórico oficial vem de Snapshots.
14. Predictions exigem dados adequados.
15. Simulation exige modelo explícito.
16. Autonomy exige policy, Audit e human control.
17. Grounding deve ser preferido para respostas factuais.
18. Fact, inference e recommendation devem ser distinguíveis.
19. Custos e qualidade precisam ser observáveis.
20. IA evolui depois da governança de dados, não antes.

------------------------------------------------------------------------

# 113. Relação com `/docs/09-ai/`

Este documento define a arquitetura.

A pasta:

``` text
/docs/09-ai/
```

deverá aprofundar:

-   AI use cases;
-   prompts;
-   context contracts;
-   provider configuration;
-   model policies;
-   evaluations;
-   grounding;
-   safety;
-   cost controls;
-   Copilot behavior;
-   future agents.

------------------------------------------------------------------------

# 114. Relação com Specs

Specs que usam IA devem declarar:

-   AI role;
-   inputs;
-   authorized context;
-   outputs;
-   grounding;
-   confirmation;
-   failure behavior;
-   Audit implications;
-   fallback sem IA.

------------------------------------------------------------------------

# 115. Referências

-   `/docs/02-architecture/README.md`
-   `/docs/02-architecture/system-architecture.md`
-   `/docs/02-architecture/data-architecture.md`
-   `/docs/02-architecture/security-architecture.md`
-   `/docs/01-product/roadmap.md`
-   `/docs/01-product/success-metrics.md`
-   `/docs/04-specs/025-pmo-copilot/`
-   `/docs/09-ai/`

------------------------------------------------------------------------

# 116. Status

**Documento:** AI Architecture\
**Status:** Approved\
**Responsabilidade:** definir a arquitetura de IA do PMO Control,
incluindo Copilot, BYOK, abstração de providers, contexto autorizado,
grounding, segurança, observabilidade e evolução controlada para
inteligência preditiva, simulação e agentes.

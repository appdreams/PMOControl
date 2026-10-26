# PMO Control --- Product Roadmap

**Documento:** `roadmap.md`\
**Camada:** Product\
**Status:** Under Review\
**Tipo:** Roadmap evolutivo do produto

------------------------------------------------------------------------

## 1. Objetivo

Este documento define a evolução planejada do PMO Control desde sua
fundação até capacidades avançadas de inteligência e otimização.

O roadmap é orientado por:

-   valor;
-   dependências;
-   risco;
-   aprendizado;
-   maturidade dos dados;
-   métricas de sucesso.

Não é um compromisso rígido de datas.

> **A evolução para a próxima fase depende de evidências da fase
> anterior.**

------------------------------------------------------------------------

# 2. Princípio

O produto deve evoluir nesta direção:

``` text
CONTROL
   ↓
GOVERNANCE
   ↓
VISIBILITY
   ↓
INTELLIGENCE
   ↓
PREDICTION
   ↓
SIMULATION
   ↓
OPTIMIZATION
   ↓
AUTONOMY
```

Não antecipar inteligência avançada sem dados confiáveis.

------------------------------------------------------------------------

# 3. Horizonte

``` text
Phase 0 — Foundation
Phase 1 — MVP / Governance Core
Phase 2 — Operational Excellence
Phase 3 — Connected PMO
Phase 4 — Project Intelligence
Phase 5 — Predictive Governance
Phase 6 — Simulation & Optimization
Phase 7 — Agentic PMO
```

------------------------------------------------------------------------

# 4. Phase 0 --- Foundation

## Objetivo

Criar a base documental, funcional, arquitetural e de segurança antes da
implementação intensiva.

## Entregas

-   PDD;
-   Product docs;
-   Foundation docs;
-   ADRs;
-   Specifications;
-   UX references;
-   Data model;
-   Security model;
-   API conventions;
-   AI architecture;
-   Testing strategy;
-   DevOps foundation.

## Gate

A implementação de um domínio deve começar somente quando ele possuir
informação suficiente para desenvolvimento seguro e verificável.

------------------------------------------------------------------------

# 5. Phase 1 --- MVP / Governance Core

## Objetivo

Provar o Core Governance Loop:

``` text
UPDATE
  ↓
GOVERN
  ↓
CONSOLIDATE
  ↓
PUBLISH
  ↓
PRESERVE
  ↓
ANALYZE
  ↓
DECIDE
  ↓
ACT
```

------------------------------------------------------------------------

# 6. Phase 1A --- Secure SaaS Foundation

Entregas:

``` text
Authentication
Multi-tenancy
RBAC
Tenant isolation
Settings foundation
Audit foundation
Environment/Secrets
```

Critérios:

-   nenhum vazamento cross-tenant conhecido;
-   backend authorization;
-   Roles/Scopes funcionando;
-   eventos sensíveis auditáveis.

------------------------------------------------------------------------

# 7. Phase 1B --- Portfolio & Project Core

Entregas:

``` text
Portfolios
Projects
Project Control Center
Milestones
Deliverables
Schedule basic
Team basic
```

Resultado:

PMO e Project Manager conseguem estruturar e acompanhar Projects.

------------------------------------------------------------------------

# 8. Phase 1C --- Governance Core

Entregas:

``` text
Risks
Issues
Actions
Decisions
Dependencies basic
Documents/Evidence basic
```

Resultado:

o sistema deixa de ser apenas cadastro de Projects e passa a controlar
governança.

------------------------------------------------------------------------

# 9. Phase 1D --- Status & History

Entregas:

``` text
Status Update
RAG Engine
Snapshots
Audit integration
Basic historical comparison
```

Resultado:

o PMO consegue publicar um estado confiável e preservar o passado.

------------------------------------------------------------------------

# 10. Phase 1E --- Visibility

Entregas:

``` text
My Day
Project Dashboard
Portfolio Dashboard
Executive Portfolio
```

Resultado:

o produto transforma dados em atenção e contexto executivo.

------------------------------------------------------------------------

# 11. Phase 1F --- MVP Management Extensions

Entregas parciais:

``` text
Financial
Resources/Capacity
Time Machine
Notifications
Import/Export
Report Builder
```

Implementar somente os slices definidos em `mvp-scope.md`.

------------------------------------------------------------------------

# 12. Phase 1G --- Copilot Initial Release

Entregas:

-   BYOK por Tenant;
-   primeiro provider;
-   Q&A autorizado;
-   Project summary;
-   Portfolio summary;
-   change summary;
-   critical Risk/Issue summary;
-   executive briefing;
-   committee preparation.

Princípio:

``` text
AI assists.
Human decides.
```

------------------------------------------------------------------------

# 13. Gate de conclusão do MVP

Antes de avançar, validar:

-   jornada ponta a ponta;
-   Snapshot Integrity;
-   tenant isolation;
-   RBAC;
-   Status publication;
-   dashboards derivados;
-   Executive Portfolio;
-   Decision → Action;
-   My Day;
-   métricas básicas.

------------------------------------------------------------------------

# 14. Métricas gate --- MVP

Observar especialmente:

``` text
Trusted Governance Coverage
Status Freshness Rate
Status Preparation Time
Portfolio Consolidation Time
Parallel Control Rate
Overdue Action Rate
Decision Lead Time
Task Success Rate
Snapshot Integrity
```

Targets de negócio devem ser definidos após baseline.

Targets de integridade permanecem rígidos.

------------------------------------------------------------------------

# 15. Phase 2 --- Operational Excellence

## Objetivo

Reduzir ainda mais o trabalho operacional do PMO e melhorar adoção.

Foco:

``` text
Efficiency
Usability
Automation
Configuration
Reporting
```

------------------------------------------------------------------------

# 16. Phase 2 --- Status evolution

Possíveis evoluções:

-   configurable reporting cadence;
-   configurable review workflow;
-   richer deltas;
-   status templates;
-   validation profiles;
-   stronger completeness checks.

Evitar workflow builder genérico prematuro.

------------------------------------------------------------------------

# 17. Phase 2 --- My Day evolution

Evoluções:

-   dependency alerts;
-   resource conflicts;
-   saved filters;
-   personalized prioritization;
-   configurable attention rules;
-   better bulk follow-up.

------------------------------------------------------------------------

# 18. Phase 2 --- Reporting evolution

Evoluções:

-   templates;
-   richer exports;
-   scheduled report generation;
-   committee packs;
-   branded reports;
-   reusable report configurations.

------------------------------------------------------------------------

# 19. Phase 2 --- Financial evolution

Evoluções:

-   categories;
-   cost breakdown;
-   richer Forecast;
-   imported Actuals;
-   portfolio financial trends;
-   budget thresholds.

Ainda sem tentar virar ERP.

------------------------------------------------------------------------

# 20. Phase 2 --- Resources evolution

Evoluções:

-   skills/tags;
-   richer capacity planning;
-   availability;
-   allocation scenarios simples;
-   conflict resolution support.

------------------------------------------------------------------------

# 21. Phase 2 --- Documents evolution

Evoluções:

-   versions;
-   richer Evidence relationships;
-   metadata;
-   improved search;
-   external links/providers.

Não construir DMS completo sem necessidade.

------------------------------------------------------------------------

# 22. Phase 2 --- Configuration evolution

Possíveis capacidades:

-   project types;
-   taxonomies;
-   custom fields controlados;
-   configurable RAG rule packs;
-   notification preferences;
-   governance templates.

------------------------------------------------------------------------

# 23. Phase 2 --- AI productivity

Evoluções:

-   draft Actions;
-   draft Decision context;
-   draft Status narrative;
-   report drafting;
-   meeting preparation;
-   suggested follow-ups.

Toda mudança consequencial continua exigindo confirmação.

------------------------------------------------------------------------

# 24. Gate Phase 2

Avançar quando houver evidência de:

-   uso recorrente;
-   boa qualidade de dados;
-   redução de controles paralelos;
-   workflows principais estáveis;
-   valor percebido pelo PMO;
-   uso executivo real.

------------------------------------------------------------------------

# 25. Phase 3 --- Connected PMO

## Objetivo

Reduzir atualização manual conectando o PMO Control às ferramentas onde
a execução já acontece.

------------------------------------------------------------------------

# 26. Phase 3 --- Integration framework

Criar base para:

``` text
Connector
Authentication
Mapping
Sync
Idempotency
Retry
Observability
Source Authority
Conflict Handling
Audit
```

------------------------------------------------------------------------

# 27. Phase 3 --- Execution integrations

Candidatos:

``` text
Jira
Azure DevOps
Microsoft Project
GitHub
```

Prioridade deve seguir demanda real.

------------------------------------------------------------------------

# 28. Phase 3 --- Document integrations

Possíveis integrações:

``` text
SharePoint
OneDrive
Google Drive
```

Objetivo:

relacionar Evidence e documentos sem duplicação desnecessária.

------------------------------------------------------------------------

# 29. Phase 3 --- Communication integrations

Possíveis:

``` text
Microsoft Teams
Slack
E-mail workflows
```

Uso:

-   notifications;
-   decision requests;
-   reminders;
-   summaries.

------------------------------------------------------------------------

# 30. Phase 3 --- Financial integrations

Possíveis integrações com sistemas corporativos para trazer:

-   Actuals;
-   Budget;
-   Forecast inputs.

Não transformar PMO Control no sistema financeiro de origem.

------------------------------------------------------------------------

# 31. Phase 3 --- Source Authority

Cada integração deve declarar:

``` text
System of Record
Direction
Fields
Sync Frequency
Conflict Rule
Failure Behavior
```

Evitar sincronização bidirecional sem autoridade definida.

------------------------------------------------------------------------

# 32. Gate Phase 3

Antes de adicionar muitos conectores, validar:

-   demanda;
-   adoção;
-   manutenção;
-   qualidade;
-   custo;
-   segurança;
-   impacto real sobre trabalho manual.

------------------------------------------------------------------------

# 33. Phase 4 --- Project Intelligence

## Objetivo

Transformar dados históricos confiáveis em inteligência contextual mais
profunda.

------------------------------------------------------------------------

# 34. Phase 4 --- Knowledge Intelligence

Evoluções:

-   contextual retrieval;
-   Evidence-aware answers;
-   historical summaries;
-   cross-project patterns;
-   decision memory;
-   governance knowledge.

------------------------------------------------------------------------

# 35. Phase 4 --- Advanced Copilot

Perguntas:

> "O que mudou desde o último comitê?"

> "Quais Risks estão se repetindo em Projects semelhantes?"

> "Quais Decisions permanecem abertas há mais tempo?"

> "Quais Milestones estão ameaçados por Dependencies?"

------------------------------------------------------------------------

# 36. Phase 4 --- Explainability

Toda inteligência relevante deve buscar:

``` text
Claim
 ↓
Evidence
 ↓
Source
 ↓
Timestamp
```

quando aplicável.

------------------------------------------------------------------------

# 37. Phase 4 --- AI model routing

Evolução para múltiplos providers/modelos:

``` text
Task
 ↓
Policy
 ↓
Model Selection
 ↓
Provider
```

Critérios possíveis:

-   capability;
-   cost;
-   latency;
-   privacy;
-   context size;
-   Tenant policy.

------------------------------------------------------------------------

# 38. Phase 4 --- Provider expansion

Possíveis:

``` text
OpenAI
Anthropic
Google
OpenRouter
xAI
DeepSeek
others
```

A inclusão depende de necessidade, segurança e suporte técnico.

------------------------------------------------------------------------

# 39. Gate Phase 4

Inteligência avançada só deve crescer quando:

-   dados possuem qualidade;
-   histórico suficiente;
-   autorização está madura;
-   Evidence está estruturada;
-   usuários confiam nas fontes.

------------------------------------------------------------------------

# 40. Phase 5 --- Predictive Governance

## Objetivo

Passar de:

> "O que está acontecendo?"

para:

> "O que provavelmente acontecerá?"

------------------------------------------------------------------------

# 41. Predictive candidates

-   Milestone delay probability;
-   Project delay probability;
-   Risk escalation probability;
-   Issue aging prediction;
-   Forecast drift;
-   budget variance risk;
-   Action non-completion risk.

------------------------------------------------------------------------

# 42. Requisito de dados

Modelos preditivos exigem:

-   histórico;
-   qualidade;
-   volume;
-   consistência;
-   outcome labels.

Não criar previsão fictícia apenas para adicionar "AI".

------------------------------------------------------------------------

# 43. Confidence

Predições devem mostrar:

-   confidence;
-   evidence/features relevantes;
-   limitações;
-   data sufficiency.

Nunca apresentar previsão incerta como fato.

------------------------------------------------------------------------

# 44. Human governance

Predição não substitui responsável.

Fluxo:

``` text
Prediction
   ↓
Human review
   ↓
Decision
   ↓
Action
```

------------------------------------------------------------------------

# 45. Gate Phase 5

Exigir validação de:

-   accuracy;
-   calibration;
-   usefulness;
-   bias;
-   false positive cost;
-   false negative cost;
-   user trust.

------------------------------------------------------------------------

# 46. Phase 6 --- Simulation & Optimization

## Objetivo

Permitir testar cenários antes de decidir.

------------------------------------------------------------------------

# 47. Scenario Simulation

Perguntas:

> "E se o Milestone atrasar 30 dias?"

> "E se adicionarmos duas pessoas?"

> "E se reduzirmos o Budget?"

> "E se priorizarmos este Project sobre outro?"

------------------------------------------------------------------------

# 48. Simulation pipeline

``` text
Current State
      ↓
Assumption
      ↓
Simulation Model
      ↓
Projected Impact
      ↓
Comparison
      ↓
Decision Support
```

------------------------------------------------------------------------

# 49. Portfolio Optimization

Possíveis dimensões:

-   value;
-   cost;
-   risk;
-   capacity;
-   dependencies;
-   strategy;
-   deadlines.

Resultado:

cenários, não ordens automáticas.

------------------------------------------------------------------------

# 50. Strategy Alignment

Possível evolução:

``` text
Strategy
  ↓
Objectives / OKRs
  ↓
Portfolio
  ↓
Projects
  ↓
Benefits
  ↓
Outcomes
```

------------------------------------------------------------------------

# 51. Benefits Realization

O produto pode evoluir do acompanhamento de entrega para acompanhamento
de benefício.

Pergunta:

> "O Project entregou o resultado que justificou o investimento?"

------------------------------------------------------------------------

# 52. Gate Phase 6

Simulação e otimização exigem:

-   modelos explicáveis;
-   assumptions explícitas;
-   dados confiáveis;
-   capacidade de comparação;
-   validação humana.

------------------------------------------------------------------------

# 53. Phase 7 --- Agentic PMO

## Objetivo

Permitir agentes executarem trabalho operacional controlado, preservando
governança humana.

------------------------------------------------------------------------

# 54. Agent capabilities futuras

Exemplos:

-   preparar follow-ups;
-   solicitar updates;
-   organizar evidências;
-   gerar briefing;
-   acompanhar Actions;
-   sugerir escalations;
-   executar rotinas em integrações autorizadas.

------------------------------------------------------------------------

# 55. Autonomy levels

Possível modelo:

``` text
L0 — Answer
L1 — Recommend
L2 — Draft
L3 — Execute with Confirmation
L4 — Execute within Explicit Policy
L5 — High Autonomy
```

PMO Control deve evoluir progressivamente.

------------------------------------------------------------------------

# 56. Default autonomy

Para ações consequenciais:

``` text
Human confirmation
```

continua sendo o padrão até existir justificativa robusta para maior
autonomia.

------------------------------------------------------------------------

# 57. Agent authorization

Agentes nunca possuem acesso implícito superior ao usuário/contexto
autorizado.

Modelo:

``` text
Agent Effective Access
≤
Authorized Policy Context
```

------------------------------------------------------------------------

# 58. Agent auditability

Toda ação relevante deve registrar:

-   agent;
-   initiating user/policy;
-   action;
-   resource;
-   timestamp;
-   reason/context;
-   result.

------------------------------------------------------------------------

# 59. Agent safety

Antes de níveis altos de autonomia:

-   sandboxing quando aplicável;
-   permission boundaries;
-   confirmation policies;
-   rate limits;
-   rollback/compensation strategy;
-   observability;
-   kill switch;
-   incident response.

------------------------------------------------------------------------

# 60. Roadmap visual

``` text
FOUNDATION
    │
    ▼
MVP GOVERNANCE CORE
    │
    ▼
OPERATIONAL EXCELLENCE
    │
    ▼
CONNECTED PMO
    │
    ▼
PROJECT INTELLIGENCE
    │
    ▼
PREDICTIVE GOVERNANCE
    │
    ▼
SIMULATION & OPTIMIZATION
    │
    ▼
AGENTIC PMO
```

------------------------------------------------------------------------

# 61. Evolução da pergunta principal

## MVP

> "O que está acontecendo?"

## Operational Excellence

> "Onde preciso agir?"

## Connected PMO

> "Como manter o estado atualizado automaticamente?"

## Intelligence

> "Por que isso está acontecendo?"

## Predictive

> "O que provavelmente acontecerá?"

## Simulation

> "O que acontece se fizermos X?"

## Optimization

> "Qual cenário parece melhor?"

## Agentic

> "O que pode ser executado com segurança em meu nome?"

------------------------------------------------------------------------

# 62. Evolução do pipeline de inteligência

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

O MVP concentra-se principalmente em:

``` text
STATE
IMPACT
EVIDENCE
DECISION
ACTION
```

------------------------------------------------------------------------

# 63. Evolução do histórico

``` text
MVP
Immutable Snapshots

Phase 2
Richer comparison

Phase 4
Historical intelligence

Phase 5
Predictive training/evaluation data

Phase 6
Simulation baseline

Phase 7
Agent learning context under governance
```

------------------------------------------------------------------------

# 64. Evolução do Copilot

``` text
V1
Ask & Summarize

V2
Explain & Draft

V3
Recommend

V4
Predict

V5
Simulate

V6
Execute with Confirmation

V7
Policy-bound Agents
```

------------------------------------------------------------------------

# 65. Evolução do Portfolio

``` text
MVP
Visibility

Phase 2
Better prioritization

Phase 3
Connected data

Phase 4
Cross-project intelligence

Phase 5
Predictive risk

Phase 6
Optimization
```

------------------------------------------------------------------------

# 66. Evolução do PMO

O produto pretende deslocar progressivamente o trabalho de:

``` text
Collect
Consolidate
Format
Chase
```

para:

``` text
Analyze
Govern
Challenge
Decide
Improve
```

------------------------------------------------------------------------

# 67. Evolução executiva

De:

``` text
Static report
```

para:

``` text
Live trusted portfolio context
```

e posteriormente:

``` text
Decision intelligence
```

------------------------------------------------------------------------

# 68. Não usar datas arbitrárias

Este roadmap é baseado em maturidade.

Datas devem ser adicionadas somente quando houver:

-   capacidade do time;
-   estimativas;
-   dependências;
-   prioridades comerciais;
-   feedback de usuários.

------------------------------------------------------------------------

# 69. Release planning

O roadmap deve alimentar releases menores.

Exemplo:

``` text
Phase
  ↓
Release
  ↓
Epic/Capability
  ↓
Spec
  ↓
Implementation
```

Não transformar uma Phase inteira em um único release monolítico.

------------------------------------------------------------------------

# 70. Gate-based roadmap

Cada fase deve possuir:

``` text
Entry Criteria
Capabilities
Success Metrics
Exit Criteria
```

A próxima fase não deve existir apenas porque "está no roadmap".

------------------------------------------------------------------------

# 71. Critério de antecipação

Uma capability futura pode ser antecipada se houver:

-   requisito contratual;
-   necessidade crítica de usuário;
-   dependência comercial;
-   oportunidade comprovada;
-   risco estratégico.

A decisão deve ser explícita.

------------------------------------------------------------------------

# 72. Critério de adiamento

Uma capability pode ser adiada quando:

-   adoção insuficiente;
-   dados insuficientes;
-   baixo valor;
-   alto custo;
-   risco técnico;
-   dependências não maduras;
-   alternativa simples atende temporariamente.

------------------------------------------------------------------------

# 73. Controle de complexidade

Antes de adicionar tecnologia, perguntar:

1.  qual problema resolve?
2.  qual métrica melhora?
3.  qual persona precisa?
4.  qual jornada muda?
5.  por que agora?
6.  qual nova complexidade cria?

------------------------------------------------------------------------

# 74. Infraestrutura evolutiva

MVP:

``` text
Vercel
Supabase
Inngest
GitHub
SMTP
AI BYOK
```

Adicionar novos componentes somente quando necessidades observadas
justificarem.

------------------------------------------------------------------------

# 75. Possíveis gatilhos de infraestrutura

## Redis

Quando cache/distributed coordination justificar.

## Queue/Event infrastructure adicional

Quando volume, integração ou desacoplamento superar o modelo atual.

## Elasticsearch/OpenSearch

Quando search requirements reais excederem PostgreSQL.

## Graph database

Somente se casos de grafo demonstrarem valor impossível ou impraticável
no modelo atual.

## Kubernetes

Somente se necessidades operacionais justificarem complexidade.

------------------------------------------------------------------------

# 76. Roadmap de segurança

Segurança evolui junto com produto.

``` text
MVP
Strong isolation + RBAC + audit

Later
MFA / SSO / enterprise policies

Connected PMO
Integration security

AI maturity
AI governance / provider policies

Agentic
Agent authorization / execution safety
```

------------------------------------------------------------------------

# 77. Roadmap de dados

``` text
MVP
Operational relational model

Phase 2
Better analytics

Phase 3
Integrated sources

Phase 4
Knowledge retrieval

Phase 5
Predictive datasets

Phase 6
Simulation models

Phase 7
Agent execution context
```

------------------------------------------------------------------------

# 78. Roadmap de observabilidade

``` text
MVP
Logs / errors / jobs / health

Phase 2
Product telemetry maturity

Phase 3
Integration observability

Phase 4+
AI observability

Agentic
Agent traces and action observability
```

------------------------------------------------------------------------

# 79. Roadmap de UX

``` text
MVP
Clear operational workflows

Phase 2
Efficiency & personalization

Phase 3
Integration-aware experiences

Phase 4
Intelligence embedded in context

Phase 5
Predictive explanations

Phase 6
Scenario exploration

Phase 7
Human-agent collaboration
```

------------------------------------------------------------------------

# 80. Roadmap de métricas

``` text
MVP
Governance + efficiency + integrity

Phase 2
Adoption + workflow optimization

Phase 3
Automation impact

Phase 4
AI usefulness

Phase 5
Prediction quality

Phase 6
Simulation decision value

Phase 7
Agent effectiveness + safety
```

------------------------------------------------------------------------

# 81. Critérios de sucesso por fase

## Phase 1

Core Governance Loop funciona.

## Phase 2

Trabalho manual cai e adoção cresce.

## Phase 3

Integrações reduzem atualização duplicada.

## Phase 4

Intelligence melhora análise real.

## Phase 5

Predições demonstram utilidade e qualidade.

## Phase 6

Cenários melhoram decisões.

## Phase 7

Agentes executam trabalho com segurança e valor mensurável.

------------------------------------------------------------------------

# 82. Anti-roadmap

O PMO Control não deve evoluir automaticamente para:

-   ERP;
-   Jira clone;
-   HRIS;
-   generic DMS;
-   generic BI;
-   generic chatbot;
-   generic workflow platform.

A evolução deve preservar o foco em:

> **Project Governance Operating System.**

------------------------------------------------------------------------

# 83. North Star ao longo do roadmap

A North Star inicial permanece:

``` text
Trusted Governance Coverage
```

Com maturidade, métricas complementares podem ganhar importância:

``` text
Decision Effectiveness
Automation Coverage
Prediction Utility
Outcome Realization
```

Não trocar a North Star apenas para acompanhar uma nova feature.

------------------------------------------------------------------------

# 84. Visão de longo prazo

A visão final é um sistema capaz de:

1.  representar o estado do Portfolio;
2.  explicar causas;
3.  identificar impactos;
4.  localizar evidências;
5.  prever riscos;
6.  simular alternativas;
7.  apoiar decisões;
8.  transformar decisões em Actions;
9.  acompanhar Outcomes;
10. automatizar trabalho permitido com agentes governados.

------------------------------------------------------------------------

# 85. Estado futuro desejado

``` text
Project data is continuously updated.
Governance is exception-driven.
History is trustworthy.
Executives receive decision context.
AI explains and recommends.
Simulation tests alternatives.
Agents execute bounded work.
Humans retain governance authority.
```

------------------------------------------------------------------------

# 86. Relação com SDD

O roadmap não autoriza implementação direta.

Cada capability deve seguir:

``` text
Product Decision
      ↓
Specification
      ↓
Architecture / ADR when needed
      ↓
Acceptance Criteria
      ↓
Implementation
      ↓
Tests
      ↓
Release
      ↓
Metrics
      ↓
Learning
```

------------------------------------------------------------------------

# 87. Relação com Product Docs

Este roadmap encerra a camada inicial de Product Documentation:

``` text
PDD
Product Vision
Personas
User Journeys
Functional Map
Module Catalog
Feature Prioritization
MVP Scope
Success Metrics
Roadmap
```

Esses documentos formam a base para aprofundar Architecture, ADRs e
Specifications.

------------------------------------------------------------------------

# 88. Próxima etapa documental

Após aprovação deste documento, a pasta:

``` text
/docs/01-product/
```

estará completa.

A próxima frente documental deverá seguir a estrutura global definida
para o PMO Control, iniciando a próxima pasta ainda pendente conforme a
sequência acordada.

------------------------------------------------------------------------

# 89. Invariantes do roadmap

1.  Segurança não é fase futura.
2.  Multi-tenancy não é fase futura.
3.  Auditabilidade crítica não é fase futura.
4.  Histórico confiável começa no MVP.
5.  IA não substitui domínio correto.
6.  Prediction exige dados.
7.  Simulation exige modelo confiável.
8.  Autonomy exige autorização e segurança.
9.  Integração exige source authority.
10. Complexidade precisa de justificativa.
11. Roadmap muda com evidência.
12. Cada fase deve produzir valor mensurável.

------------------------------------------------------------------------

# 90. Referências

-   `/docs/01-product/PDD.md`
-   `/docs/01-product/product-vision.md`
-   `/docs/01-product/personas.md`
-   `/docs/01-product/user-journeys.md`
-   `/docs/01-product/functional-map.md`
-   `/docs/01-product/module-catalog.md`
-   `/docs/01-product/feature-prioritization.md`
-   `/docs/01-product/mvp-scope.md`
-   `/docs/01-product/success-metrics.md`
-   `/docs/00-foundation/`
-   `/docs/04-specs/`

------------------------------------------------------------------------

# 91. Status

**Documento:** Product Roadmap\
**Status:** Under Review\
**Responsabilidade:** orientar a evolução do PMO Control do MVP de
governança até inteligência preditiva, simulação, otimização e agentes
governados, usando evidências e métricas como gates de evolução.

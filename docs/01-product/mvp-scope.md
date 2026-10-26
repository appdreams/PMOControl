# PMO Control --- MVP Scope

**Documento:** `mvp-scope.md`\
**Camada:** Product\
**Status:** Under Review\
**Tipo:** Definição formal do escopo do MVP

------------------------------------------------------------------------

## 1. Objetivo

Este documento define a fronteira funcional e técnica do MVP do PMO
Control.

Seu objetivo é responder com clareza:

-   o que entra no MVP;
-   o que entra parcialmente;
-   o que fica fora;
-   quais jornadas precisam funcionar ponta a ponta;
-   quais requisitos não podem ser simplificados;
-   quais critérios indicam que o MVP está pronto para validação.

A regra central é:

> **MVP reduz escopo, não reduz integridade, segurança ou governança.**

------------------------------------------------------------------------

# 2. Objetivo do MVP

O MVP deve validar que o PMO Control consegue transformar dados
operacionais de projetos em governança confiável e visão executiva sem
exigir consolidação manual paralela.

A hipótese central é:

> **Se Project Managers e PMOs atualizarem as entidades operacionais na
> fonte, o sistema conseguirá consolidar Status, histórico, dashboards e
> Portfolio automaticamente, permitindo que o PMO trabalhe por exceção e
> que executivos decidam com contexto confiável.**

------------------------------------------------------------------------

# 3. Jornada central que precisa funcionar

O MVP não será considerado completo apenas porque módulos isolados
existem.

Esta jornada deve funcionar ponta a ponta:

``` text
Create Portfolio
      ↓
Create Project
      ↓
Define Project information
      ↓
Create Milestones / Deliverables
      ↓
Register Risks / Issues
      ↓
Create Actions / Decisions
      ↓
Update Project execution
      ↓
Prepare Status
      ↓
Validate and publish directly (authorized Project Manager)
      ↓
Calculate RAG
      ↓
Publish Status
      ↓
Create immutable Snapshot
      ↓
Update Project Dashboard
      ↓
Update Portfolio Dashboard
      ↓
Executive understands exceptions
```

------------------------------------------------------------------------

# 4. Princípios de escopo

## 4.1 Update once

O usuário atualiza a fonte correta uma vez.

## 4.2 Propagate everywhere

Views derivadas refletem o novo estado sem redigitação.

## 4.3 Governance by exception

O PMO identifica o que exige atenção.

## 4.4 History by design

Status publicado gera histórico confiável desde o primeiro release.

## 4.5 Authorization by design

Nenhuma feature é considerada pronta sem controle de acesso adequado.

## 4.6 AI is optional to core correctness

O produto precisa funcionar corretamente mesmo sem IA disponível.

------------------------------------------------------------------------

# 5. Classificação

Cada capability recebe uma classificação:

``` text
IN       → faz parte do MVP
PARTIAL  → entra com subconjunto claramente definido
OUT      → deliberadamente fora do MVP
LATER    → previsto para evolução futura
```

------------------------------------------------------------------------

# 6. Resumo do escopo

  Capability               MVP
  ------------------------ ---------
  Authentication           IN
  Multi-tenancy            IN
  RBAC                     IN
  Portfolios               IN
  Projects                 IN
  Project Control Center   IN
  Schedule                 PARTIAL
  Milestones               IN
  Deliverables             IN
  Risks                    IN
  Issues                   IN
  Actions                  IN
  Decisions                IN
  Dependencies             PARTIAL
  Status Update            IN
  RAG Engine               IN
  Snapshots                IN
  My Day                   IN
  Project Dashboard        IN
  Portfolio Dashboard      IN
  Executive Portfolio      IN
  Financial                PARTIAL
  Team                     PARTIAL
  Resources/Capacity       PARTIAL
  Documents/Evidence       PARTIAL
  Time Machine             PARTIAL
  Report Builder           PARTIAL
  PMO Copilot              PARTIAL
  Notifications            PARTIAL
  Audit Log                IN
  Import/Export            PARTIAL
  Settings                 IN

------------------------------------------------------------------------

# 7. Authentication --- IN

MVP inclui:

-   login;
-   logout;
-   convite/ativação;
-   recuperação de acesso;
-   sessão segura;
-   revogação;
-   tratamento de sessão inválida/expirada.

Fora do primeiro release:

-   SSO enterprise avançado;
-   federação com múltiplos IdPs;
-   políticas enterprise sofisticadas.

MFA será decidido na Spec de segurança conforme risco e mecanismo
disponível.

------------------------------------------------------------------------

# 8. Multi-tenancy --- IN

MVP inclui:

-   Tenant;
-   Membership;
-   tenant context;
-   isolamento de dados;
-   configuração por Tenant;
-   Tenant-aware storage;
-   testes automatizados cross-tenant.

Não existe versão aceitável do MVP com isolamento apenas no frontend.

------------------------------------------------------------------------

# 9. RBAC --- IN

MVP inclui Roles padrão:

``` text
Platform Admin
Tenant Admin
PMO Admin
PMO
Project Manager
Contributor
Executive
Viewer
```

Inclui:

-   Scope;
-   Permission;
-   sensitive permissions;
-   backend authorization;
-   Data Policies essenciais;
-   workflow authorization essencial.

Fora:

-   custom role designer;
-   visual policy builder;
-   ABAC avançado genérico.

------------------------------------------------------------------------

# 10. Portfolios --- IN

MVP inclui:

-   criar/editar;
-   owner;
-   Projects;
-   status;
-   filtros;
-   visão consolidada;
-   Project RAG;
-   exceções principais;
-   navegação.

Fora:

-   optimization engine;
-   advanced scoring models;
-   strategic scenario planning.

------------------------------------------------------------------------

# 11. Projects --- IN

MVP inclui:

-   criação;
-   edição;
-   ownership;
-   Portfolio;
-   lifecycle;
-   phase;
-   progress;
-   planned/actual;
-   Baseline essencial;
-   Forecast;
-   start/end dates;
-   archive;
-   completion/cancellation.

------------------------------------------------------------------------

# 12. Project Control Center --- IN

MVP inclui:

-   Overview;
-   health;
-   progress;
-   Baseline/Forecast;
-   próximos Milestones;
-   principais Deliverables;
-   Risks;
-   Issues;
-   Actions;
-   Decisions;
-   atalhos;
-   acesso ao Status.

É composição; não cria dados paralelos.

------------------------------------------------------------------------

# 13. Schedule --- PARTIAL

MVP inclui:

-   timeline básica;
-   start/end;
-   Baseline dates;
-   Forecast dates;
-   Actual dates;
-   Milestones;
-   visualização temporal;
-   indicação básica de atraso.

Fora:

-   critical path engine;
-   resource leveling;
-   complex network planning;
-   substituição completa de Microsoft Project.

------------------------------------------------------------------------

# 14. Milestones --- IN

MVP inclui:

-   title;
-   description;
-   owner;
-   criticality;
-   Baseline date;
-   Forecast date;
-   Actual date;
-   status;
-   threat/delay;
-   Deliverable relation;
-   history essencial.

------------------------------------------------------------------------

# 15. Deliverables --- IN

MVP inclui:

-   title;
-   description;
-   owner;
-   due date;
-   progress;
-   status;
-   Milestone relation;
-   Evidence básica;
-   overdue detection.

------------------------------------------------------------------------

# 16. Risks --- IN

MVP inclui:

-   title/context;
-   probability;
-   impact;
-   classification;
-   owner;
-   response/mitigation;
-   status;
-   escalation;
-   closure;
-   materialization em Issue;
-   history/audit aplicável.

------------------------------------------------------------------------

# 17. Issues --- IN

MVP inclui:

-   title/context;
-   severity;
-   impact;
-   owner;
-   resolution plan;
-   status;
-   escalation;
-   relation to Risk;
-   closure.

------------------------------------------------------------------------

# 18. Actions --- IN

MVP inclui:

-   title;
-   description;
-   owner;
-   due date;
-   source;
-   status;
-   overdue detection;
-   completion;
-   Project relation.

Origens suportadas inicialmente:

``` text
Risk
Issue
Decision
Status
Milestone
Manual
```

------------------------------------------------------------------------

# 19. Decisions --- IN

MVP inclui:

-   context;
-   requested decision;
-   impact;
-   impact of no decision;
-   deadline;
-   decision maker;
-   Evidence/reference;
-   approve;
-   reject;
-   defer;
-   comment;
-   history;
-   Action derivada.

------------------------------------------------------------------------

# 20. Dependencies --- PARTIAL

MVP inclui:

-   dependência básica;
-   source;
-   target;
-   owner;
-   due date;
-   status;
-   impact;
-   Project/Milestone/Deliverable relations definidas pela Spec.

Fora:

-   advanced dependency graph;
-   automated propagation simulation;
-   complex cross-program dependency engine.

------------------------------------------------------------------------

# 21. Status Update --- IN

O MVP inclui integralmente o workflow principal em cinco etapas.

## Step 1

Execution & Indicators.

## Step 2

Milestones & Deliverables.

## Step 3

Risks & Issues.

## Step 4

Actions & Decisions.

## Step 5

Summary & Publication.

Inclui:

-   Draft;
-   save;
-   current data loading;
-   delta desde última publicação;
-   validation;
-   direct publish by explicitly authorized Project Manager;
-   post-publication PMO consultation/correction flow;
-   Snapshot;
-   Audit.

------------------------------------------------------------------------

# 22. Status workflow --- IN

Fluxo padrão: `Draft → Validate → Publish → Snapshot`. Project Manager pode publicar diretamente quando possuir grant explícito no Project scope; não há aprovação de segunda pessoa obrigatória no MVP. Correção exige permission `status.update.correct`, motivo e publicação sucessora imutável. Revisão/aprovação configurável fica fora do MVP.

# 23. RAG Engine --- IN

MVP inclui:

-   Green;
-   Amber;
-   Red;
-   regras determinísticas;
-   thresholds essenciais;
-   explanation;
-   calculated RAG;
-   effective RAG;
-   override;
-   justification;
-   permission;
-   Audit.

IA não é necessária para determinar RAG no MVP.

------------------------------------------------------------------------

# 24. Snapshots --- IN

MVP inclui:

-   criação transacional na publicação;
-   immutable published state;
-   timestamp;
-   publication reference;
-   versão/sequence;
-   consulta;
-   base para Time Machine;
-   base para comparação.

Snapshot não pode depender de reconstrução futura do estado atual.

------------------------------------------------------------------------

# 25. My Day --- IN

MVP inclui:

-   overdue Actions;
-   Actions due soon;
-   critical Risks;
-   critical Issues;
-   Projects without current Status;
-   pending Decisions;
-   upcoming Milestones;
-   links rápidos;
-   filtros básicos.

Pode ficar para depois:

-   resource conflicts avançados;
-   personalized AI ranking;
-   predictive attention.

------------------------------------------------------------------------

# 26. Project Dashboard --- IN

MVP inclui:

-   RAG;
-   progress;
-   Baseline/Forecast;
-   milestones;
-   deliverables;
-   risks;
-   issues;
-   actions;
-   decisions;
-   upcoming critical events;
-   tendências básicas quando houver histórico.

O dashboard é derivado.

------------------------------------------------------------------------

# 27. Portfolio Dashboard --- IN

MVP inclui:

-   Projects;
-   RAG distribution;
-   critical Projects;
-   progress;
-   critical Risks;
-   pending Decisions;
-   upcoming Milestones;
-   Status freshness;
-   filtros.

------------------------------------------------------------------------

# 28. Executive Portfolio --- IN

MVP deve possuir experiência executiva enxuta.

Deve responder:

``` text
Which projects require attention?
Why?
What changed?
What is the impact?
What decisions are pending?
What is the next critical milestone?
```

Não incluir dezenas de widgets sem necessidade.

------------------------------------------------------------------------

# 29. Financial --- PARTIAL

MVP inclui:

-   Budget;
-   Actual;
-   Forecast;
-   Variance;
-   project summary;
-   Portfolio aggregation quando autorizado.

Fora:

-   accounting;
-   invoicing;
-   accounts payable;
-   complex financial allocation;
-   ERP replacement.

Acesso protegido por permissões específicas.

------------------------------------------------------------------------

# 30. Team --- PARTIAL

MVP inclui:

-   Project members;
-   responsibility;
-   role/context;
-   ownership visibility.

Não inclui:

-   HR lifecycle;
-   payroll;
-   performance management.

------------------------------------------------------------------------

# 31. Resources & Capacity --- PARTIAL

MVP inclui:

-   Resource;
-   basic capacity;
-   allocation;
-   utilization;
-   basic overallocation.

Fora:

-   optimization;
-   skills marketplace;
-   workforce planning;
-   AI allocation.

------------------------------------------------------------------------

# 32. Documents & Evidence --- PARTIAL

MVP inclui:

-   upload ou referência;
-   metadata;
-   classification;
-   Project association;
-   Evidence relation;
-   authorized access.

Fora:

-   enterprise DMS;
-   complex document lifecycle;
-   full-text enterprise search;
-   advanced knowledge graph.

------------------------------------------------------------------------

# 33. Time Machine --- PARTIAL

MVP inclui:

-   lista de Status publicados;
-   selecionar Snapshot;
-   visualizar estado histórico;
-   comparação básica com outra publicação.

Fora:

-   AI historical narrative;
-   advanced visual diff;
-   predictive timeline.

------------------------------------------------------------------------

# 34. Report Builder --- PARTIAL

MVP inclui:

-   standard Project report;
-   standard Portfolio report;
-   escolha de seções essenciais;
-   current ou published data;
-   export básico;
-   summary assistido por IA se disponível.

Fora:

-   drag-and-drop report designer;
-   arbitrary layout engine;
-   marketplace de templates;
-   complex scheduled distribution.

------------------------------------------------------------------------

# 35. PMO Copilot --- PARTIAL

O MVP pode operar sem IA configurada.

Quando AI/BYOK estiver configurado, primeira versão inclui:

-   Q&A sobre dados autorizados;
-   Project summary;
-   Portfolio summary;
-   mudanças desde último Status;
-   critical Risks/Issues;
-   executive briefing;
-   preparação de pontos para comitê.

Fora:

-   autonomous agents;
-   silent actions;
-   autonomous project management;
-   scenario simulation;
-   predictive engine;
-   unrestricted document ingestion.

------------------------------------------------------------------------

# 36. AI provider --- MVP

Modelo:

``` text
BYOK per Tenant
```

Primeiro provider suportado:

``` text
OpenAI
```

A arquitetura deve permitir evolução para outros providers sem
acoplamento desnecessário.

Possíveis providers futuros:

``` text
Claude
Gemini
OpenRouter
Grok
DeepSeek
others
```

------------------------------------------------------------------------

# 37. Model routing --- MVP

O sistema deve permitir abstração suficiente para que diferentes ações
possam utilizar modelos diferentes futuramente.

Não é necessário construir um sofisticado AI Router no primeiro release.

A configuração mínima deve evitar hardcode espalhado pelo domínio.

------------------------------------------------------------------------

# 38. Notifications --- PARTIAL

MVP inclui:

-   in-app;
-   SMTP/e-mail essencial;
-   Action assignment;
-   due reminder;
-   Status reminder;
-   Decision request;
-   eventos críticos selecionados.

Fora:

-   complex notification workflow builder;
-   SMS;
-   WhatsApp;
-   omnichannel orchestration.

------------------------------------------------------------------------

# 39. Audit Log --- IN

Captura desde o MVP:

-   authentication/security events relevantes;
-   access grants/revocations;
-   Role/Scope changes;
-   Baseline changes;
-   Financial changes sensíveis;
-   RAG override;
-   Status publication;
-   Decisions;
-   sensitive export;
-   exceptional administrative access.

UI pode começar simples, mas captura e integridade não podem ser
adiadas.

------------------------------------------------------------------------

# 40. Import / Export --- PARTIAL

MVP inclui importação controlada de dados estruturados quando necessária
à adoção.

Formato final será definido na Spec, priorizando simplicidade.

Inclui:

-   validation;
-   preview;
-   mapping essencial;
-   errors;
-   confirmation;
-   summary.

Export inclui:

-   Reports;
-   dados estruturados autorizados conforme regras.

------------------------------------------------------------------------

# 41. Settings --- IN

MVP inclui:

-   Tenant identity/config;
-   users/access entry points;
-   taxonomies essenciais;
-   RAG parameters essenciais;
-   AI/BYOK;
-   notification basics;
-   integrations configuration foundation.

Fora:

-   generic workflow designer;
-   generic custom object builder;
-   unlimited custom fields.

------------------------------------------------------------------------

# 42. Platform Administration --- IN mínimo

Necessário para operação SaaS.

Inclui:

-   Tenant management;
-   status;
-   basic limits/config;
-   support operations control.

Não inclui automaticamente acesso aos dados de negócio dos Tenants.

------------------------------------------------------------------------

# 43. Search --- PARTIAL

MVP deve possuir busca/filtros suficientes nos módulos operacionais.

Busca global inteligente pode ficar para depois.

Fora inicialmente:

-   Elasticsearch;
-   semantic global search complexa;
-   enterprise search engine.

------------------------------------------------------------------------

# 44. Mobile --- OUT do foco inicial

O produto será:

``` text
Desktop-first
Responsive where practical
```

Não faz parte do MVP:

-   aplicativo mobile nativo;
-   experiência mobile equivalente a todas as telas densas.

Fluxos simples podem funcionar responsivamente.

------------------------------------------------------------------------

# 45. Offline --- OUT

Não faz parte do MVP:

-   offline-first;
-   local synchronization;
-   conflict resolution offline.

------------------------------------------------------------------------

# 46. Real-time collaboration avançada --- OUT

Não faz parte do MVP:

-   coedição estilo Google Docs;
-   cursors;
-   live presence;
-   operational CRDT.

Atualizações normais multiusuário continuam necessárias.

------------------------------------------------------------------------

# 47. Chat corporativo --- OUT

PMO Control não tentará substituir:

-   Teams;
-   Slack;
-   e-mail.

Pode integrar notificações no futuro.

------------------------------------------------------------------------

# 48. Task management completo --- OUT

Não tentar reproduzir integralmente:

-   Jira;
-   Azure Boards;
-   sprint management;
-   story points;
-   source-code workflow.

Actions e Deliverables existem para governança.

------------------------------------------------------------------------

# 49. ERP financeiro --- OUT

Financial é limitado à governança de projetos.

------------------------------------------------------------------------

# 50. HRIS --- OUT

Resources não substitui sistemas de RH.

------------------------------------------------------------------------

# 51. DMS completo --- OUT

Documents/Evidence não substitui SharePoint, Google Drive ou plataformas
enterprise de documentos.

Integrações podem surgir depois.

------------------------------------------------------------------------

# 52. Advanced Portfolio Optimization --- LATER

Inclui:

-   optimization algorithms;
-   constrained portfolio selection;
-   capacity scenarios;
-   investment optimization.

------------------------------------------------------------------------

# 53. Predictive Intelligence --- LATER

Inclui:

-   delay prediction;
-   risk prediction;
-   anomaly detection;
-   budget forecasting assistido;
-   milestone probability.

Exige dados históricos suficientes.

------------------------------------------------------------------------

# 54. Scenario Simulation --- LATER

Inclui perguntas como:

> "Qual impacto de adicionar duas pessoas?"

> "O que acontece se este Milestone atrasar 30 dias?"

Fora do MVP.

------------------------------------------------------------------------

# 55. Autonomous Agents --- LATER

Fora do MVP:

-   agentes executando mudanças sem confirmação;
-   agentes realizando follow-up autonomamente em múltiplos sistemas;
-   agentes alterando governance state sem usuário responsável.

------------------------------------------------------------------------

# 56. Strategy / OKR Alignment --- LATER

Possível evolução:

``` text
Strategy
 ↓
Objectives / OKRs
 ↓
Portfolio
 ↓
Project
 ↓
Outcome
```

Não faz parte da validação inicial.

------------------------------------------------------------------------

# 57. Benefits Realization --- LATER

Acompanhamento de benefícios pós-projeto é uma direção coerente, porém
posterior.

------------------------------------------------------------------------

# 58. Stack do MVP

``` text
Application
Next.js + TypeScript

Hosting
Vercel

Database
Supabase / PostgreSQL

Authentication
Supabase Auth, sujeito à confirmação arquitetural

Storage
Supabase Storage

Background Jobs
Inngest

Repository / CI source
GitHub

E-mail
SMTP existente/configurável

AI
BYOK per Tenant
```

Decisões definitivas de arquitetura serão formalizadas em ADRs.

------------------------------------------------------------------------

# 59. Infraestrutura fora do MVP

Não introduzir sem evidência de necessidade:

``` text
Redis
Kafka
RabbitMQ
Neo4j
Elasticsearch
Kubernetes
Firebase
```

Se uma necessidade real surgir, deve gerar decisão arquitetural
explícita.

------------------------------------------------------------------------

# 60. Requisitos não negociáveis

Mesmo no MVP:

1.  tenant isolation;
2.  backend authorization;
3.  secure secret handling;
4.  immutable published history;
5.  audit de eventos sensíveis;
6.  transactional Status publication;
7.  data classification;
8.  input validation;
9.  output encoding/security;
10. protection against IDOR/BOLA;
11. tests de autorização;
12. tests cross-tenant;
13. migrations versionadas;
14. observability mínima;
15. backups/recovery compatíveis com a plataforma escolhida.

------------------------------------------------------------------------

# 61. Publicação transacional

O MVP deve implementar publicação conceitualmente como:

``` text
Validate
   ↓
Authorize
   ↓
Calculate KPIs
   ↓
Calculate RAG
   ↓
Consolidate
   ↓
Create Snapshot
   ↓
Register publication/audit
   ↓
Commit
   ↓
Trigger derived asynchronous work
```

Se a operação principal falhar, não deve existir Snapshot parcial
oficialmente publicado.

------------------------------------------------------------------------

# 62. Dados derivados assíncronos

Após publicação, tarefas não críticas podem ocorrer via Inngest.

Exemplos:

-   notification;
-   AI summary;
-   report preparation;
-   derived cache/materialization quando adotada.

A publicação oficial não deve depender de um LLM responder com sucesso.

------------------------------------------------------------------------

# 63. AI failure behavior

Se AI estiver indisponível:

``` text
Core PMO functionality continues.
```

O usuário ainda consegue:

-   atualizar;
-   governar;
-   publicar;
-   consultar;
-   decidir.

------------------------------------------------------------------------

# 64. BYOK security

MVP deve garantir:

-   secrets protegidos;
-   nunca retornar chave completa;
-   acesso restrito;
-   Tenant isolation;
-   audit de alteração/configuração;
-   remoção/revogação.

Detalhamento técnico será definido em Security/AI Specs.

------------------------------------------------------------------------

# 65. Dados de demonstração

O MVP deve possuir mecanismo seguro para ambiente de
desenvolvimento/demo com dados sintéticos.

Nunca utilizar dados reais de cliente em ambientes inadequados.

------------------------------------------------------------------------

# 66. Browser/Desktop

Foco inicial:

-   browsers modernos;
-   desktop/laptop;
-   widescreen.

Compatibilidade específica será definida em testing/support matrix.

------------------------------------------------------------------------

# 67. Acessibilidade

O MVP deve aplicar boas práticas básicas:

-   contraste;
-   navegação por teclado onde aplicável;
-   labels;
-   focus states;
-   semântica;
-   não depender apenas de cor para comunicar RAG.

A maturidade de acessibilidade poderá crescer, mas não deve ser
ignorada.

------------------------------------------------------------------------

# 68. Performance

O MVP deve manter experiência responsiva para volumes realistas de
validação.

Não otimizar prematuramente para escala hipotética extrema.

Performance targets quantitativos serão definidos em NFRs.

------------------------------------------------------------------------

# 69. Observability

MVP deve possuir:

-   structured logs;
-   correlation/request IDs;
-   error tracking compatível;
-   job observability;
-   security-relevant telemetry;
-   health visibility.

Log técnico não substitui Audit Log.

------------------------------------------------------------------------

# 70. Dados iniciais e onboarding

Onboarding mínimo deve permitir:

``` text
Create Tenant / provision Tenant
      ↓
Invite Users
      ↓
Create Portfolio
      ↓
Create Project
      ↓
Start governance
```

Importação pode acelerar adoção, mas não deve bloquear criação manual
inicial.

------------------------------------------------------------------------

# 71. Primeiro cenário de validação

Projeto exemplo:

``` text
Modernização ERP
```

Criar:

-   Portfolio;
-   Project;
-   seis Milestones;
-   Deliverables;
-   Risks;
-   Issues;
-   Actions;
-   Decisions;
-   Budget;
-   Status.

Executar a jornada completa e validar propagação.

------------------------------------------------------------------------

# 72. Segundo cenário de validação

Portfolio com pelo menos cinco Projects em estados distintos:

``` text
Green
Green
Amber
Amber
Red
```

Validar:

-   Portfolio Dashboard;
-   Executive Portfolio;
-   My Day;
-   filtros;
-   decisões;
-   riscos;
-   Status freshness.

------------------------------------------------------------------------

# 73. Cenário de segurança obrigatório

Criar:

``` text
Tenant A
Tenant B
```

Usuário do Tenant A tenta:

-   consultar Project B;
-   alterar Risk B;
-   acessar documento B;
-   exportar dados B;
-   perguntar ao Copilot sobre B.

Todos devem resultar em acesso negado sem vazamento de informação.

------------------------------------------------------------------------

# 74. Cenário de RBAC obrigatório

Validar pelo menos:

``` text
Contributor
Project Manager
PMO
PMO Admin
Executive
Tenant Admin
```

com operações permitidas e negadas.

------------------------------------------------------------------------

# 75. Cenário histórico obrigatório

``` text
Publish Status 1
      ↓
Change Project
      ↓
Publish Status 2
      ↓
Open Time Machine
      ↓
Compare
```

Status 1 deve permanecer inalterado.

------------------------------------------------------------------------

# 76. Cenário RAG obrigatório

``` text
Calculated RAG = RED
      ↓
Authorized PMO Admin overrides to AMBER
      ↓
Justification required
      ↓
Audit
      ↓
Snapshot stores calculated + effective values
```

------------------------------------------------------------------------

# 77. Cenário de decisão obrigatório

``` text
Create Decision
      ↓
Assign Executive
      ↓
Executive reviews
      ↓
Approve
      ↓
Create Action
      ↓
Assign owner
      ↓
Track completion
```

------------------------------------------------------------------------

# 78. Cenário Copilot obrigatório quando AI estiver habilitada

Pergunta:

> "Quais projetos merecem minha atenção?"

Resposta deve:

-   usar apenas Projects autorizados;
-   citar/explicar fatores relevantes no contexto da aplicação;
-   distinguir fato e recomendação;
-   não inventar dados ausentes.

------------------------------------------------------------------------

# 79. Definition of MVP Complete --- Produto

MVP está funcionalmente completo quando:

1.  jornada central funciona ponta a ponta;
2.  PMO consegue operar por exceção;
3.  PM consegue atualizar sem dashboard manual;
4.  Status pode ser publicado;
5.  Snapshot é preservado;
6.  Portfolio reflete Projects;
7.  Executive consegue identificar exceções;
8.  Decisions conectam-se a Actions;
9.  histórico pode ser consultado;
10. permissões funcionam.

------------------------------------------------------------------------

# 80. Definition of MVP Complete --- Engenharia

Também exige:

-   migrations;
-   automated tests essenciais;
-   tenant isolation tests;
-   permission tests;
-   publication transaction tests;
-   audit tests;
-   error handling;
-   observability;
-   deployment reproduzível;
-   environment configuration;
-   secret handling;
-   backup/recovery strategy documentada.

------------------------------------------------------------------------

# 81. Definition of MVP Complete --- Segurança

Exige:

-   deny by default em operações sensíveis;
-   no known cross-tenant leakage;
-   no client-controlled authorization;
-   secure BYOK handling;
-   sensitive exports controlled;
-   confidential document policy;
-   audit integrity;
-   dependency/security review compatível com release.

------------------------------------------------------------------------

# 82. Definition of MVP Complete --- UX

Exige que as jornadas centrais possam ser executadas sem:

-   planilha paralela obrigatória;
-   PowerPoint obrigatório;
-   navegação excessiva;
-   duplicação da mesma informação;
-   dependência de conhecimento oculto do sistema.

------------------------------------------------------------------------

# 83. Critérios de não entrada

Uma feature não entra no MVP se:

-   não suporta jornada central;
-   não é necessária para segurança;
-   não reduz risco crítico;
-   não é necessária para validar proposta;
-   introduz complexidade desproporcional;
-   depende de maturidade ainda inexistente.

------------------------------------------------------------------------

# 84. Controle de expansão de escopo

Qualquer inclusão nova no MVP deve registrar:

``` text
Feature
Reason
Persona
Journey
Business Value
Dependency
Cost/Complexity
What leaves or changes in scope
Decision
```

Evitar crescimento silencioso.

------------------------------------------------------------------------

# 85. Critério para pós-MVP

Mover para pós-MVP quando:

-   o valor pode ser validado sem a capability;
-   existe alternativa manual aceitável temporária;
-   exige dados históricos ainda inexistentes;
-   exige integração externa complexa;
-   cria infraestrutura prematura;
-   não bloqueia governança central.

------------------------------------------------------------------------

# 86. Resultado esperado do MVP

Ao final, deve ser possível demonstrar:

> Um PMO abre o sistema, identifica exceções, entra em um projeto,
> acompanha execução, riscos, issues, ações e decisões, publica um
> Status confiável, preserva o estado histórico e apresenta ao executivo
> uma visão consolidada do Portfolio sem reconstruir os dados
> manualmente.

Essa é a demonstração principal do valor do MVP.

------------------------------------------------------------------------

# 87. O que o MVP não tenta provar

O MVP não precisa provar que o PMO Control:

-   substitui todas as ferramentas de execução;
-   suporta qualquer processo organizacional;
-   resolve planejamento financeiro corporativo;
-   otimiza automaticamente Portfolio;
-   prevê todos os atrasos;
-   possui agentes autônomos;
-   escala para qualquer volume imaginável.

Precisa provar seu **Core Governance Loop**.

------------------------------------------------------------------------

# 88. Core Governance Loop do MVP

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

# 89. Relação com Success Metrics

O próximo documento:

``` text
/docs/01-product/success-metrics.md
```

definirá como medir se esse MVP realmente gera valor.

Exemplos a formalizar:

-   redução do tempo de preparação de Status;
-   Status freshness;
-   redução de Actions vencidas;
-   tempo até decisão;
-   uso de dados operacionais como fonte;
-   redução de controles paralelos.

------------------------------------------------------------------------

# 90. Referências

-   `/docs/01-product/PDD.md`
-   `/docs/01-product/product-vision.md`
-   `/docs/01-product/personas.md`
-   `/docs/01-product/user-journeys.md`
-   `/docs/01-product/functional-map.md`
-   `/docs/01-product/module-catalog.md`
-   `/docs/01-product/feature-prioritization.md`
-   `/docs/00-foundation/business-rules.md`
-   `/docs/00-foundation/permission-model.md`
-   `/docs/00-foundation/data-classification.md`
-   `/docs/04-specs/`

------------------------------------------------------------------------

# 91. Status

**Documento:** MVP Scope\
**Status:** Under Review\
**Responsabilidade:** estabelecer a fronteira objetiva do primeiro
produto validável do PMO Control, incluindo capacidades IN, PARTIAL, OUT
e LATER, sem comprometer segurança, histórico, autorização ou
integridade da governança.

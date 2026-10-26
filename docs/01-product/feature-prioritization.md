# PMO Control --- Feature Prioritization

**Documento:** `feature-prioritization.md`\
**Camada:** Product\
**Status:** Under Review\
**Tipo:** Priorização funcional do produto

------------------------------------------------------------------------

## 1. Objetivo

Este documento estabelece a priorização funcional do PMO Control e cria
uma referência para decisões de escopo, sequência de entrega e MVP.

A priorização responde:

> **O que é indispensável para provar a proposta de valor do PMO
> Control, o que aumenta significativamente seu valor e o que deve ser
> adiado para evitar complexidade prematura?**

Este documento não define sozinho o conteúdo final do MVP. A fronteira
formal será consolidada em:

``` text
/docs/01-product/mvp-scope.md
```

------------------------------------------------------------------------

# 2. Método

A classificação principal utiliza quatro níveis:

``` text
MUST
SHOULD
COULD
FUTURE
```

## MUST

Necessário para o produto funcionar com segurança ou provar sua proposta
central.

## SHOULD

Muito importante para a experiência e valor, mas pode entrar após o
núcleo funcional caso necessário.

## COULD

Útil e desejável, porém não essencial para validar a primeira versão.

## FUTURE

Capacidade estratégica ou avançada deliberadamente adiada.

------------------------------------------------------------------------

# 3. Critérios de priorização

Cada capacidade é avaliada considerando:

1.  valor para PMO;
2.  valor para Project Manager;
3.  valor executivo;
4.  necessidade de governança;
5.  dependência funcional;
6.  segurança;
7.  redução de trabalho manual;
8.  frequência de uso;
9.  complexidade;
10. capacidade de validar a hipótese central.

------------------------------------------------------------------------

# 4. Hipótese que o MVP precisa provar

O MVP precisa demonstrar que:

> **dados operacionais estruturados podem alimentar automaticamente
> governança, Status, histórico e visão executiva, reduzindo
> consolidação manual do PMO.**

Portanto, a cadeia prioritária é:

``` text
Project
   ↓
Operational Governance
   ↓
Status
   ↓
Snapshot
   ↓
Dashboard / Portfolio
   ↓
Decision
```

------------------------------------------------------------------------

# 5. Prioridade P0 --- Fundação obrigatória

Estas capacidades são `MUST`.

``` text
Authentication
Multi-tenancy
RBAC
Tenant Isolation
Projects
Portfolios
Audit foundations
Settings foundations
```

Sem elas, o SaaS não possui base segura para operar.

------------------------------------------------------------------------

# 6. Authentication --- MUST

Razões:

-   acesso à aplicação;
-   identidade;
-   sessão;
-   segurança;
-   base para autorização.

MVP mínimo:

-   login;
-   logout;
-   convite/ativação;
-   recuperação de acesso;
-   sessão segura;
-   revogação básica.

Pode ficar para evolução:

-   SSO corporativo avançado;
-   múltiplos Identity Providers;
-   políticas enterprise complexas.

------------------------------------------------------------------------

# 7. Multi-tenancy --- MUST

Razões:

-   produto SaaS;
-   isolamento organizacional;
-   BYOK por Tenant;
-   configurações independentes.

MVP:

-   Tenant;
-   Membership;
-   tenant context;
-   isolamento;
-   testes cross-tenant.

Não é aceitável implementar isolamento posteriormente.

------------------------------------------------------------------------

# 8. RBAC --- MUST

MVP:

-   Roles padrão;
-   Scope;
-   Permissions;
-   permissões sensíveis;
-   enforcement backend;
-   Data Policies essenciais.

Roles iniciais:

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

Custom Roles avançados podem ficar para fase posterior.

------------------------------------------------------------------------

# 9. Projects --- MUST

É o núcleo operacional.

MVP:

-   criação;
-   edição;
-   ownership;
-   Portfolio;
-   phase/state;
-   dates;
-   progress;
-   Baseline essencial;
-   Forecast;
-   archive/completion;
-   navegação.

------------------------------------------------------------------------

# 10. Portfolios --- MUST

Necessário para governança multi-project.

MVP:

-   criar Portfolio;
-   associar Projects;
-   responsável;
-   filtros;
-   visão consolidada;
-   RAG dos Projects;
-   principais exceções.

Priorização avançada pode ser posterior.

------------------------------------------------------------------------

# 11. Project Control Center --- MUST

É a experiência operacional principal do Project.

MVP:

-   overview;
-   health;
-   progress;
-   próximas datas;
-   principais Risks;
-   Issues;
-   Actions;
-   Decisions;
-   Milestones;
-   atalhos para módulos.

------------------------------------------------------------------------

# 12. Milestones --- MUST

Razões:

-   controle de prazo;
-   visão executiva;
-   Status;
-   alertas;
-   governança.

MVP:

-   title;
-   owner;
-   baseline date;
-   forecast date;
-   actual date;
-   criticality;
-   status;
-   relation to Project;
-   threat/delay indication.

------------------------------------------------------------------------

# 13. Deliverables --- MUST

MVP:

-   title;
-   owner;
-   due date;
-   status;
-   progress;
-   Milestone relation;
-   basic evidence;
-   overdue detection.

------------------------------------------------------------------------

# 14. Risks --- MUST

MVP:

-   register;
-   probability;
-   impact;
-   classification;
-   owner;
-   response;
-   status;
-   criticality;
-   escalation;
-   closure.

Risk management é parte central da proposta de governança.

------------------------------------------------------------------------

# 15. Issues --- MUST

MVP:

-   register;
-   severity;
-   impact;
-   owner;
-   resolution plan;
-   status;
-   escalation;
-   relation to materialized Risk;
-   closure.

------------------------------------------------------------------------

# 16. Actions --- MUST

MVP:

-   title;
-   description;
-   owner;
-   due date;
-   source;
-   status;
-   overdue;
-   completion.

Actions conectam governança à execução.

------------------------------------------------------------------------

# 17. Decisions --- MUST

Decisions são fundamentais para diferenciar o produto de um simples
tracker.

MVP:

-   context;
-   decision required;
-   impact;
-   impact of no decision;
-   owner/decision maker;
-   due date;
-   evidence/reference;
-   approve;
-   reject;
-   defer;
-   history.

------------------------------------------------------------------------

# 18. Dependencies --- SHOULD

Dependencies são importantes, mas o primeiro incremento pode começar com
relações essenciais.

Prioridade:

``` text
SHOULD
```

MVP desejável:

-   basic dependency;
-   owner;
-   due date;
-   status;
-   impact.

Dependências complexas cross-project podem evoluir depois.

------------------------------------------------------------------------

# 19. Status Update --- MUST

É uma das capacidades mais importantes do produto.

MVP deve possuir as cinco etapas:

``` text
1. Execution & Indicators
2. Milestones & Deliverables
3. Risks & Issues
4. Actions & Decisions
5. Summary & Publication
```

Inclui:

-   Draft;
-   review;
-   validation;
-   publication;
-   delta desde última publicação;
-   integração com Snapshot.

------------------------------------------------------------------------

# 20. RAG Engine --- MUST

MVP:

-   Green/Amber/Red;
-   regras iniciais;
-   thresholds configuráveis essenciais;
-   calculated RAG;
-   effective RAG;
-   explanation;
-   override autorizado;
-   justification;
-   audit.

Não precisa começar com IA para calcular RAG.

Regras determinísticas devem ser suficientes inicialmente.

------------------------------------------------------------------------

# 21. Snapshots --- MUST

Snapshots são necessários desde a primeira publicação de Status.

MVP:

-   Snapshot por publicação;
-   immutable business state;
-   version/date;
-   consulta;
-   comparação básica.

Não devem ser adicionados apenas depois que o produto já possuir
histórico mutável.

------------------------------------------------------------------------

# 22. My Day --- MUST

É a experiência que materializa a ideia de:

> **governance by exception**

MVP:

-   overdue Actions;
-   critical Risks;
-   critical Issues;
-   Projects without current Status;
-   pending Decisions;
-   upcoming Milestones.

Itens mais avançados podem entrar posteriormente.

------------------------------------------------------------------------

# 23. Project Dashboard --- MUST

MVP:

-   RAG;
-   progress;
-   schedule;
-   Milestones;
-   Risks;
-   Issues;
-   Actions;
-   Decisions;
-   próximos marcos;
-   tendências básicas.

Financeiro depende de autorização e maturidade do módulo.

------------------------------------------------------------------------

# 24. Portfolio Dashboard --- MUST

MVP:

-   Projects por RAG;
-   progress;
-   critical Projects;
-   critical Risks;
-   pending Decisions;
-   upcoming Milestones;
-   Status freshness.

Deve permanecer executivo e não excessivamente poluído.

------------------------------------------------------------------------

# 25. Financial --- SHOULD

É relevante para governança corporativa, mas pode ser entregue em
incremento posterior ao núcleo operacional caso necessário.

Prioridade:

``` text
SHOULD
```

Primeira versão:

-   Budget;
-   Actual;
-   Forecast;
-   Variance;
-   project-level summary;
-   authorized portfolio consolidation.

Fora da primeira versão:

-   ERP features;
-   accounting;
-   complex cost allocation;
-   invoicing.

------------------------------------------------------------------------

# 26. Resources & Capacity --- SHOULD

Primeira versão:

-   Resource;
-   allocation;
-   capacity;
-   basic overallocation;
-   project association.

Advanced resource optimization:

``` text
COULD / FUTURE
```

------------------------------------------------------------------------

# 27. Documents --- SHOULD

Primeira versão:

-   upload/reference;
-   metadata;
-   classification;
-   Project association;
-   Evidence relation;
-   authorization.

Não tentar construir um DMS completo.

------------------------------------------------------------------------

# 28. Time Machine --- SHOULD

Snapshots são `MUST`.

A experiência rica de Time Machine é:

``` text
SHOULD
```

Primeira versão:

-   escolher publicação;
-   visualizar histórico;
-   comparação básica.

Evoluções:

-   advanced diff;
-   timeline intelligence;
-   AI historical explanation.

------------------------------------------------------------------------

# 29. Report Builder --- SHOULD

Importante para substituir apresentações manuais.

Primeira versão:

-   Project report;
-   Portfolio report;
-   sections;
-   current/snapshot;
-   export básico;
-   templates iniciais.

Advanced custom report designer pode ser `COULD`.

------------------------------------------------------------------------

# 30. PMO Copilot --- SHOULD

IA é diferencial estratégico, mas o domínio precisa funcionar sem
depender dela.

Prioridade:

``` text
SHOULD
```

Primeira versão:

-   perguntas sobre dados autorizados;
-   resumo de Project;
-   resumo de Portfolio;
-   mudanças desde último Status;
-   principais Risks;
-   preparação de resumo executivo.

Ações autônomas ficam fora do MVP.

------------------------------------------------------------------------

# 31. Notifications --- SHOULD

Primeira versão:

-   in-app;
-   e-mail essencial;
-   Action assignment;
-   due date;
-   Status reminder;
-   Decision request;
-   critical escalation.

Advanced notification rules:

``` text
COULD
```

------------------------------------------------------------------------

# 32. Audit Log --- MUST

Auditability é fundamento.

MVP:

-   login/security events essenciais;
-   role/scope changes;
-   Status publication;
-   RAG override;
-   Decisions;
-   Baseline change;
-   sensitive export;
-   admin/support events quando aplicável.

Uma UI completa de exploração do Audit Log pode evoluir após a captura
correta dos eventos.

------------------------------------------------------------------------

# 33. Import / Export --- SHOULD

Importação é importante para adoção.

Primeira versão:

-   CSV/XLSX ou formato definido posteriormente;
-   validation;
-   preview;
-   mapping essencial;
-   summary.

Export:

-   reports;
-   authorized structured exports.

Integrações sofisticadas ficam para roadmap.

------------------------------------------------------------------------

# 34. Settings --- MUST

MVP:

-   Tenant basics;
-   users/access entry points;
-   project taxonomies essenciais;
-   RAG configuration essencial;
-   AI/BYOK configuration;
-   notification basics.

Custom Fields avançados ficam para depois.

------------------------------------------------------------------------

# 35. Schedule --- SHOULD

Embora importante, não é necessário reproduzir um Microsoft Project
completo.

Primeira versão:

-   timeline;
-   dates;
-   Baseline;
-   Forecast;
-   Actual;
-   Milestones;
-   basic dependencies.

Advanced critical path/network planning:

``` text
FUTURE
```

------------------------------------------------------------------------

# 36. Team --- SHOULD

Primeira versão:

-   Project members;
-   responsibilities;
-   owners;
-   relationship to assignments.

Não substituir HRIS.

------------------------------------------------------------------------

# 37. Evidence --- MUST como conceito

Mesmo que não exista módulo independente no MVP, o conceito de Evidence
deve existir desde o início para:

-   Decisions;
-   Deliverables;
-   Status;
-   Risks/Issues quando necessário;
-   Baseline changes.

------------------------------------------------------------------------

# 38. Baseline Management --- MUST básico / SHOULD avançado

MVP:

-   preserve original Baseline;
-   authorized change;
-   reason;
-   audit;
-   new version when required.

Workflow completo de Change Request/approval:

``` text
SHOULD
```

dependendo da complexidade escolhida para o primeiro release.

------------------------------------------------------------------------

# 39. Executive Portfolio --- MUST

A experiência executiva é parte da validação do produto.

Primeira versão deve responder:

``` text
Which projects need attention?
Why?
What changed?
What decisions are pending?
What are the next critical milestones?
```

Não precisa começar com dezenas de gráficos.

------------------------------------------------------------------------

# 40. Priorização consolidada por módulo

  Capability               Priority
  ------------------------ ----------
  Authentication           MUST
  Multi-tenancy            MUST
  RBAC                     MUST
  Portfolios               MUST
  Projects                 MUST
  Project Control Center   MUST
  Milestones               MUST
  Deliverables             MUST
  Risks                    MUST
  Issues                   MUST
  Actions                  MUST
  Decisions                MUST
  Dependencies             SHOULD
  Status Update            MUST
  RAG Engine               MUST
  Snapshots                MUST
  My Day                   MUST
  Project Dashboard        MUST
  Portfolio Dashboard      MUST
  Financial                SHOULD
  Resources                SHOULD
  Documents                SHOULD
  Time Machine             SHOULD
  Report Builder           SHOULD
  PMO Copilot              SHOULD
  Notifications            SHOULD
  Audit Log                MUST
  Import / Export          SHOULD
  Settings                 MUST

------------------------------------------------------------------------

# 41. MUST não significa implementação completa

Uma capacidade classificada como MUST pode possuir:

``` text
MVP Slice
```

e evoluir posteriormente.

Exemplo:

`RBAC` é MUST.

Mas:

``` text
Standard Roles → MUST
Custom Roles → COULD
```

------------------------------------------------------------------------

# 42. Priorização interna --- Authentication

``` text
MUST
- login
- logout
- invitation
- recovery
- secure session
- revocation

SHOULD
- MFA

FUTURE
- enterprise SSO / advanced federation
```

------------------------------------------------------------------------

# 43. Priorização interna --- RBAC

``` text
MUST
- standard roles
- scope
- permissions
- sensitive permissions
- backend enforcement

SHOULD
- groups

COULD
- custom roles

FUTURE
- advanced policy builder
```

------------------------------------------------------------------------

# 44. Priorização interna --- Portfolio

``` text
MUST
- projects
- health
- filters
- critical exceptions

SHOULD
- investment consolidation
- advanced trends

COULD
- scoring/prioritization engine

FUTURE
- portfolio optimization
```

------------------------------------------------------------------------

# 45. Priorização interna --- Project

``` text
MUST
- identity
- ownership
- lifecycle
- progress
- baseline
- forecast
- portfolio relation

SHOULD
- configurable project types

COULD
- advanced custom fields

FUTURE
- complex workflow designer
```

------------------------------------------------------------------------

# 46. Priorização interna --- Status

``` text
MUST
- five-step workflow
- draft
- review
- validation
- publish
- delta
- snapshot
- audit

SHOULD
- configurable review workflow

COULD
- custom status templates

FUTURE
- fully configurable workflow builder
```

------------------------------------------------------------------------

# 47. Priorização interna --- RAG

``` text
MUST
- deterministic rules
- explanation
- override
- audit

SHOULD
- configurable thresholds

COULD
- project-type-specific rule packs

FUTURE
- predictive RAG / AI-assisted forecasting
```

------------------------------------------------------------------------

# 48. Priorização interna --- My Day

``` text
MUST
- overdue actions
- critical risks/issues
- missing status
- pending decisions
- upcoming milestones

SHOULD
- dependency alerts
- resource conflicts

COULD
- personalized ranking

FUTURE
- predictive attention engine
```

------------------------------------------------------------------------

# 49. Priorização interna --- Copilot

``` text
SHOULD / first AI release
- Q&A
- summaries
- changes
- risk summary
- executive briefing

COULD
- suggested actions
- structured meeting preparation
- report drafting

FUTURE
- autonomous agents
- simulation
- predictive recommendations
- multi-step autonomous workflows
```

------------------------------------------------------------------------

# 50. Priorização interna --- Reports

``` text
SHOULD
- standard project report
- standard portfolio report
- export

COULD
- configurable layouts
- custom templates
- scheduled reports

FUTURE
- advanced narrative generation
- board-ready automated packs
```

------------------------------------------------------------------------

# 51. Priorização interna --- Financial

``` text
SHOULD
- budget
- actual
- forecast
- variance

COULD
- categories
- advanced breakdown
- imported actuals

FUTURE
- deep financial system integrations
```

------------------------------------------------------------------------

# 52. Priorização interna --- Resources

``` text
SHOULD
- resources
- allocation
- capacity
- overallocation

COULD
- skills
- scenario allocation

FUTURE
- AI optimization
- advanced workforce planning
```

------------------------------------------------------------------------

# 53. Priorização interna --- Documents

``` text
SHOULD
- upload/reference
- classification
- relation to project/entity
- evidence

COULD
- version management
- advanced search

FUTURE
- enterprise knowledge intelligence
```

------------------------------------------------------------------------

# 54. Priorização interna --- Integrations

``` text
MUST
- architecture ready for integration

SHOULD
- import/export

COULD
- one or more execution-tool integrations

FUTURE
- integration marketplace
- bidirectional enterprise sync
```

Não é necessário construir todas as integrações para validar o produto.

------------------------------------------------------------------------

# 55. Prioridade por persona

## PMO Analyst

P0:

``` text
My Day
Portfolio
Projects
Risks
Issues
Actions
Decisions
Status
Dashboards
```

## Project Manager

P0:

``` text
Project
Milestones
Deliverables
Risks
Issues
Actions
Status
```

## Executive

P0:

``` text
Executive Portfolio
Project Dashboard
Decisions
```

## Tenant Admin

P0:

``` text
Users
Access
Tenant Settings
BYOK
```

------------------------------------------------------------------------

# 56. Prioridade por valor

## Valor operacional imediato

-   My Day;
-   Projects;
-   Actions;
-   Risks;
-   Issues;
-   Milestones.

## Valor de governança

-   Status;
-   RAG;
-   Decisions;
-   Audit;
-   Snapshots.

## Valor executivo

-   Project Dashboard;
-   Portfolio Dashboard;
-   Executive Portfolio;
-   Reports.

## Valor de inteligência

-   Copilot;
-   historical comparison;
-   future predictive capabilities.

------------------------------------------------------------------------

# 57. Prioridade por dependência

``` text
Foundation
   ↓
Operational Data
   ↓
Governance
   ↓
History
   ↓
Projection
   ↓
Intelligence
```

Portanto, Copilot não deve preceder a existência de dados confiáveis.

------------------------------------------------------------------------

# 58. Prioridade por risco técnico

Capacidades que devem ser validadas cedo por risco arquitetural:

``` text
Multi-tenancy
RBAC
Snapshot model
Status publication transaction
Tenant isolation
BYOK security
```

Mesmo que algumas não sejam visualmente impressionantes, atrasá-las
aumenta risco de retrabalho.

------------------------------------------------------------------------

# 59. Prioridade por risco de produto

Capacidades que devem ser testadas cedo com usuários:

``` text
My Day
Project Control Center
Status Update
Executive Portfolio
Project Dashboard
```

Elas validam se o produto realmente reduz trabalho e melhora governança.

------------------------------------------------------------------------

# 60. Fora do MVP --- infraestrutura

Não introduzir inicialmente sem necessidade comprovada:

``` text
Redis
Kafka
RabbitMQ
Neo4j
Elasticsearch
Kubernetes
Firebase
```

------------------------------------------------------------------------

# 61. FUTURE --- Advanced AI Agents

Agentes capazes de:

-   executar múltiplos passos;
-   acompanhar projetos autonomamente;
-   criar follow-ups;
-   operar integrações;
-   preparar reuniões automaticamente;

são direção futura.

Não devem ser requisito para MVP.

------------------------------------------------------------------------

# 62. FUTURE --- Predictive Project Intelligence

Possíveis capacidades:

-   previsão de atraso;
-   probabilidade de Milestone slip;
-   previsão de budget variance;
-   risk propagation;
-   anomaly detection.

Dependem de dados históricos suficientes.

------------------------------------------------------------------------

# 63. FUTURE --- Scenario Simulation

Exemplo:

> "O que acontece se adicionarmos duas pessoas ao projeto por seis
> semanas?"

Pode considerar:

-   capacity;
-   schedule;
-   cost;
-   dependencies;
-   risks.

É uma capacidade estratégica, não MVP.

------------------------------------------------------------------------

# 64. FUTURE --- Portfolio Optimization

Possíveis objetivos:

-   maximizar valor;
-   reduzir risco;
-   respeitar capacidade;
-   priorizar investimentos;
-   simular cenários.

Requer maturidade maior do domínio.

------------------------------------------------------------------------

# 65. FUTURE --- Strategy Alignment

Possível relação:

``` text
Strategy
  ↓
Objective
  ↓
Portfolio
  ↓
Project
  ↓
Outcome
```

Pode incluir OKRs no futuro.

Não é necessário para validar o primeiro ciclo de governança.

------------------------------------------------------------------------

# 66. FUTURE --- Benefits Realization

Capacidade de acompanhar se o Project entregou o benefício esperado após
conclusão.

É coerente com a evolução:

``` text
Decision → Action → Outcome
```

mas fica fora do núcleo inicial.

------------------------------------------------------------------------

# 67. O que não priorizar por apelo visual

Evitar priorizar uma feature apenas porque gera uma demonstração visual
impressionante.

Exemplos:

-   gráficos complexos;
-   animações;
-   dezenas de widgets;
-   IA sem dados;
-   mapas sofisticados;
-   simulação sem modelo confiável.

O produto precisa primeiro produzir confiança.

------------------------------------------------------------------------

# 68. O que não priorizar por moda tecnológica

Não adicionar tecnologia apenas por tendência.

Pergunta:

> **"Qual problema real do PMO isso resolve agora?"**

Se a resposta não for clara, a capacidade deve ser adiada.

------------------------------------------------------------------------

# 69. Sequência recomendada de incrementos

## Incremento A --- Secure Foundation

``` text
Authentication
Multi-tenancy
RBAC
Settings foundation
Audit foundation
```

## Incremento B --- Project Core

``` text
Portfolios
Projects
Project Control Center
Milestones
Deliverables
```

## Incremento C --- Governance Core

``` text
Risks
Issues
Actions
Decisions
Dependencies basic
```

## Incremento D --- Status & History

``` text
Status Update
RAG Engine
Snapshots
```

## Incremento E --- Visibility

``` text
My Day
Project Dashboard
Portfolio Dashboard
Executive Portfolio
```

## Incremento F --- Management

``` text
Financial
Resources
Documents
Time Machine
Notifications
```

## Incremento G --- Productivity & Intelligence

``` text
Report Builder
Import/Export
PMO Copilot
```

------------------------------------------------------------------------

# 70. Vertical Slice recomendado

Além da construção por domínio, uma validação precoce deve executar uma
jornada ponta a ponta:

``` text
Create Project
      ↓
Create Milestone
      ↓
Create Risk
      ↓
Create Action
      ↓
Prepare Status
      ↓
Calculate RAG
      ↓
Publish
      ↓
Create Snapshot
      ↓
Show Project Dashboard
      ↓
Show Portfolio impact
```

Esse slice reduz o risco de módulos isolados funcionarem sem integração
real.

------------------------------------------------------------------------

# 71. Critério para promover SHOULD a MUST

Uma capacidade SHOULD pode ser promovida quando:

-   bloquear jornada central;
-   feedback de usuário mostrar dependência;
-   requisito contratual;
-   requisito regulatório;
-   risco técnico;
-   necessidade comercial comprovada.

A mudança deve ser registrada.

------------------------------------------------------------------------

# 72. Critério para remover MUST do MVP

Um MUST só deve sair do MVP se:

1.  a proposta central continuar demonstrável;
2.  não comprometer segurança;
3.  não comprometer integridade histórica;
4.  não criar retrabalho arquitetural significativo;
5.  a decisão estiver registrada.

------------------------------------------------------------------------

# 73. Priorização não altera autorização

Uma feature ser `COULD` ou `FUTURE` não reduz exigências de segurança
quando for implementada.

Todo recurso deve respeitar:

-   Multi-tenancy;
-   RBAC;
-   Data Classification;
-   Audit;
-   Security by Design.

------------------------------------------------------------------------

# 74. Priorização não altera qualidade

MVP não significa:

-   ausência de testes;
-   autorização incompleta;
-   histórico inconsistente;
-   dados inseguros;
-   arquitetura descartável.

A simplificação deve ocorrer no **escopo**, não na integridade.

------------------------------------------------------------------------

# 75. Critério de pronto para entrar no MVP

Uma capability candidata deve possuir:

-   problema claro;
-   persona;
-   jornada;
-   Spec;
-   regras;
-   dados;
-   autorização;
-   Acceptance Criteria;
-   UX suficiente;
-   dependências conhecidas.

------------------------------------------------------------------------

# 76. Critério de sucesso da priorização

A priorização é eficaz se permitir construir primeiro um produto que:

1.  controla Projects;
2.  governa exceções;
3.  publica Status confiável;
4.  preserva histórico;
5.  consolida Portfolio;
6.  apoia decisão;
7.  reduz trabalho manual.

------------------------------------------------------------------------

# 77. Resumo executivo

``` text
MUST
Secure multi-tenant foundation
Project & Portfolio core
Milestones / Deliverables
Risks / Issues / Actions / Decisions
Status
RAG
Snapshots
My Day
Project & Portfolio dashboards
Executive Portfolio
Audit
Settings

SHOULD
Dependencies
Financial
Resources
Documents
Time Machine
Report Builder
Copilot
Notifications
Import / Export
Schedule
Team

COULD
Advanced configuration
Advanced reporting
Custom roles
Custom fields
Advanced resource planning
Execution-tool integrations

FUTURE
Autonomous agents
Predictive intelligence
Scenario simulation
Portfolio optimization
Strategy alignment
Benefits realization
```

------------------------------------------------------------------------

# 78. Relação com MVP Scope

O próximo documento:

``` text
/docs/01-product/mvp-scope.md
```

transformará esta priorização em uma fronteira explícita:

``` text
IN
OUT
PARTIAL
LATER
```

incluindo o que cada módulo entrega na primeira versão.

------------------------------------------------------------------------

# 79. Referências

-   `/docs/01-product/PDD.md`
-   `/docs/01-product/product-vision.md`
-   `/docs/01-product/personas.md`
-   `/docs/01-product/user-journeys.md`
-   `/docs/01-product/functional-map.md`
-   `/docs/01-product/module-catalog.md`
-   `/docs/00-foundation/business-rules.md`
-   `/docs/00-foundation/permission-model.md`
-   `/docs/04-specs/`

------------------------------------------------------------------------

# 80. Status

**Documento:** Feature Prioritization\
**Status:** Under Review\
**Responsabilidade:** priorizar capacidades do PMO Control para orientar
MVP, sequência de entrega e evolução do produto sem comprometer
segurança, governança ou integridade.

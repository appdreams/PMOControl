# PMO Control --- User Journeys

**Documento:** `user-journeys.md`\
**Camada:** Product\
**Status:** Under Review\
**Tipo:** Jornadas ponta a ponta do produto

------------------------------------------------------------------------

## 1. Objetivo

Este documento descreve as principais jornadas ponta a ponta do PMO
Control, conectando personas, módulos, entidades, decisões e resultados.

As jornadas não substituem os fluxos detalhados das Specifications. Elas
mostram como diferentes capacidades do produto trabalham juntas para
entregar valor.

Cada Spec deverá detalhar estados, permissões, validações, APIs,
eventos, edge cases e Acceptance Criteria de sua parte da jornada.

------------------------------------------------------------------------

# 2. Princípio das jornadas

O PMO Control deve minimizar fluxos paralelos e retrabalho.

A direção principal é:

``` text
Execution
   ↓
Update Source Data
   ↓
Governance
   ↓
Consolidation
   ↓
Analysis
   ↓
Decision
   ↓
Action
   ↓
Outcome
```

O usuário não deve precisar reconstruir manualmente a mesma informação
em cada etapa.

------------------------------------------------------------------------

# 3. Macro jornada

``` text
Create / Configure Project
          ↓
Plan
          ↓
Execute
          ↓
Update
          ↓
Monitor
          ↓
Identify Exceptions
          ↓
Govern
          ↓
Publish Status
          ↓
Create Snapshot
          ↓
Portfolio / Executive View
          ↓
Decision
          ↓
Action
          ↓
Follow-up
          ↓
Learn from History
```

------------------------------------------------------------------------

# 4. Personas envolvidas

As jornadas consideram principalmente:

-   PMO Analyst;
-   PMO Lead;
-   Project Manager;
-   Contributor;
-   Executive;
-   Tenant Administrator;
-   Viewer;
-   Platform Administrator.

A autorização real permanece determinada pelo Permission Model.

------------------------------------------------------------------------

# 5. Jornada 01 --- Entrada do PMO no dia de trabalho

## Persona principal

PMO Analyst.

## Objetivo

Identificar rapidamente onde concentrar atenção.

## Trigger

Início do expediente ou retorno ao workspace.

## Fluxo

``` text
Login
  ↓
My Day
  ↓
System consolidates authorized exceptions
  ↓
PMO sees:
  - overdue actions
  - critical risks
  - blocking issues
  - projects without status
  - pending decisions
  - upcoming milestones
  - dependencies
  - resource conflicts
  ↓
PMO prioritizes
  ↓
Open relevant project/item
  ↓
Follow-up / Update / Escalate
```

## Resultado esperado

O PMO começa pelo que exige atenção, não por uma inspeção manual de
todos os projetos.

## Momento de valor

> "Em poucos minutos eu sei onde agir."

------------------------------------------------------------------------

# 6. Jornada 02 --- Atualização operacional do projeto

## Persona principal

Project Manager.

## Personas secundárias

Contributor e PMO.

## Objetivo

Manter o estado operacional atualizado sem reporting duplicado.

## Fluxo

``` text
Project Control Center
      ↓
Review current state
      ↓
Update progress / forecast
      ↓
Update milestones
      ↓
Update deliverables
      ↓
Update risks/issues
      ↓
Update actions
      ↓
Attach evidence
      ↓
Save
      ↓
Derived views refresh
```

## Regra central

A atualização deve ocorrer na entidade fonte.

Exemplo:

``` text
Risk
```

é atualizado no módulo de Risk.

Status, Dashboard e Portfolio consomem esse estado.

## Resultado esperado

O Project Manager não precisa atualizar manualmente um dashboard ou
apresentação separada.

------------------------------------------------------------------------

# 7. Jornada 03 --- Contributor atualiza uma responsabilidade

## Persona principal

Contributor.

## Objetivo

Atualizar rapidamente item atribuído.

## Fluxo

``` text
Notification / My Assignments
        ↓
Open assigned item
        ↓
Read context
        ↓
Update progress/status
        ↓
Add comment/evidence
        ↓
Complete or save
        ↓
Source entity updated
        ↓
PM / PMO views reflect change
```

## Princípio UX

Poucos passos e apenas o contexto necessário.

O Contributor não precisa navegar pelo projeto inteiro.

------------------------------------------------------------------------

# 8. Jornada 04 --- PMO acompanha uma ação vencida

## Persona principal

PMO Analyst.

## Trigger

Action ultrapassa due date sem conclusão.

## Fluxo

``` text
Action becomes overdue
       ↓
System detects exception
       ↓
My Day / Project / Alerts
       ↓
PMO opens Action
       ↓
Checks:
  owner
  origin
  due date
  impact
  related risk/issue/decision
       ↓
Follow-up
       ↓
Owner updates
       ↓
PMO monitors resolution
```

## Resultado

Ação vencida não depende apenas de memória ou planilha paralela.

------------------------------------------------------------------------

# 9. Jornada 05 --- Gestão de risco

## Personas

Project Manager e PMO.

## Objetivo

Identificar, avaliar, tratar e acompanhar risco.

## Fluxo

``` text
Risk identified
      ↓
Create Risk
      ↓
Define owner
      ↓
Assess probability / impact
      ↓
Define response / mitigation
      ↓
Monitor
      ↓
Risk changes
      ↓
Reassess
```

Possíveis caminhos:

``` text
Risk mitigated
   ↓
Close
```

ou:

``` text
Risk materializes
   ↓
Create / Link Issue
   ↓
Preserve Risk → Issue traceability
```

## Resultado

O histórico mostra não apenas o problema atual, mas o risco que o
antecedeu quando aplicável.

------------------------------------------------------------------------

# 10. Jornada 06 --- Issue crítico

## Personas

PM, PMO e eventualmente Executive.

## Trigger

Problema existente compromete projeto.

## Fluxo

``` text
Issue created / escalated
       ↓
Severity evaluated
       ↓
Owner assigned
       ↓
Resolution plan
       ↓
Actions created
       ↓
Impact evaluated
       ↓
RAG may be affected
       ↓
PMO monitors
       ↓
Executive escalation if needed
       ↓
Resolve
       ↓
Preserve history
```

------------------------------------------------------------------------

# 11. Jornada 07 --- Milestone ameaçado

## Personas

Project Manager e PMO.

## Trigger

Forecast, dependencies, risks ou deliverables indicam ameaça.

## Fluxo

``` text
Milestone
   ↓
System / user identifies threat
   ↓
Review dependencies
   ↓
Review deliverables
   ↓
Review risks/issues
   ↓
Update forecast
   ↓
Create recovery actions
   ↓
Assess RAG impact
   ↓
Follow-up
```

## Resultado

Milestone não é apenas uma data; possui contexto operacional para
explicar sua condição.

------------------------------------------------------------------------

# 12. Jornada 08 --- Preparação do Status Update

## Persona principal

Project Manager ou PMO, conforme governança.

## Trigger

Chegada do período de Status.

## Fluxo macro

``` text
Create / Open Status Draft
        ↓
Load current operational data
        ↓
Compare with last published snapshot
        ↓
Highlight changes
        ↓
Review five steps
        ↓
Validate completeness
        ↓
Publish directly after validation when actor has `status.update.publish`; second-person review is future scope
```

------------------------------------------------------------------------

# 13. Jornada 08.1 --- Status Step 1

## Execução e Indicadores

``` text
Open Status
   ↓
Review:
- phase
- reporting date
- responsible
- executive summary
- planned progress
- actual progress
- baseline
- forecast
- budget
- scope
   ↓
System shows consolidated indicators
   ↓
User confirms/updates source data
```

O Status não deve criar valores paralelos quando o dado já possui
entidade fonte.

------------------------------------------------------------------------

# 14. Jornada 08.2 --- Status Step 2

## Marcos e Entregas

``` text
Review milestones
      ↓
Review deliveries
      ↓
Review dependencies
      ↓
Check delays / threats
      ↓
Confirm changes
```

O sistema deve destacar mudanças desde o último Status publicado.

------------------------------------------------------------------------

# 15. Jornada 08.3 --- Status Step 3

## Riscos e Issues

``` text
Review risk profile
      ↓
Review critical/high risks
      ↓
Review open issues
      ↓
Review changes
      ↓
Add/update operational records if needed
      ↓
Confirm
```

------------------------------------------------------------------------

# 16. Jornada 08.4 --- Status Step 4

## Ações e Decisões

``` text
Review actions
      ↓
Identify overdue items
      ↓
Review decisions
      ↓
Identify pending decisions
      ↓
Create/update items if necessary
      ↓
Confirm
```

------------------------------------------------------------------------

# 17. Jornada 08.5 --- Status Step 5

## Resumo e Publicação

``` text
System consolidates
      ↓
Show:
- progress
- deliveries
- milestones
- risks
- issues
- actions
- executive summary
- achievements
- challenges
- next steps
- indicators
      ↓
Calculate / recommend RAG
      ↓
Validate
      ↓
User reviews
      ↓
Publish directly with explicit permission
```

------------------------------------------------------------------------

# 18. Jornada 09 --- Consulta do Status pelo PMO

## Persona

PMO Analyst / PMO Lead.

## Fluxo

PM/PMO autorizado publica diretamente após validar completude. O PMO consulta a publicação e os indicadores, identifica inconsistências e solicita correção ao Project Manager quando necessário. A correção não edita o histórico: usuário com permission `status.update.correct` informa motivo e cria publicação sucessora.

Aprovação/retorno por uma segunda pessoa não integra o fluxo padrão do MVP; pode ser configurada em fase futura.

# 19. Jornada 10 --- Publicação do Status

## Persona

Project Manager com `status.update.publish` explicitamente concedida.

## Fluxo transacional

```text
Draft → Revalidate tenant/scope/permission/version → Validate required data
→ Calculate KPIs and deterministic RAG → Persist Publication + immutable Snapshot + audit/outbox atomically
→ Commit → Update projections/notify asynchronously and idempotently
```

Falha pré-commit não publica dados parciais. Falha pós-commit não desfaz a publicação; jobs são repetidos com segurança. PM/PMO Admin com `status.update.correct` e motivo cria publicação sucessora ligada à anterior.

# 20. Jornada 11 --- RAG Override

## Persona

PMO Admin ou usuário explicitamente autorizado.

## Trigger

Usuário considera que RAG efetivo deve divergir do
calculado/recomendado.

## Fluxo

``` text
Calculated RAG
      ↓
User requests override
      ↓
Permission check
      ↓
Enter justification
      ↓
Confirm
      ↓
Effective RAG updated
      ↓
Audit Event
      ↓
Snapshot preserves:
  calculated
  effective
  reason
  actor
  timestamp
```

------------------------------------------------------------------------

# 21. Jornada 12 --- Consumo executivo do Portfolio

## Persona principal

Executive.

## Objetivo

Identificar exceções e decisões.

## Fluxo

``` text
Executive Portfolio
      ↓
Review portfolio health
      ↓
Identify red/amber projects
      ↓
Review trends / investment / critical risks
      ↓
Review pending decisions
      ↓
Drill into relevant project
      ↓
Understand impact
      ↓
Decide / Request action
```

## Princípio

A tela deve começar por síntese e permitir aprofundamento.

------------------------------------------------------------------------

# 22. Jornada 13 --- Executivo investiga projeto Red

## Persona

Executive.

## Fluxo

``` text
Portfolio shows RED project
      ↓
Open Project Dashboard
      ↓
See:
- why red
- what changed
- impact
- critical risks/issues
- next milestone
- decisions required
      ↓
Optional Time Machine
      ↓
Compare previous status
      ↓
Decision
```

## Resultado

O executivo não precisa pedir ao PMO uma nova apresentação para entender
o contexto básico.

------------------------------------------------------------------------

# 23. Jornada 14 --- Decisão executiva

## Personas

PMO/PM solicita; Executive decide.

## Fluxo

``` text
Decision Request
      ↓
Define:
- context
- options
- impact
- impact of no decision
- deadline
- evidence
- decision maker
      ↓
Executive notified
      ↓
Executive reviews
      ↓
Approve / Reject / Defer
      ↓
Decision recorded
      ↓
Audit
      ↓
Actions may be generated
```

## Resultado

Decisão deixa de existir apenas em reunião, e-mail ou mensagem.

------------------------------------------------------------------------

# 24. Jornada 15 --- Follow-up da decisão

## Personas

PMO e responsáveis.

``` text
Decision made
     ↓
Actions generated
     ↓
Owners assigned
     ↓
Due dates
     ↓
My Day / Notifications
     ↓
Execution
     ↓
Completion
     ↓
Outcome can be evaluated
```

Essa jornada conecta decisão a execução.

------------------------------------------------------------------------

# 25. Jornada 16 --- Time Machine

## Personas

PMO, PMO Lead, Executive.

## Objetivo

Entender evolução histórica.

## Fluxo

``` text
Open Project
      ↓
Time Machine
      ↓
Select published snapshot
      ↓
View historical state
      ↓
Select another snapshot
      ↓
Compare
      ↓
Understand:
- progress change
- RAG change
- risks
- issues
- forecast
- decisions
- milestones
```

## Pergunta central

> **"Como chegamos até aqui?"**

------------------------------------------------------------------------

# 26. Jornada 17 --- Preparação de comitê

## Persona principal

PMO.

## Objetivo

Preparar conteúdo executivo sem reconstrução manual.

## Fluxo

``` text
Select Portfolio / Period
      ↓
System identifies:
- deteriorated projects
- critical risks
- blocking issues
- pending decisions
- milestone threats
- financial deviations
      ↓
PMO reviews
      ↓
Copilot generates draft summary
      ↓
PMO validates
      ↓
Report Builder
      ↓
Committee material
```

## Resultado

O PMO trabalha sobre exceções e narrativa, não sobre copiar/colar dados.

------------------------------------------------------------------------

# 27. Jornada 18 --- Report Builder

## Persona

PMO.

## Fluxo

``` text
Choose report context
      ↓
Choose authorized sections
      ↓
Load current/snapshot data
      ↓
Generate draft
      ↓
Review
      ↓
Optional AI summary
      ↓
Export / Present
```

Toda exportação deve respeitar Data Policies.

------------------------------------------------------------------------

# 28. Jornada 19 --- Pergunta ao PMO Copilot

## Personas

PMO, PM, PMO Lead ou Executive.

## Exemplo

> "Quais projetos merecem minha atenção esta semana?"

## Fluxo

``` text
Question
   ↓
Resolve user authorization context
   ↓
Retrieve authorized data
   ↓
Apply classification / AI policy
   ↓
Analyze
   ↓
Separate facts / inference / recommendation
   ↓
Generate response
   ↓
Offer drill-down / authorized action
```

## Regra

O Copilot não amplia acesso.

------------------------------------------------------------------------

# 29. Jornada 20 --- Copilot prepara resumo executivo

## Persona

PMO.

``` text
Request executive summary
      ↓
Select context / period
      ↓
Retrieve authorized project data
      ↓
Compare with previous state
      ↓
Identify material changes
      ↓
Generate draft
      ↓
PMO reviews/edits
      ↓
Use in Status / Report
```

A saída de IA não se torna automaticamente fonte oficial.

------------------------------------------------------------------------

# 30. Jornada 21 --- Copilot recomenda ação

## Fluxo

``` text
AI identifies condition
      ↓
Recommendation
      ↓
Show evidence / rationale
      ↓
User chooses action
      ↓
Authorization re-check
      ↓
Confirmation
      ↓
Create/update domain entity
      ↓
Audit if applicable
```

Exemplo:

> "Criar uma Action para revisar o plano de recuperação do Milestone
> M4?"

------------------------------------------------------------------------

# 31. Jornada 22 --- Gestão financeira

## Personas

PM, PMO e Executive autorizados.

``` text
Financial
   ↓
Review Budget
   ↓
Review Actual
   ↓
Review Forecast
   ↓
Calculate Variance
   ↓
Threshold exceeded?
   ├── No → continue monitoring
   └── Yes
        ↓
       Exception
        ↓
       Project / Portfolio / Status
```

Dados financeiros só aparecem para usuários autorizados.

------------------------------------------------------------------------

# 32. Jornada 23 --- Gestão de capacidade

## Personas

PMO / PMO Lead / PM autorizados.

``` text
Resources
    ↓
Capacity
    ↓
Allocations
    ↓
Detect overallocation
    ↓
Identify affected projects
    ↓
Review priority / dates
    ↓
Decision / Reallocation
```

------------------------------------------------------------------------

# 33. Jornada 24 --- Documento como evidência

## Personas

PM, PMO e Contributor autorizado.

``` text
Operational Item
      ↓
Attach / Link Document
      ↓
Classify
      ↓
Define context
      ↓
Evidence relationship
      ↓
Authorized users can consume
```

Exemplo:

``` text
Decision
  └── Evidence
       └── Architecture Assessment.pdf
```

------------------------------------------------------------------------

# 34. Jornada 25 --- Entrada de novo usuário

## Persona principal

Tenant Admin.

``` text
Settings
   ↓
Invite User
   ↓
Create / activate Membership
   ↓
Assign Role
   ↓
Assign Scope
   ↓
Apply permissions/policies
   ↓
Invitation
   ↓
User authenticates
   ↓
Authorized workspace
```

------------------------------------------------------------------------

# 35. Jornada 26 --- Mudança de responsabilidade

## Persona

Tenant Admin / authorized administrator.

``` text
User changes responsibility
      ↓
Review current grants
      ↓
Revoke obsolete Scope/Role
      ↓
Grant new Scope/Role
      ↓
Audit
      ↓
Access takes effect
```

A revogação deve impedir acesso indevido persistente.

------------------------------------------------------------------------

# 36. Jornada 27 --- Configuração BYOK

## Persona

Tenant Admin.

``` text
Settings
   ↓
AI Configuration
   ↓
Choose Provider
   ↓
Enter API Key
   ↓
Secure validation
   ↓
Store secret securely
   ↓
Configure model/routing policy
   ↓
Activate
```

A chave não deve ser novamente exibida em texto puro.

------------------------------------------------------------------------

# 37. Jornada 28 --- Importação inicial

## Persona

PMO Admin / Tenant Admin autorizado.

``` text
Choose import
   ↓
Upload / Connect source
   ↓
Validate
   ↓
Map fields
   ↓
Preview
   ↓
Resolve errors
   ↓
Confirm
   ↓
Import
   ↓
Audit / summary
```

Importação deve respeitar Tenant binding e validações.

------------------------------------------------------------------------

# 38. Jornada 29 --- Integração futura com ferramenta de execução

Exemplo conceitual:

``` text
Jira / Azure DevOps
      ↓
Integration
      ↓
Normalize
      ↓
Validate
      ↓
Map to authorized Tenant/Project
      ↓
Update domain data
      ↓
Derived views
```

A autoridade da fonte deve ser definida por integração.

------------------------------------------------------------------------

# 39. Jornada 30 --- Arquivamento de projeto

## Personas

PMO Admin / authorized role.

``` text
Project completed/cancelled
      ↓
Validate pending governance
      ↓
Finalize required Status
      ↓
Preserve history
      ↓
Archive
      ↓
Remove from active operational views
      ↓
Keep authorized historical access
```

Archive não significa apagar histórico.

------------------------------------------------------------------------

# 40. Jornada 31 --- Auditoria de uma alteração

## Persona

Usuário autorizado.

``` text
Question:
"Who changed the RAG?"
      ↓
Audit
      ↓
Locate event
      ↓
Show:
- actor
- timestamp
- previous value
- new value
- reason
- resource
```

------------------------------------------------------------------------

# 41. Jornada 32 --- Suporte excepcional

## Personas

Tenant-authorized actor + Platform Admin.

``` text
Support need identified
      ↓
Explicit authorization
      ↓
Define purpose/scope
      ↓
Grant temporary access
      ↓
Support action
      ↓
Audit
      ↓
Expire / Revoke
```

Platform Admin não recebe acesso automático.

------------------------------------------------------------------------

# 42. Jornada 33 --- Projeto deteriorando

Esta jornada demonstra a conexão entre módulos.

``` text
Deliverable delayed
      ↓
Milestone threatened
      ↓
Forecast changes
      ↓
Risk increases
      ↓
RAG changes Green → Amber
      ↓
My Day highlights project
      ↓
PMO investigates
      ↓
Recovery Action created
      ↓
Status published
      ↓
Portfolio reflects Amber
      ↓
Executive sees trend
```

Essa é uma das jornadas mais importantes para validar a proposta de
valor.

------------------------------------------------------------------------

# 43. Jornada 34 --- Risco materializa e exige decisão

``` text
Risk
 ↓
Materialized
 ↓
Issue
 ↓
Critical impact
 ↓
Decision Request
 ↓
Executive Decision
 ↓
Actions
 ↓
Follow-up
 ↓
Resolution
 ↓
Outcome
```

Representa a cadeia de governança conectada.

------------------------------------------------------------------------

# 44. Jornada 35 --- Do dado à decisão

``` text
STATE
  ↓
Project is Amber

CAUSE
  ↓
Milestone threatened by 3 delayed deliverables

IMPACT
  ↓
Go-live may move 18 days

EVIDENCE
  ↓
Current forecast + dependencies + open issues

SIMULATION
  ↓
What if additional capacity is assigned?

DECISION
  ↓
Approve temporary capacity increase

ACTION
  ↓
Reallocate resources

OUTCOME
  ↓
Forecast recovers / does not recover
```

`SIMULATION` e avaliação avançada de `OUTCOME` representam direção
evolutiva e podem ficar fora do MVP.

------------------------------------------------------------------------

# 45. Pontos de handoff

As jornadas devem reduzir perda de contexto entre pessoas.

Principais handoffs:

``` text
Contributor → Project Manager
Project Manager → PMO
PMO → PMO Lead
PMO Lead → Executive
Executive → Action Owner
```

O contexto relevante deve viajar com o item, não depender exclusivamente
de reunião.

------------------------------------------------------------------------

# 46. Momentos críticos de confiança

## Publicação

O usuário precisa confiar que o Snapshot representa o Status publicado.

## Executive View

O executivo precisa confiar que os números vêm das fontes corretas.

## RAG

O usuário precisa entender por que o estado foi calculado.

## Copilot

O usuário precisa diferenciar fato, inferência e recomendação.

## Time Machine

O usuário precisa confiar que está vendo o estado histórico real.

------------------------------------------------------------------------

# 47. Momentos críticos de autorização

As jornadas devem revalidar autorização em operações consequenciais.

Exemplos:

``` text
Publish Status
Override RAG
Approve Decision
Change Baseline
Export Report
Access Confidential Document
Execute AI-suggested action
```

------------------------------------------------------------------------

# 48. Fricções proibidas

Evitar jornadas que obriguem:

1.  atualizar dashboard manualmente;
2.  duplicar Risk dentro de Status;
3.  copiar Action para outro módulo;
4.  preencher novamente dados já existentes;
5.  reconstruir histórico usando memória;
6.  criar apresentação manual para responder pergunta básica;
7.  expor dados não autorizados em export/Copilot;
8.  abrir todos os Projects para descobrir exceções.

------------------------------------------------------------------------

# 49. Jornada de valor do MVP

O MVP deve provar pelo menos esta sequência:

``` text
Create Project
      ↓
Manage Milestones / Risks / Issues / Actions
      ↓
Update Project
      ↓
Prepare Status
      ↓
Review
      ↓
Publish
      ↓
Snapshot
      ↓
Project Dashboard
      ↓
Portfolio View
      ↓
Executive Insight
```

Esse fluxo é a espinha dorsal do produto.

------------------------------------------------------------------------

# 50. Critérios de qualidade das jornadas

Uma jornada bem implementada deve:

-   possuir fonte de dados clara;
-   evitar duplicação;
-   preservar contexto;
-   respeitar autorização;
-   preservar histórico;
-   produzir feedback ao usuário;
-   tratar falhas;
-   permitir auditoria quando necessário;
-   gerar valor perceptível;
-   possuir Acceptance Criteria nas Specs envolvidas.

------------------------------------------------------------------------

# 51. Mapeamento inicial Jornada × módulos

  -----------------------------------------------------------------------
  Jornada                             Principais módulos
  ----------------------------------- -----------------------------------
  Dia do PMO                          My Day, Portfolio, Notifications

  Atualização do projeto              Project Control Center, Schedule,
                                      Milestones, Deliverables

  Gestão de risco                     Risks, Issues, Actions

  Status                              Status Update, RAG, Snapshots

  Comitê                              Portfolio, Reports, Copilot

  Decisão                             Decisions, Actions, Notifications

  Histórico                           Snapshots, Time Machine

  Financeiro                          Financial, Project, Portfolio

  Capacidade                          Resources, Projects

  Evidência                           Documents, Domain Entities

  Acesso                              Authentication, Multi-tenancy, RBAC

  IA                                  PMO Copilot, AI Configuration

  Auditoria                           Audit Log
  -----------------------------------------------------------------------

------------------------------------------------------------------------

# 52. Mapeamento Jornada × persona

  Jornada                   Persona principal
  ------------------------- -------------------
  My Day                    PMO Analyst
  Atualização operacional   Project Manager
  Assignment                Contributor
  Status Preparation        Project Manager
  Status Review             PMO consultation after publication
  Status Publication        Project Manager with explicit permission
  Portfolio Review          PMO Lead
  Executive Review          Executive
  Decision                  Executive
  Committee Preparation     PMO
  Time Machine              PMO / Executive
  Tenant Configuration      Tenant Admin
  Platform Support          Platform Admin

------------------------------------------------------------------------

# 53. Relação com Specifications

As jornadas serão decompostas em Specs.

Exemplo:

``` text
Journey: Publish Status
```

envolve:

``` text
003-rbac
005-projects
014-status-update
015-rag-engine
016-snapshots
019-portfolio-dashboard
026-notifications
027-audit-log
```

Uma jornada pode atravessar várias Specs.

------------------------------------------------------------------------

# 54. Relação com Functional Map

`functional-map.md` transformará estas jornadas em um mapa das
capacidades funcionais do produto.

As jornadas descrevem:

> **como o valor flui.**

O Functional Map descreverá:

> **quais capacidades sustentam esse fluxo.**

------------------------------------------------------------------------

# 55. Relação com UX

As imagens de `/docs/05-ux/screens/` representam pontos específicos
dentro dessas jornadas.

Elas não substituem a jornada completa.

Exemplo:

``` text
status-update/05-summary-publication-reference.png
```

representa uma etapa da Jornada de Status, não todo o processo.

------------------------------------------------------------------------

# 56. Relação com eventos

Jornadas importantes devem produzir eventos de domínio quando
apropriado.

Exemplo:

``` text
StatusPublished
SnapshotCreated
DecisionMade
ActionOverdue
RiskMaterialized
```

Eventos detalhados serão definidos nas Specs/arquitetura.

------------------------------------------------------------------------

# 57. Relação com métricas

As jornadas devem permitir medir eficiência e resultado.

Exemplos:

-   tempo entre atualização e publicação;
-   tempo de preparação de Status;
-   tempo até decisão;
-   percentual de Actions vencidas;
-   tempo de resolução de Issue;
-   percentual de projetos com Status em dia.

As métricas serão formalizadas em `success-metrics.md`.

------------------------------------------------------------------------

# 58. Invariantes das jornadas

1.  Atualizar a fonte correta uma única vez.
2.  Dashboard não é fonte primária.
3.  Status não duplica entidades operacionais.
4.  Publicação preserva histórico.
5.  Snapshot é imutável.
6.  Copilot respeita autorização.
7.  Ação de IA relevante exige confirmação.
8.  Executive View privilegia decisão.
9.  PMO trabalha por exceção.
10. Project Manager não deve repetir reporting desnecessariamente.
11. Contributor recebe contexto mínimo necessário.
12. Decisão deve poder gerar ação.
13. Risk materializado deve preservar vínculo com Issue quando
    aplicável.
14. Archive não elimina histórico.
15. Handoffs devem preservar contexto.

------------------------------------------------------------------------

# 59. Referências

-   `/docs/01-product/PDD.md`
-   `/docs/01-product/product-vision.md`
-   `/docs/01-product/personas.md`
-   `/docs/00-foundation/domain-model.md`
-   `/docs/00-foundation/business-rules.md`
-   `/docs/00-foundation/permission-model.md`
-   `/docs/00-foundation/data-classification.md`
-   `/docs/05-ux/screens/`

------------------------------------------------------------------------

# 60. Status

**Documento:** User Journeys\
**Status:** Under Review\
**Responsabilidade:** definir as principais jornadas ponta a ponta que
conectam personas, módulos, governança, inteligência e decisão no PMO
Control.

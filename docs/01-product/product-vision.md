# PMO Control --- Product Vision

**Documento:** `product-vision.md`\
**Camada:** Product\
**Status:** Under Review\
**Tipo:** Visão estratégica do produto

------------------------------------------------------------------------

## 1. Objetivo

Este documento estabelece a visão estratégica do PMO Control e traduz o
PDD em uma direção de produto clara para design, arquitetura,
Specifications e desenvolvimento.

Ele responde principalmente:

-   qual problema o PMO Control resolve;
-   para quem o produto existe;
-   qual transformação pretende produzir;
-   quais princípios orientam sua evolução;
-   como o produto se diferencia;
-   quais resultados devem ser perseguidos;
-   quais limites não devem ser ultrapassados.

Este documento não substitui `/docs/01-product/PDD.md`.

------------------------------------------------------------------------

# 2. Visão do produto

> **Transformar a governança de projetos de TI de um processo
> fragmentado, manual e reativo em um sistema operacional de gestão,
> controle e inteligência para PMOs.**

O PMO Control deve permitir que organizações acompanhem projetos e
portfólios utilizando uma fonte operacional confiável, com governança,
rastreabilidade, automação e inteligência incorporadas ao fluxo de
trabalho.

O objetivo não é apenas produzir dashboards.

O objetivo é estruturar o ciclo completo:

``` text
Execution
   ↓
Operational Update
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

------------------------------------------------------------------------

# 3. Problema

Em muitas organizações, a governança de projetos depende de uma
combinação de:

-   planilhas;
-   apresentações;
-   e-mails;
-   mensagens;
-   ferramentas de tarefas;
-   ferramentas de cronograma;
-   documentos;
-   reuniões;
-   controles paralelos.

As informações existem, mas permanecem fragmentadas.

O PMO precisa frequentemente:

1.  cobrar atualização;
2.  localizar informações;
3.  validar dados;
4.  consolidar planilhas;
5.  montar apresentações;
6.  comparar versões;
7.  identificar atrasos;
8.  acompanhar riscos;
9.  cobrar ações;
10. preparar reuniões;
11. responder perguntas executivas.

Grande parte do esforço é consumida na preparação da informação, não na
governança.

------------------------------------------------------------------------

# 4. Sintoma central

O problema não é simplesmente:

> "faltam dashboards".

O problema é:

> **dados demais, contexto de menos e governança fragmentada.**

Um dashboard bonito alimentado por dados inconsistentes apenas apresenta
inconsistência de maneira mais elegante.

O PMO Control deve atuar antes do dashboard.

------------------------------------------------------------------------

# 5. Hipótese do produto

Se a organização registrar e governar informações de projeto em
entidades operacionais estruturadas, com responsabilidades, histórico,
workflows e regras claras, então o sistema poderá automaticamente
produzir:

-   dashboards;
-   alertas;
-   reports;
-   snapshots;
-   histórico;
-   indicadores;
-   priorização;
-   contexto executivo;
-   inteligência para decisão.

Assim:

> **o dashboard passa a ser consequência da operação, e não uma
> atividade manual do PMO.**

------------------------------------------------------------------------

# 6. Transformação desejada

## Antes

``` text
Execution Areas
     ↓
Messages / Spreadsheets / Meetings
     ↓
PMO manually collects
     ↓
PMO manually consolidates
     ↓
PMO creates presentation
     ↓
Leadership receives stale information
```

## Depois

``` text
Execution Areas update
     ↓
PMO governs
     ↓
PMO Control consolidates
     ↓
System identifies exceptions
     ↓
Leadership receives current context
     ↓
Decision
     ↓
Action
```

Princípio:

> **Execution updates → PMO governs → System consolidates → Leadership
> decides.**

------------------------------------------------------------------------

# 7. Product Vision Statement

Para organizações que precisam governar múltiplos projetos de
tecnologia, o **PMO Control** é uma plataforma de governança e
inteligência de projetos que transforma atualizações operacionais em
visão executiva, histórico confiável e apoio à decisão.

Diferentemente de ferramentas focadas apenas em tarefas, cronogramas ou
dashboards, o PMO Control conecta:

``` text
Portfolio
Projects
Execution
Risks
Issues
Actions
Decisions
Status
Financial
Resources
Evidence
History
AI
```

em um único modelo operacional de governança.

------------------------------------------------------------------------

# 8. Público principal

O produto é orientado principalmente para:

-   PMOs de Tecnologia;
-   PMO Managers;
-   Project Managers;
-   Program Managers;
-   Portfolio Managers;
-   líderes de Tecnologia;
-   CIOs;
-   Heads de áreas;
-   executivos responsáveis por portfólios;
-   organizações com múltiplos projetos e necessidade de governança.

------------------------------------------------------------------------

# 9. Usuário central

Embora existam diferentes personas, o usuário operacional central é o
profissional de PMO.

O produto deve responder diariamente à pergunta:

> **"Onde preciso colocar minha atenção agora?"**

Em vez de obrigar o PMO a abrir projeto por projeto, o sistema deve
identificar exceções.

Exemplos:

-   projetos sem Status atualizado;
-   ações vencidas;
-   riscos críticos;
-   issues bloqueadores;
-   decisões pendentes;
-   milestones ameaçados;
-   dependências críticas;
-   conflitos de recursos;
-   desvios financeiros;
-   deterioração do RAG.

------------------------------------------------------------------------

# 10. Usuário executivo

Para executivos, a pergunta é diferente:

> **"O que exige decisão ou intervenção?"**

A experiência executiva deve privilegiar:

-   síntese;
-   tendência;
-   impacto;
-   exceções;
-   riscos;
-   investimentos;
-   decisões;
-   próximos marcos.

O produto não deve transformar a visão executiva em uma réplica da tela
operacional do PMO.

------------------------------------------------------------------------

# 11. Proposta de valor

O PMO Control entrega valor em cinco dimensões.

## 11.1 Controle

Centraliza informações essenciais para acompanhar projetos.

## 11.2 Governança

Estrutura responsabilidades, workflows, aprovações, evidências e
histórico.

## 11.3 Visibilidade

Transforma dados operacionais em visão de projeto, portfólio e
executivo.

## 11.4 Inteligência

Identifica padrões, mudanças, exceções e possíveis impactos.

## 11.5 Decisão

Organiza o contexto necessário para que gestores e executivos tomem
decisões melhores e mais rápidas.

------------------------------------------------------------------------

# 12. Princípio --- Update Once, Propagate Everywhere

Uma informação operacional deve ser atualizada em sua fonte correta uma
única vez.

Exemplo:

``` text
Risk updated
     ↓
Project Control Center
     ↓
My Day
     ↓
Status Update
     ↓
Portfolio
     ↓
Executive View
     ↓
Report
     ↓
Copilot Context
```

O sistema não deve exigir que o PMO replique manualmente a mesma
informação em múltiplos lugares.

------------------------------------------------------------------------

# 13. Princípio --- Single Source of Operational Truth

Entidades como:

-   Risk;
-   Issue;
-   Action;
-   Decision;
-   Milestone;
-   Deliverable;

são fontes operacionais.

Dashboards, reports e Status Updates consomem essas fontes.

Eles não devem criar versões paralelas desnecessárias das mesmas
informações.

------------------------------------------------------------------------

# 14. Princípio --- Governance by Exception

O PMO Control deve reduzir trabalho de inspeção manual.

O sistema deve ajudar a priorizar:

``` text
What changed?
What is late?
What is blocked?
What is critical?
What needs a decision?
What may compromise the next milestone?
```

A operação ideal não é:

> abrir todos os projetos.

É:

> trabalhar primeiro nas exceções que exigem atenção.

------------------------------------------------------------------------

# 15. Princípio --- Reliable History

A governança precisa responder:

> "O que sabíamos naquele momento?"

Por isso, Status publicado gera Snapshot.

O histórico não pode ser reconstruído apenas usando o estado atual das
entidades.

Esse princípio sustenta:

-   Time Machine;
-   auditoria;
-   comparação;
-   análise de evolução;
-   explicação de decisões.

------------------------------------------------------------------------

# 16. Princípio --- Evidence over Opinion

Sempre que possível, informações relevantes devem poder ser sustentadas
por:

-   dados;
-   documentos;
-   evidências;
-   histórico;
-   eventos;
-   decisões registradas.

A plataforma deve ajudar a diferenciar percepção de fato observável.

------------------------------------------------------------------------

# 17. Princípio --- Decision-Oriented Product

O objetivo final da governança não é gerar informação.

É permitir decisão e ação.

A evolução do produto deve aproximar-se da cadeia:

``` text
STATE
  ↓
CAUSE
  ↓
IMPACT
  ↓
EVIDENCE
  ↓
SIMULATION
  ↓
DECISION
  ↓
ACTION
  ↓
OUTCOME
```

Essa cadeia representa a direção de longo prazo da inteligência do PMO
Control.

------------------------------------------------------------------------

# 18. Princípio --- Human-in-the-Loop

IA deve ampliar a capacidade humana, não assumir silenciosamente
decisões de governança.

O sistema pode:

-   analisar;
-   resumir;
-   recomendar;
-   priorizar;
-   detectar;
-   explicar;
-   simular.

Operações consequenciais devem respeitar:

``` text
Recommendation
     ↓
Human Review
     ↓
Authorization
     ↓
Confirmation / Approval
     ↓
Execution
```

------------------------------------------------------------------------

# 19. Princípio --- AI Does Not Expand Access

A IA não constitui um canal privilegiado de acesso.

Se o usuário não pode acessar determinada informação pela aplicação, o
PMO Copilot também não pode revelá-la.

------------------------------------------------------------------------

# 20. Princípio --- Explainability

Indicadores relevantes devem ser explicáveis.

Exemplo:

Em vez de apenas:

``` text
Project Health: RED
```

o produto deve conseguir explicar:

``` text
RED because:
- forecast delay: +21 days
- 1 critical milestone at risk
- 2 blocking issues
- budget variance: +8%
```

A mesma lógica deve orientar recomendações de IA.

------------------------------------------------------------------------

# 21. Princípio --- Auditability by Design

Governança sem rastreabilidade perde confiança.

Operações relevantes devem preservar:

-   ator;
-   ação;
-   data/hora;
-   contexto;
-   alteração;
-   justificativa quando necessária.

Auditoria deve ser parte do desenho do produto.

------------------------------------------------------------------------

# 22. Princípio --- Security by Default

Multi-tenancy e autorização não são funcionalidades complementares.

São fundamentos do produto.

Acesso efetivo:

``` text
Tenant
+
Role
+
Scope
+
Permission
+
Data Policy
+
Workflow Rule
```

------------------------------------------------------------------------

# 23. Princípio --- Progressive Complexity

O produto deve suportar governança sofisticada sem exigir complexidade
desnecessária desde o primeiro uso.

Uma organização deve conseguir começar com:

``` text
Portfolio
Projects
Milestones
Risks
Actions
Status
```

e evoluir para:

``` text
Financial
Resources
Advanced Workflows
Integrations
AI
Simulation
Advanced Governance
```

------------------------------------------------------------------------

# 24. Princípio --- Configuration over Forking

Variações entre organizações devem ser atendidas preferencialmente por
configuração governada, não por versões customizadas do produto.

Exemplos futuros:

-   RAG thresholds;
-   workflows;
-   taxonomies;
-   notification rules;
-   project types;
-   custom fields;
-   AI providers.

------------------------------------------------------------------------

# 25. Core Loop do produto

O ciclo principal é:

``` text
PLAN
 ↓
EXECUTE
 ↓
UPDATE
 ↓
GOVERN
 ↓
CONSOLIDATE
 ↓
ANALYZE
 ↓
DECIDE
 ↓
ACT
 ↓
LEARN
 ↺
```

Cada módulo deve contribuir para uma ou mais etapas desse ciclo.

------------------------------------------------------------------------

# 26. Fluxo diário do PMO

A experiência diária deve favorecer:

``` text
Meu Dia
  ↓
Exceptions
  ↓
Project / Item
  ↓
Update / Follow-up
  ↓
Resolution / Decision
  ↓
Status Consolidation
```

O PMO Control deve diminuir o tempo entre identificação do problema e
ação de governança.

------------------------------------------------------------------------

# 27. Fluxo semanal

Uma referência operacional:

``` text
Monday
Portfolio / priorities / milestones

Tuesday
Actions / risks / issues / dependencies

Wednesday
Project / owner follow-up

Thursday
Status meetings / updates

Friday
Status close / reports / portfolio
```

O produto não deve impor essa agenda, mas deve suportar esse tipo de
operação naturalmente.

------------------------------------------------------------------------

# 28. Reuniões de Status

Durante reuniões, o PMO deve conseguir atualizar diretamente as
entidades reais.

Evitar:

``` text
Meeting Notes
    ↓
Later transcription
    ↓
Spreadsheet
    ↓
Dashboard
```

Preferir:

``` text
Meeting
   ↓
Update Risk / Issue / Action / Decision
   ↓
System immediately reflects new state
```

------------------------------------------------------------------------

# 29. Status Update como mecanismo de governança

Status Update não é formulário isolado.

Ele funciona como checkpoint de governança.

O processo:

``` text
Load current operational state
      ↓
Show changes since previous publication
      ↓
Review execution
      ↓
Review milestones/deliverables
      ↓
Review risks/issues
      ↓
Review actions/decisions
      ↓
Review summary
      ↓
Calculate KPIs/RAG
      ↓
Publish
      ↓
Snapshot
```

------------------------------------------------------------------------

# 30. Valor do Snapshot

O Snapshot transforma uma atualização de Status em registro histórico
confiável.

Permite responder:

-   qual era o progresso;
-   qual era o Forecast;
-   quais riscos existiam;
-   quais issues estavam abertas;
-   quais decisões estavam pendentes;
-   qual era o RAG;
-   quais eram os próximos marcos;
-   qual era a situação financeira.

------------------------------------------------------------------------

# 31. Time Machine

Time Machine deve permitir navegar pelo histórico publicado do projeto.

Pergunta central:

> **"Como o projeto chegou até aqui?"**

Não é apenas histórico técnico.

É histórico de governança.

------------------------------------------------------------------------

# 32. PMO Copilot

O Copilot é uma camada transversal de inteligência.

Ele não deve ser tratado apenas como uma tela de chat.

Deve poder apoiar o PMO em contextos específicos.

Exemplos:

> Quais projetos merecem minha atenção esta semana?

> O que mudou no ERP desde o último Status?

> Quais riscos podem comprometer os marcos deste mês?

> Prepare os cinco pontos para o comitê.

> Gere o resumo executivo desta semana.

------------------------------------------------------------------------

# 33. Copilot proativo

A direção futura inclui insights proativos.

Exemplo:

``` text
Observation:
Milestone M4 is due in 12 days.

Evidence:
3 dependent deliverables are incomplete.

Risk:
Current completion rate suggests schedule pressure.

Recommendation:
Review owners and recovery plan before Thursday's committee.
```

O sistema deve separar:

``` text
Fact
Inference
Recommendation
```

------------------------------------------------------------------------

# 34. Diferencial 1 --- Governança conectada à execução

Ferramentas de tarefas normalmente respondem:

> "O que está sendo feito?"

O PMO Control também precisa responder:

> "O que isso significa para o projeto e para o portfólio?"

------------------------------------------------------------------------

# 35. Diferencial 2 --- Histórico executivo confiável

O produto preserva estados publicados e não apenas o estado atual.

Isso permite:

-   comparação temporal;
-   accountability;
-   análise de tendência;
-   investigação de decisões;
-   aprendizado organizacional.

------------------------------------------------------------------------

# 36. Diferencial 3 --- Inteligência contextual

O Copilot trabalha sobre o contexto estruturado do domínio.

Não apenas documentos soltos.

Exemplo:

``` text
Project
+ Milestones
+ Risks
+ Issues
+ Actions
+ Decisions
+ Financial
+ History
```

produzem contexto mais útil para análise.

------------------------------------------------------------------------

# 37. Diferencial 4 --- Governance Operating System

A visão de longo prazo não é ser apenas:

``` text
Dashboard Tool
```

nem:

``` text
Task Manager
```

nem:

``` text
Project Report Generator
```

Mas:

> **um Project Governance Operating System.**

------------------------------------------------------------------------

# 38. Diferencial 5 --- Segurança e governança incorporadas

Multi-tenancy, RBAC, Scope, Data Policies, Audit e AI authorization
fazem parte do modelo central.

Isso permite que a plataforma evolua para ambientes corporativos com
maior exigência de governança.

------------------------------------------------------------------------

# 39. Capacidades centrais

O produto organiza suas capacidades em torno de:

### Governança de portfólio

-   Portfolio;
-   Executive Portfolio;
-   priorização;
-   saúde consolidada.

### Controle de projeto

-   Project Control Center;
-   Schedule;
-   Milestones;
-   Deliverables;
-   Dependencies.

### Governança operacional

-   Risks;
-   Issues;
-   Actions;
-   Decisions.

### Governança periódica

-   Status Update;
-   RAG;
-   Snapshots;
-   Time Machine.

### Gestão

-   Financial;
-   Team;
-   Resources/Capacity;
-   Documents/Evidence.

### Inteligência

-   My Day;
-   Dashboards;
-   Report Builder;
-   PMO Copilot.

### Administração

-   Authentication;
-   Multi-tenancy;
-   RBAC;
-   Notifications;
-   Audit;
-   Settings;
-   Import/Export;
-   Integrations.

------------------------------------------------------------------------

# 40. O que o produto não deve se tornar

## Não é um clone genérico de Jira

Pode integrar ou coexistir com ferramentas de execução.

## Não é um ERP financeiro

Financeiro existe para governança de projetos.

## Não é um HRIS

Recursos existem para capacidade e alocação relacionadas a projetos.

## Não é um DMS completo

Documents existe para conhecimento, evidência e governança do projeto.

## Não é apenas um chatbot

IA deve estar integrada ao domínio e ao workflow.

## Não é apenas BI

Dashboards são uma projeção do sistema operacional.

------------------------------------------------------------------------

# 41. Integrações como estratégia

O produto deve evoluir para integrar fontes externas em vez de exigir
substituição imediata de todas as ferramentas existentes.

Possíveis fontes futuras:

-   Jira;
-   Azure DevOps;
-   Microsoft Project;
-   Excel;
-   APIs corporativas;
-   sistemas financeiros;
-   ferramentas de documentos.

Princípio:

> **PMO Control deve consolidar governança sem obrigatoriamente
> substituir toda a execução.**

------------------------------------------------------------------------

# 42. MVP tecnológico

Stack definido:

``` text
Frontend / Application
Next.js + TypeScript

Hosting
Vercel

Database / Auth / Storage
Supabase

Background Jobs
Inngest

Source Control
GitHub

Email
Existing SMTP / configurable

AI
BYOK per Tenant
```

------------------------------------------------------------------------

# 43. Fora do MVP tecnológico

Não introduzir sem necessidade comprovada:

``` text
Redis
Kafka
RabbitMQ
Neo4j
Elasticsearch
Kubernetes
Firebase
```

A complexidade arquitetural deve ser justificada por necessidade real.

------------------------------------------------------------------------

# 44. Filosofia do MVP

MVP não significa produto superficial.

Significa entregar o menor conjunto coerente capaz de validar a proposta
central.

O MVP deve demonstrar o ciclo:

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

# 45. Resultado esperado para o PMO

O PMO deve gastar menos tempo em:

-   consolidar planilhas;
-   procurar informação;
-   montar slides manualmente;
-   comparar versões;
-   perguntar repetidamente pelo mesmo dado.

E mais tempo em:

-   analisar;
-   antecipar;
-   priorizar;
-   facilitar decisões;
-   remover impedimentos;
-   melhorar governança.

------------------------------------------------------------------------

# 46. Resultado esperado para Project Managers

Project Managers devem possuir um caminho claro para:

-   atualizar execução;
-   registrar desvios;
-   acompanhar milestones;
-   registrar riscos/issues;
-   responder ações;
-   preparar Status;
-   fornecer evidências.

Sem necessidade de manter múltiplos controles redundantes.

------------------------------------------------------------------------

# 47. Resultado esperado para executivos

Executivos devem receber:

-   menos informação irrelevante;
-   mais contexto;
-   exceções;
-   tendências;
-   impacto;
-   decisões necessárias;
-   evidências.

Pergunta orientadora:

> **"O que preciso saber e decidir agora?"**

------------------------------------------------------------------------

# 48. Resultado esperado para a organização

O PMO Control deve contribuir para:

-   maior confiabilidade dos dados;
-   melhor rastreabilidade;
-   menor tempo de consolidação;
-   identificação antecipada de problemas;
-   melhor qualidade de decisões;
-   histórico organizacional;
-   padronização de governança;
-   maior transparência do portfólio.

------------------------------------------------------------------------

# 49. North Star conceitual

Uma métrica única definitiva será estabelecida em `success-metrics.md`.

Como direção conceitual, o produto deve maximizar:

> **a proporção de decisões e ações de governança realizadas com
> contexto atualizado, confiável e rastreável.**

Isso é mais importante do que simplesmente medir número de dashboards
visualizados ou registros criados.

------------------------------------------------------------------------

# 50. Anti-métricas

O produto não deve otimizar isoladamente:

-   número de campos preenchidos;
-   número de relatórios gerados;
-   quantidade de notificações;
-   quantidade de mensagens do Copilot;
-   tempo gasto dentro da aplicação.

Mais uso não significa necessariamente mais valor.

------------------------------------------------------------------------

# 51. Princípios de UX

A experiência deve ser:

-   executiva;
-   clara;
-   densa sem ser poluída;
-   orientada a exceções;
-   consistente;
-   rápida para operação recorrente.

Desktop widescreen é a prioridade inicial para experiências complexas de
PMO.

------------------------------------------------------------------------

# 52. Identidade visual

Direção visual:

-   navy/grafite profundo;
-   azul/ciano elétrico;
-   roxo para IA/decisões;
-   verde para saudável/concluído;
-   âmbar para atenção;
-   vermelho para crítico;
-   cards arredondados;
-   bordas sutis;
-   glow moderado;
-   alta legibilidade.

A identidade visual deve comunicar:

``` text
Control
Intelligence
Trust
Technology
Governance
```

------------------------------------------------------------------------

# 53. Critério de simplicidade

Uma funcionalidade deve justificar sua complexidade.

Antes de adicionar infraestrutura, workflow ou configuração, perguntar:

1.  resolve problema real?
2.  melhora governança?
3.  reduz trabalho manual?
4.  aumenta confiança?
5.  melhora decisão?
6.  é necessária agora?

Se não, pode pertencer a uma fase posterior.

------------------------------------------------------------------------

# 54. Critério de automação

Automatizar tarefas repetitivas que não exigem julgamento humano.

Exemplos:

-   consolidação;
-   cálculo;
-   detecção de atraso;
-   comparação;
-   alerta;
-   geração de resumo;
-   atualização de projeções.

Preservar julgamento humano em:

-   decisões;
-   aprovações;
-   exceções;
-   overrides;
-   interpretação estratégica.

------------------------------------------------------------------------

# 55. Critério de inteligência

IA deve ser utilizada quando adicionar capacidade que regras
determinísticas isoladas não entregam bem.

Exemplos:

-   sumarização;
-   análise contextual;
-   identificação de padrões;
-   explicação;
-   recomendação;
-   perguntas em linguagem natural.

Não usar IA onde uma regra simples e auditável for superior.

------------------------------------------------------------------------

# 56. Critério de confiança

O usuário deve conseguir responder:

``` text
Where did this number come from?
Why is this project red?
What changed?
Who changed it?
When?
What evidence supports this?
What is fact and what is AI inference?
```

Se o sistema não consegue responder, existe déficit de confiança.

------------------------------------------------------------------------

# 57. Estratégia de evolução

A evolução deve ocorrer em camadas.

``` text
Foundation
   ↓
Operational Control
   ↓
Governance
   ↓
Portfolio Intelligence
   ↓
AI Assistance
   ↓
Predictive Intelligence
   ↓
Simulation / Decision Intelligence
```

Não antecipar complexidade avançada antes da qualidade dos dados
operacionais.

------------------------------------------------------------------------

# 58. Visão futura

Em maturidade avançada, o PMO Control deve ser capaz de responder não
apenas:

> "Qual é o estado do projeto?"

mas:

> "Por que chegamos a esse estado?"

> "Qual será o impacto se nada mudar?"

> "Quais alternativas existem?"

> "Qual decisão produz o melhor cenário?"

> "A decisão tomada gerou o resultado esperado?"

Essa evolução transforma reporting em inteligência de governança.

------------------------------------------------------------------------

# 59. Guardrails de produto

O PMO Control não deve:

1.  duplicar informação sem necessidade;
2.  esconder lógica crítica;
3.  permitir que IA amplie acesso;
4.  permitir edição silenciosa de histórico publicado;
5.  transformar dashboard em fonte primária;
6.  depender de preenchimento manual redundante;
7.  confundir Risk com Issue;
8.  confundir Baseline com Forecast;
9.  confundir recomendação de IA com fato;
10. sacrificar auditabilidade por conveniência.

------------------------------------------------------------------------

# 60. Perguntas para avaliação de novas features

Toda nova feature deve responder:

1.  Qual problema resolve?
2.  Qual persona se beneficia?
3.  Em qual etapa do Core Loop atua?
4.  Qual entidade é fonte da informação?
5.  Evita duplicação?
6.  Qual impacto na governança?
7.  Qual impacto em autorização?
8.  Qual classificação dos dados?
9.  Precisa de auditoria?
10. IA realmente agrega valor?
11. Pertence ao MVP?
12. Como seu sucesso será medido?

------------------------------------------------------------------------

# 61. Relação com outros documentos

Este documento orienta:

``` text
personas.md
user-journeys.md
functional-map.md
module-catalog.md
feature-prioritization.md
mvp-scope.md
success-metrics.md
roadmap.md
```

As Specifications devem permanecer coerentes com esta visão.

------------------------------------------------------------------------

# 62. Invariantes da visão

1.  PMO Control é um sistema de governança, não apenas reporting.
2.  Dados operacionais são fonte primária.
3.  Dashboards são projeções.
4.  Status publicado preserva histórico.
5.  Governança deve ser orientada a exceções.
6.  Executivo recebe síntese, não excesso operacional.
7.  IA amplia análise, não autorização.
8.  Decisões relevantes permanecem humanas e auditáveis.
9.  Segurança e multi-tenancy são fundamentos.
10. Complexidade deve ser introduzida progressivamente.
11. Automação deve reduzir trabalho manual.
12. Inteligência deve melhorar decisão.
13. O produto deve preservar contexto e evidência.
14. A evolução deve partir de dados confiáveis.
15. O produto deve aproximar execução, governança e decisão.

------------------------------------------------------------------------

# 63. Referências

-   `/docs/01-product/PDD.md`
-   `/docs/00-foundation/README.md`
-   `/docs/00-foundation/glossary.md`
-   `/docs/00-foundation/domain-model.md`
-   `/docs/00-foundation/business-rules.md`
-   `/docs/00-foundation/permission-model.md`
-   `/docs/00-foundation/data-classification.md`
-   `/docs/00-foundation/conventions.md`

------------------------------------------------------------------------

# 64. Status

**Documento:** Product Vision\
**Status:** Under Review\
**Responsabilidade:** estabelecer a visão estratégica, proposta de
valor, princípios, diferenciais e direção de evolução do PMO Control.

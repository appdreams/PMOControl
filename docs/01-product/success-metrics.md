# PMO Control --- Success Metrics

**Documento:** `success-metrics.md`\
**Camada:** Product\
**Status:** Under Review\
**Tipo:** Métricas de sucesso do produto e do MVP

------------------------------------------------------------------------

## 1. Objetivo

Este documento define como o PMO Control medirá se está cumprindo sua
proposta de valor.

O objetivo não é criar uma coleção extensa de métricas, mas estabelecer
um sistema que permita responder:

> **O PMO Control está reduzindo esforço manual, aumentando a
> confiabilidade da governança e melhorando a velocidade e a qualidade
> das decisões?**

As métricas deste documento orientam:

-   validação do MVP;
-   evolução do produto;
-   priorização;
-   experimentos;
-   acompanhamento de adoção;
-   qualidade operacional;
-   governança;
-   inteligência futura.

------------------------------------------------------------------------

# 2. Princípio central

O sucesso do produto não deve ser medido apenas por:

``` text
Logins
Page Views
Clicks
Number of Projects
Number of AI Prompts
```

Essas métricas podem indicar uso, mas não demonstram valor.

O PMO Control deve priorizar:

``` text
Outcome > Activity
```

------------------------------------------------------------------------

# 3. Cadeia de valor mensurável

``` text
Structured Updates
       ↓
Fresh Data
       ↓
Reliable Governance
       ↓
Faster Consolidation
       ↓
Earlier Exception Detection
       ↓
Faster Decisions
       ↓
Better Follow-through
       ↓
Better Project Outcomes
```

As métricas devem observar diferentes pontos dessa cadeia.

------------------------------------------------------------------------

# 4. North Star Metric proposta

## Trusted Governance Coverage --- TGC

Percentual de Projects ativos que possuem um estado de governança
considerado atual, completo e confiável.

Conceitualmente:

``` text
TGC =
Active Projects with Trusted Governance State
------------------------------------------------
Total Active Projects
× 100
```

Um Project só entra no numerador quando atende critérios mínimos
definidos, por exemplo:

-   Status dentro da janela esperada;
-   informações essenciais completas;
-   RAG calculado;
-   owners definidos para exceções relevantes;
-   publicação válida;
-   sem inconsistências críticas conhecidas.

------------------------------------------------------------------------

# 5. Por que TGC

A métrica representa melhor o propósito do produto do que simplesmente
contar Projects cadastrados.

Um Portfolio com:

``` text
100 Projects registered
```

mas apenas:

``` text
25 Projects with current trusted information
```

não possui governança efetiva de 100 Projects.

Sua cobertura confiável é próxima de 25%.

------------------------------------------------------------------------

# 6. TGC não substitui métricas auxiliares

A North Star precisa ser explicada por métricas de:

-   adoption;
-   freshness;
-   completeness;
-   reporting efficiency;
-   exception management;
-   decision flow;
-   action execution;
-   executive consumption;
-   system reliability.

------------------------------------------------------------------------

# 7. Dimensões de sucesso

O sistema de métricas será dividido em:

``` text
1. Adoption
2. Governance Freshness
3. Data Quality
4. PMO Efficiency
5. Exception Management
6. Decision Effectiveness
7. Execution Follow-through
8. Executive Value
9. AI Value
10. Product & Platform Health
```

------------------------------------------------------------------------

# 8. Adoption

Mede se as personas realmente incorporaram o PMO Control ao trabalho.

KPIs:

-   Active Tenant Rate;
-   Active User Rate;
-   Active PMO Rate;
-   Active Project Rate;
-   Weekly Active Projects;
-   Status Adoption Rate;
-   Feature Adoption by Role.

------------------------------------------------------------------------

# 9. Active Project Rate

Percentual de Projects ativos com atividade relevante no período.

``` text
Active Project Rate =
Projects with meaningful activity
---------------------------------
Active Projects
× 100
```

Atividade significativa deve ser definida por eventos de domínio, não
por simples page view.

Exemplos:

-   Risk updated;
-   Action completed;
-   Milestone updated;
-   Status prepared;
-   Decision made.

------------------------------------------------------------------------

# 10. Status Adoption Rate

``` text
Status Adoption Rate =
Projects using PMO Control Status workflow
------------------------------------------
Projects expected to report Status
× 100
```

Essa métrica indica se o sistema substitui de fato o processo paralelo
de report.

------------------------------------------------------------------------

# 11. Governance Freshness

Mede se a informação disponível está atual.

KPIs:

-   Status Freshness Rate;
-   Average Status Age;
-   Projects Without Current Status;
-   Stale Critical Risk Rate;
-   Stale Action Rate.

------------------------------------------------------------------------

# 12. Status Freshness Rate

``` text
Status Freshness Rate =
Projects with Status inside expected reporting window
-----------------------------------------------------
Projects expected to report
× 100
```

A janela deve ser configurável.

Exemplo:

``` text
Weekly governance → 7 days
Biweekly governance → 14 days
Monthly governance → defined monthly window
```

------------------------------------------------------------------------

# 13. Average Status Age

Tempo médio desde o último Status publicado.

Unidade:

``` text
days
```

Deve ser analisado por:

-   Portfolio;
-   PMO;
-   Project type;
-   governance cadence.

------------------------------------------------------------------------

# 14. Data Quality

Mede se os registros possuem qualidade suficiente para governança.

KPIs:

-   Required Field Completeness;
-   Ownership Coverage;
-   Critical Item Ownership;
-   Due Date Coverage;
-   Orphan Record Rate;
-   Inconsistency Rate.

------------------------------------------------------------------------

# 15. Ownership Coverage

``` text
Ownership Coverage =
Governance items with valid owner
---------------------------------
Governance items requiring owner
× 100
```

Pode ser segmentada por:

``` text
Risks
Issues
Actions
Milestones
Decisions
```

------------------------------------------------------------------------

# 16. Critical Item Ownership

Percentual de itens críticos com owner definido.

Target esperado deve ser muito alto.

Um Risk crítico sem responsável é uma falha de governança.

------------------------------------------------------------------------

# 17. PMO Efficiency

Mede redução de esforço operacional.

KPIs:

-   Status Preparation Time;
-   Portfolio Consolidation Time;
-   Executive Report Preparation Time;
-   Manual Re-entry Rate;
-   Parallel Control Rate;
-   Time Spent Collecting Updates.

------------------------------------------------------------------------

# 18. Status Preparation Time

Tempo entre início da preparação do Status e publicação.

Comparar:

``` text
Before PMO Control
vs
After PMO Control
```

Objetivo:

reduzir tempo sem reduzir qualidade.

------------------------------------------------------------------------

# 19. Portfolio Consolidation Time

Tempo necessário para preparar visão consolidada do Portfolio.

Idealmente, o dashboard deve estar continuamente disponível.

A métrica pode evoluir de:

``` text
hours/days of manual consolidation
```

para:

``` text
near-zero manual consolidation
```

------------------------------------------------------------------------

# 20. Manual Re-entry Rate

Mede quantas informações precisam ser digitadas novamente apenas para
produzir report/dashboard.

Objetivo conceitual:

``` text
→ 0
```

A regra desejada é:

``` text
Update once → propagate everywhere
```

------------------------------------------------------------------------

# 21. Parallel Control Rate

Percentual de Projects que ainda dependem de controles paralelos
obrigatórios para o processo oficial.

Exemplos:

-   planilhas;
-   apresentações;
-   documentos manuais.

``` text
Parallel Control Rate =
Projects requiring parallel governance control
----------------------------------------------
Active Projects
× 100
```

Objetivo:

redução progressiva.

------------------------------------------------------------------------

# 22. Exception Management

Mede a capacidade de identificar e tratar desvios.

KPIs:

-   Critical Risk Response Time;
-   Issue Resolution Time;
-   Overdue Action Rate;
-   Escalation Aging;
-   Threatened Milestone Rate;
-   Exception Acknowledgement Time.

------------------------------------------------------------------------

# 23. Overdue Action Rate

``` text
Overdue Action Rate =
Open Actions past due
---------------------
Open Actions
× 100
```

Segmentar por:

-   Portfolio;
-   Project;
-   owner;
-   severity/source.

------------------------------------------------------------------------

# 24. Critical Risk Response Time

Tempo entre:

``` text
Risk becomes critical
      ↓
Response / mitigation action is registered
```

Ajuda a medir se o sistema produz ação, não apenas visibilidade.

------------------------------------------------------------------------

# 25. Issue Resolution Time

Tempo entre:

``` text
Issue opened
   ↓
Issue resolved
```

Analisar especialmente:

-   critical;
-   blocking;
-   high-impact Issues.

------------------------------------------------------------------------

# 26. Decision Effectiveness

Mede o fluxo de decisões.

KPIs:

-   Decision Lead Time;
-   Pending Decision Aging;
-   Decisions Past Due;
-   Decision-to-Action Conversion;
-   Decision Closure Rate.

------------------------------------------------------------------------

# 27. Decision Lead Time

``` text
Decision Lead Time =
Decision timestamp - Decision request timestamp
```

Objetivo:

reduzir tempo de espera para decisões relevantes.

------------------------------------------------------------------------

# 28. Pending Decision Aging

Idade das Decisions ainda pendentes.

Faixas possíveis:

``` text
0–3 days
4–7 days
8–14 days
15+ days
```

Os thresholds reais serão configuráveis conforme contexto.

------------------------------------------------------------------------

# 29. Decision-to-Action Conversion

Percentual de Decisions que exigem execução e possuem Action
correspondente.

``` text
Decision-to-Action Conversion =
Decisions requiring execution with Action
-----------------------------------------
Decisions requiring execution
× 100
```

------------------------------------------------------------------------

# 30. Execution Follow-through

Mede se compromissos de governança são executados.

KPIs:

-   Action Completion Rate;
-   On-time Action Completion;
-   Milestone On-time Rate;
-   Deliverable Completion Rate;
-   Forecast Accuracy.

------------------------------------------------------------------------

# 31. Action Completion Rate

``` text
Action Completion Rate =
Completed Actions
-----------------
Actions due in period
× 100
```

Deve ser analisada junto com pontualidade.

------------------------------------------------------------------------

# 32. On-time Action Completion

``` text
On-time Action Completion =
Actions completed by due date
-----------------------------
Completed Actions
× 100
```

------------------------------------------------------------------------

# 33. Milestone On-time Rate

``` text
Milestone On-time Rate =
Milestones completed on/before committed date
---------------------------------------------
Completed Milestones
× 100
```

A comparação precisa deixar explícito se usa Baseline ou Forecast.

------------------------------------------------------------------------

# 34. Forecast Accuracy

Mede quão próxima a previsão ficou do resultado real.

Exemplo conceitual:

``` text
|Actual Date - Forecast Date|
```

Pode ser medido em diferentes checkpoints históricos.

Snapshots permitem avaliar evolução da precisão.

------------------------------------------------------------------------

# 35. RAG Metrics

KPIs:

-   RAG Distribution;
-   RAG Transition Rate;
-   Red Project Aging;
-   Override Rate;
-   Override Reversal Rate;
-   RAG Explanation Coverage.

------------------------------------------------------------------------

# 36. RAG Override Rate

``` text
RAG Override Rate =
Published Statuses with override
--------------------------------
Published Statuses
× 100
```

Uma taxa alta pode indicar:

-   regras inadequadas;
-   thresholds inadequados;
-   problemas de dados;
-   comportamento organizacional.

Não deve ser interpretada isoladamente como algo bom ou ruim.

------------------------------------------------------------------------

# 37. Red Project Aging

Tempo que Projects permanecem em Red.

Permite identificar:

-   problemas persistentes;
-   ausência de ação;
-   governança ineficaz;
-   Projects estruturalmente comprometidos.

------------------------------------------------------------------------

# 38. Historical Governance Metrics

Snapshots permitem métricas que não seriam confiáveis apenas com estado
atual.

Exemplos:

-   RAG transition;
-   Forecast drift;
-   Risk exposure evolution;
-   Action backlog evolution;
-   Budget Forecast evolution;
-   Decision aging over time.

------------------------------------------------------------------------

# 39. Executive Value

Mede se a liderança usa e obtém valor das informações.

KPIs:

-   Executive Portfolio Usage;
-   Decision Response Rate;
-   Executive Report Usage;
-   Time to Executive Insight;
-   Committee Preparation Time.

------------------------------------------------------------------------

# 40. Time to Executive Insight

Tempo necessário para responder perguntas como:

> "Quais projetos precisam de atenção e por quê?"

O objetivo do produto é tornar essa resposta quase imediata quando os
dados estão atualizados.

------------------------------------------------------------------------

# 41. Committee Preparation Time

Tempo gasto pelo PMO para preparar reunião de governança/comitê.

Comparação:

``` text
Before
vs
After
```

Pode ser uma das métricas mais fortes de valor percebido.

------------------------------------------------------------------------

# 42. AI Value

IA não deve ser medida apenas por volume de prompts.

KPIs:

-   Copilot Adoption;
-   Useful Response Rate;
-   AI-assisted Report Rate;
-   AI Suggestion Acceptance;
-   AI Correction Rate;
-   AI Response Grounding Rate;
-   Estimated Time Saved.

------------------------------------------------------------------------

# 43. Copilot Adoption

``` text
Copilot Adoption =
Eligible active users using Copilot
-----------------------------------
Eligible active users
× 100
```

Deve ser segmentada por persona.

------------------------------------------------------------------------

# 44. Useful Response Rate

Pode ser obtida por feedback explícito ou mecanismo equivalente.

Exemplo:

``` text
Useful
Not useful
```

Não transformar feedback em vanity metric.

Investigar causas de respostas não úteis.

------------------------------------------------------------------------

# 45. AI Suggestion Acceptance

``` text
AI Suggestion Acceptance =
Accepted suggestions
--------------------
Suggestions presented
× 100
```

Uma taxa baixa pode indicar:

-   contexto insuficiente;
-   recomendação ruim;
-   baixa confiança;
-   sugestão irrelevante.

------------------------------------------------------------------------

# 46. AI Correction Rate

Percentual de outputs assistidos que exigem correção material antes de
uso.

Especialmente importante para:

-   executive summaries;
-   Status summaries;
-   reports.

------------------------------------------------------------------------

# 47. AI Grounding / Evidence Coverage

Quando a experiência exigir afirmações baseadas em dados, medir quantas
afirmações relevantes podem ser relacionadas a fontes internas
autorizadas.

Objetivo:

reduzir respostas sem sustentação.

------------------------------------------------------------------------

# 48. AI não pode mascarar falha do produto

Se o Copilot for muito usado porque a navegação básica é ruim, isso não
representa necessariamente sucesso.

Métricas de IA devem ser analisadas junto com:

-   UX;
-   data quality;
-   task completion;
-   user effort.

------------------------------------------------------------------------

# 49. Product Health

KPIs:

-   Task Success Rate;
-   Error Rate;
-   Abandonment Rate;
-   Feature Adoption;
-   Time on Task;
-   Support Requests;
-   User Satisfaction.

------------------------------------------------------------------------

# 50. Task Success Rate

Medir jornadas centrais:

-   criar Project;
-   registrar Risk;
-   criar Action;
-   preparar Status;
-   publicar;
-   registrar Decision;
-   consultar histórico;
-   gerar report.

------------------------------------------------------------------------

# 51. Time on Task

Tempo não é sempre melhor quando menor.

Para tarefas operacionais repetitivas:

``` text
lower is generally better
```

Para análise executiva:

tempo isolado não mede qualidade.

Usar junto com Task Success e resultado.

------------------------------------------------------------------------

# 52. Platform Health

KPIs técnicos principais:

-   Availability;
-   Error Rate;
-   API Latency;
-   Page Load Performance;
-   Background Job Success;
-   Notification Delivery;
-   Database Health;
-   AI Provider Error Rate.

Targets quantitativos serão formalizados nos NFRs/SLOs.

------------------------------------------------------------------------

# 53. Security Metrics

Indicadores:

-   Cross-tenant Access Test Pass Rate;
-   Authorization Test Pass Rate;
-   Sensitive Operation Audit Coverage;
-   Security Incident Count;
-   Secret Exposure Incidents;
-   Unauthorized Export Attempts;
-   Privileged Access Events.

------------------------------------------------------------------------

# 54. Cross-tenant Access Test Pass Rate

Target:

``` text
100%
```

Testes de isolamento não são uma métrica de crescimento; são um
requisito de segurança.

Qualquer falha é crítica.

------------------------------------------------------------------------

# 55. Audit Coverage

Percentual de eventos classificados como auditáveis que efetivamente
geram Audit Event válido.

Para operações críticas, target:

``` text
100%
```

------------------------------------------------------------------------

# 56. Reliability do Status

Indicadores:

-   Publication Success Rate;
-   Partial Publication Incidents;
-   Snapshot Integrity Failures;
-   Status-to-Snapshot Consistency.

Target para publicação parcial oficial:

``` text
0
```

------------------------------------------------------------------------

# 57. Snapshot Integrity

Cada Status publicado deve possuir Snapshot consistente.

Conceitualmente:

``` text
Published Statuses with valid Snapshot
--------------------------------------
Published Statuses
× 100
```

Target:

``` text
100%
```

------------------------------------------------------------------------

# 58. Data Freshness Score

Além de Status, pode ser criada futuramente uma métrica composta
considerando:

-   Status age;
-   stale Risks;
-   stale Issues;
-   overdue Actions without update;
-   Forecast age.

Não introduzir score opaco sem explicabilidade.

------------------------------------------------------------------------

# 59. Governance Quality Score --- futuro

Uma métrica composta pode combinar:

``` text
Freshness
Completeness
Ownership
Exceptions
Decision Aging
Action Follow-through
```

Mas só deve ser introduzida se cada componente puder ser explicado.

Não criar "nota mágica".

------------------------------------------------------------------------

# 60. MVP --- métricas prioritárias

Para validação inicial, priorizar um conjunto pequeno:

``` text
1. Trusted Governance Coverage
2. Status Freshness Rate
3. Status Preparation Time
4. Portfolio Consolidation Time
5. Parallel Control Rate
6. Overdue Action Rate
7. Decision Lead Time
8. Milestone On-time Rate
9. Task Success Rate
10. Snapshot Integrity
```

------------------------------------------------------------------------

# 61. MVP --- métricas secundárias

``` text
Ownership Coverage
Critical Risk Response Time
Issue Resolution Time
RAG Override Rate
Committee Preparation Time
Copilot Adoption
AI Useful Response Rate
Error Rate
Background Job Success
```

------------------------------------------------------------------------

# 62. Baseline antes da adoção

Quando possível, antes de implantar o PMO Control em uma organização,
capturar baseline de:

-   tempo de preparação de Status;
-   tempo de consolidação;
-   número de controles paralelos;
-   tempo de preparação de comitê;
-   Action overdue;
-   Decision lead time.

Sem baseline, fica mais difícil demonstrar ganho real.

------------------------------------------------------------------------

# 63. Métricas de ativação

Um Tenant pode ser considerado inicialmente ativado quando completa uma
jornada mínima, por exemplo:

``` text
Tenant configured
      ↓
Users invited
      ↓
Portfolio created
      ↓
Project created
      ↓
Operational data registered
      ↓
First Status published
```

O evento de ativação formal será refinado após validação.

------------------------------------------------------------------------

# 64. Time to First Value

Métrica:

``` text
Time from Tenant readiness
to
First meaningful governance outcome
```

Candidato inicial:

``` text
First Published Status
```

ou:

``` text
First Portfolio with trusted Project status
```

A definição final deve ser testada com usuários.

------------------------------------------------------------------------

# 65. Retention

Retenção deve considerar comportamento coerente com cadência de
governança.

Para um PMO semanal, Weekly Retention pode ser útil.

Para executivos, frequência menor pode ser normal.

Evitar uma única regra de retenção para todas as personas.

------------------------------------------------------------------------

# 66. Segmentação obrigatória

Sempre que possível, métricas devem poder ser segmentadas por:

-   Tenant;
-   Portfolio;
-   Project;
-   Project Type;
-   Role;
-   governance cadence;
-   período.

Respeitando autorização e privacidade.

------------------------------------------------------------------------

# 67. Métricas por persona

## PMO

-   My Day usage;
-   Status Preparation Time;
-   Portfolio Consolidation Time;
-   exception resolution;
-   report preparation.

## Project Manager

-   update completion;
-   Status readiness;
-   Action completion;
-   Milestone accuracy.

## Executive

-   Portfolio usage;
-   Decision Lead Time;
-   pending Decision aging.

## Tenant Admin

-   activation;
-   user onboarding;
-   configuration completion.

------------------------------------------------------------------------

# 68. Métricas por jornada

Cada jornada principal deve possuir:

``` text
Start Event
Completion Event
Success Condition
Failure Condition
Duration
```

Exemplo:

``` text
Prepare Status
Start: StatusDraftCreated
End: StatusPublished
Success: valid publication + Snapshot
```

------------------------------------------------------------------------

# 69. Eventos analíticos

Eventos de produto devem ser diferentes de Audit Events.

Exemplos:

``` text
ProjectCreated
RiskCreated
ActionCompleted
StatusDraftCreated
StatusSubmitted
StatusPublished
DashboardViewed
DecisionRequested
DecisionMade
ReportGenerated
CopilotQueryCompleted
```

O schema final será definido na camada de dados/analytics.

------------------------------------------------------------------------

# 70. Analytics ≠ Audit

Analytics responde:

> "Como o produto está sendo usado?"

Audit responde:

> "Quem realizou uma ação relevante, em qual recurso, quando e com qual
> mudança?"

Não usar analytics como substituto de Audit.

------------------------------------------------------------------------

# 71. Métricas que não devem virar meta isolada

Evitar transformar em objetivo isolado:

-   número de Projects;
-   número de Risks;
-   número de Actions;
-   número de Copilot prompts;
-   tempo dentro do sistema.

Mais registros podem significar mais problemas, não mais valor.

------------------------------------------------------------------------

# 72. Goodhart's Law

Quando uma métrica vira alvo rígido, usuários podem otimizar o número em
vez do resultado.

Exemplo:

Meta:

``` text
0 overdue Actions
```

pode gerar due dates artificialmente longas.

Por isso, interpretar métricas em conjunto.

------------------------------------------------------------------------

# 73. Targets

Targets numéricos de negócio não devem ser inventados sem baseline.

O produto deve inicialmente registrar:

``` text
Baseline
Current
Trend
Target
```

Targets podem ser definidos:

-   por Tenant;
-   por Portfolio;
-   por governance model.

------------------------------------------------------------------------

# 74. Targets de integridade

Alguns targets não dependem de baseline.

Exemplos:

``` text
Cross-tenant isolation test pass rate = 100%
Snapshot integrity = 100%
Critical audit coverage = 100%
Official partial publication incidents = 0
```

------------------------------------------------------------------------

# 75. Leading indicators

Exemplos:

-   Status Freshness;
-   Risk response time;
-   Action overdue;
-   pending Decisions;
-   Forecast drift.

Podem antecipar problemas.

------------------------------------------------------------------------

# 76. Lagging indicators

Exemplos:

-   Milestone On-time;
-   Project completion;
-   budget variance;
-   final delivery outcome.

Mostram resultados já materializados.

O sistema deve combinar ambos.

------------------------------------------------------------------------

# 77. Indicadores de adoção versus valor

``` text
Adoption:
User used the feature.

Value:
The feature improved the outcome.
```

Exemplo:

``` text
Copilot Adoption = adoption
Committee Preparation Time = potential value
```

------------------------------------------------------------------------

# 78. Métrica de redução de trabalho manual

Uma métrica composta futura pode medir:

``` text
Manual Governance Effort
```

com base em:

-   preparation time;
-   re-entry;
-   parallel controls;
-   manual report generation.

No MVP, manter componentes separados para facilitar interpretação.

------------------------------------------------------------------------

# 79. Métrica de confiança

Confiança é difícil de medir diretamente.

Proxies possíveis:

-   override behavior;
-   data correction rate;
-   parallel control usage;
-   report acceptance;
-   user survey;
-   repeated verification outside the system.

Um usuário que continua mantendo planilha paralela pode sinalizar baixa
confiança.

------------------------------------------------------------------------

# 80. Feedback qualitativo

Métricas quantitativas devem ser complementadas por entrevistas.

Perguntas úteis:

-   O que você deixou de fazer manualmente?
-   O que ainda precisa manter fora do sistema?
-   Em que informação você não confia?
-   O que demora mais do que deveria?
-   Qual informação faltou no comitê?
-   Qual alerta chegou tarde?
-   O Copilot ajudou ou criou retrabalho?

------------------------------------------------------------------------

# 81. Cadência de revisão

Sugestão:

``` text
Weekly
Operational product health

Monthly
Adoption + governance value

Quarterly
Strategic outcomes + roadmap
```

A cadência poderá variar conforme estágio do produto.

------------------------------------------------------------------------

# 82. Dashboard interno de produto

O time do PMO Control deve possuir visão própria com:

-   activation;
-   adoption;
-   TGC;
-   freshness;
-   Status preparation;
-   consolidation;
-   parallel controls;
-   task success;
-   reliability;
-   AI value;
-   security indicators.

Não misturar esse dashboard com dashboards de clientes.

------------------------------------------------------------------------

# 83. Privacy

Analytics deve:

-   coletar apenas o necessário;
-   respeitar Tenant boundaries;
-   evitar conteúdo sensível desnecessário;
-   aplicar classificação;
-   respeitar LGPD e políticas aplicáveis;
-   definir retenção.

------------------------------------------------------------------------

# 84. Métricas financeiras do SaaS --- futuro

Quando comercialização estiver madura:

-   MRR;
-   ARR;
-   churn;
-   expansion;
-   CAC;
-   LTV;
-   gross margin;
-   AI cost per Tenant;
-   infrastructure cost per Tenant.

Essas métricas são importantes para o negócio, mas não substituem
métricas de valor do produto.

------------------------------------------------------------------------

# 85. AI Cost Metrics

Com BYOK, o custo de inferência pode ser do cliente, mas ainda é útil
medir:

-   requests;
-   tokens;
-   model usage;
-   failures;
-   latency;
-   cost estimate quando disponível.

Nunca expor dados de outro Tenant.

------------------------------------------------------------------------

# 86. Success criteria para validação do MVP

O MVP deve demonstrar qualitativamente e quantitativamente que:

1.  o processo completo funciona;
2.  dados permanecem atuais;
3.  PMO reduz consolidação manual;
4.  dashboards derivam das fontes;
5.  histórico é confiável;
6.  exceções aparecem rapidamente;
7.  Decisions são acompanhadas;
8.  Actions têm follow-through;
9.  usuários conseguem concluir jornadas centrais;
10. segurança e isolamento permanecem íntegros.

------------------------------------------------------------------------

# 87. Sinais de product-market problem

Sinais que exigem investigação:

-   usuários mantêm planilha paralela obrigatória;
-   Status continua sendo refeito manualmente;
-   dashboards não são confiáveis;
-   Executives não usam as informações;
-   PMs evitam atualizar o sistema;
-   PMO precisa corrigir grande parte dos dados;
-   Copilot é usado para compensar dados ruins;
-   grande parte dos Projects está stale.

------------------------------------------------------------------------

# 88. Sinais positivos

-   Status produzido diretamente dos dados operacionais;
-   redução clara de preparação de comitê;
-   menor tempo de decisão;
-   menos Actions vencidas;
-   alta cobertura de owners;
-   aumento de Status freshness;
-   queda no uso de controles paralelos;
-   histórico usado para explicar mudanças;
-   executivos consultam Portfolio antes de pedir consolidação manual.

------------------------------------------------------------------------

# 89. Instrumentação desde o início

Eventos essenciais devem ser definidos antes da implementação das
features correspondentes.

Não deixar analytics inteiramente para o fim.

Ao mesmo tempo, evitar instrumentação excessiva sem pergunta de negócio.

------------------------------------------------------------------------

# 90. Pergunta obrigatória para cada métrica

Antes de adicionar uma métrica:

> **"Qual decisão tomaremos de forma diferente se esse número mudar?"**

Se não houver resposta, a métrica provavelmente não é prioritária.

------------------------------------------------------------------------

# 91. Scorecard inicial do MVP

``` text
NORTH STAR
Trusted Governance Coverage

GOVERNANCE
Status Freshness Rate
Overdue Action Rate
Decision Lead Time
Milestone On-time Rate

EFFICIENCY
Status Preparation Time
Portfolio Consolidation Time
Parallel Control Rate

EXPERIENCE
Task Success Rate

INTEGRITY
Snapshot Integrity
Cross-tenant Isolation Tests
Critical Audit Coverage
```

------------------------------------------------------------------------

# 92. Relação com Roadmap

O próximo documento:

``` text
/docs/01-product/roadmap.md
```

usará estas métricas como gates para evolução.

Exemplo:

``` text
MVP
 ↓ validate governance loop
Next Release
 ↓ validate adoption and efficiency
Advanced Intelligence
 ↓ only after sufficient trusted historical data
```

------------------------------------------------------------------------

# 93. Referências

-   `/docs/01-product/PDD.md`
-   `/docs/01-product/product-vision.md`
-   `/docs/01-product/personas.md`
-   `/docs/01-product/user-journeys.md`
-   `/docs/01-product/functional-map.md`
-   `/docs/01-product/module-catalog.md`
-   `/docs/01-product/feature-prioritization.md`
-   `/docs/01-product/mvp-scope.md`
-   `/docs/00-foundation/business-rules.md`
-   `/docs/00-foundation/data-classification.md`

------------------------------------------------------------------------

# 94. Status

**Documento:** Success Metrics\
**Status:** Under Review\
**Responsabilidade:** definir como o PMO Control mede adoção,
eficiência, qualidade da governança, decisão, execução, valor executivo,
IA e integridade do produto, evitando vanity metrics e metas sem
baseline.

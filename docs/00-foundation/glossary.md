# PMO Control --- Glossário

**Documento:** `glossary.md`\
**Camada:** Foundation\
**Status:** Under Review\
**Idioma funcional:** Português\
**Nomenclatura técnica:** Inglês quando utilizada em código, APIs,
eventos e modelos de dados.

------------------------------------------------------------------------

## 1. Objetivo

Este documento estabelece o vocabulário oficial do PMO Control.

Seu propósito é garantir que Produto, PMO, UX, Arquitetura,
Desenvolvimento, Dados, Segurança, APIs, Inteligência Artificial e
testes utilizem os mesmos termos com o mesmo significado.

Sempre que um termo possuir definição neste glossário, Specifications e
demais documentos devem reutilizá-la em vez de criar interpretações
locais.

------------------------------------------------------------------------

## 2. Regras de utilização

1.  Um conceito de domínio deve possuir um nome preferencial.
2.  Sinônimos podem ser registrados, mas não devem substituir o termo
    oficial nos artefatos técnicos.
3.  Nomes técnicos utilizados em código devem seguir as convenções do
    projeto.
4.  Novos conceitos transversais devem ser adicionados ao glossário
    antes ou junto da Spec que os introduzir.
5.  Alterações de significado devem passar por análise de impacto.
6.  Termos de interface podem ser traduzidos para português, enquanto
    identificadores técnicos podem permanecer em inglês.

------------------------------------------------------------------------

# 3. Organização e acesso

## Tenant

**Definição:** organização cliente isolada dentro da plataforma SaaS PMO
Control.

Um Tenant possui seus próprios usuários, configurações, portfólios,
projetos, regras e dados.

**Regra:** dados de um Tenant não podem ser acessados por outro Tenant.

**Nome técnico sugerido:** `tenant`

------------------------------------------------------------------------

## Tenant Membership

**Definição:** vínculo entre um usuário e um Tenant.

A existência de um usuário na plataforma não implica automaticamente
acesso aos dados de uma organização.

**Nome técnico sugerido:** `tenant_membership`

------------------------------------------------------------------------

## User

**Definição:** identidade autenticável que utiliza a plataforma.

Um User pode possuir diferentes papéis e escopos de acesso conforme suas
associações.

**Nome técnico sugerido:** `user`

------------------------------------------------------------------------

## Role

**Definição:** conjunto lógico de responsabilidades e permissões
associado a um usuário em determinado contexto.

Papéis iniciais:

-   Platform Admin;
-   Tenant Admin;
-   PMO Admin;
-   PMO;
-   Project Manager;
-   Contributor;
-   Executive;
-   Viewer.

**Nome técnico sugerido:** `role`

------------------------------------------------------------------------

## Scope

**Definição:** limite organizacional ou funcional no qual um papel ou
permissão é válido.

Escopos previstos:

``` text
Tenant
  ↓
Portfolio
  ↓
Project
  ↓
Resource / Assigned Item
```

**Nome técnico sugerido:** `scope`

------------------------------------------------------------------------

## Permission

**Definição:** autorização para executar uma operação específica sobre
um recurso.

Verbos iniciais:

-   View;
-   Create;
-   Edit;
-   Delete;
-   Approve;
-   Publish;
-   Export;
-   Admin.

Exemplos técnicos:

``` text
project.read
risk.create
status.update.publish
decision.approve
financial.view
```

------------------------------------------------------------------------

## Data Policy

**Definição:** regra adicional que controla acesso a determinada
categoria ou sensibilidade de informação, independentemente do acesso
geral ao recurso.

Exemplos:

-   financeiro;
-   documentos confidenciais;
-   recursos/capacidade;
-   contratos;
-   dados pessoais.

**Nome técnico sugerido:** `data_policy`

------------------------------------------------------------------------

## Workflow Rule

**Definição:** regra que determina se uma ação pode ser executada
diretamente ou depende de etapa adicional de governança.

Exemplos:

-   revisão;
-   aprovação;
-   justificativa;
-   segregação de funções.

**Nome técnico sugerido:** `workflow_rule`

------------------------------------------------------------------------

## RBAC

**Role-Based Access Control.**

Modelo de controle de acesso baseado em papéis.

No PMO Control, RBAC não atua isoladamente. O acesso efetivo considera:

> **Tenant + Role + Scope + Permission + Data Policy + Workflow Rule**

------------------------------------------------------------------------

## RLS

**Row Level Security.**

Mecanismo de segurança aplicado no nível dos registros do banco de dados
para restringir quais linhas podem ser acessadas por determinado
contexto de usuário/tenant.

RLS será uma das camadas de proteção, não a única regra de autorização.

------------------------------------------------------------------------

# 4. Estrutura de gestão

## Portfolio / Portfólio

**Definição:** agrupamento governado de projetos relacionados por
estratégia, área, programa, investimento ou outro critério
organizacional.

Um Portfólio pertence a um Tenant e pode conter vários Projetos.

**Nome técnico:** `portfolio`

------------------------------------------------------------------------

## Project / Projeto

**Definição:** unidade de gestão criada para alcançar um objetivo
específico dentro de restrições de prazo, escopo, recursos, riscos e
orçamento.

O Projeto é uma das principais raízes de agregação do PMO Control.

**Nome técnico:** `project`

------------------------------------------------------------------------

## Project Manager

**Definição:** responsável pela gestão de um ou mais projetos dentro do
escopo concedido.

Não possui automaticamente acesso aos demais projetos do portfólio.

**Abreviação:** `PM`, quando o contexto não gerar ambiguidade.

------------------------------------------------------------------------

## PMO

**Project Management Office.**

No contexto do PMO Control, representa tanto a função de governança
quanto o papel operacional responsável por acompanhamento, consolidação,
riscos, indicadores, status, ações, decisões e apoio à gestão do
portfólio.

------------------------------------------------------------------------

## PMO Admin

**Definição:** papel com autoridade ampliada de governança sobre os
projetos e portfólios do seu escopo.

Pode possuir permissões administrativas que um PMO operacional não
possui.

------------------------------------------------------------------------

## Executive

**Definição:** usuário executivo, como CIO, diretor ou sponsor,
predominantemente consumidor de informação e responsável por
determinadas decisões/aprovações.

------------------------------------------------------------------------

## Contributor

**Definição:** participante operacional com acesso normalmente restrito
aos projetos e itens sob sua responsabilidade.

------------------------------------------------------------------------

## Viewer

**Definição:** usuário com acesso somente de leitura dentro do escopo
autorizado.

------------------------------------------------------------------------

# 5. Planejamento e cronograma

## Baseline

**Definição:** versão formalmente aprovada de um compromisso do projeto
utilizada como referência para comparação futura.

Pode envolver:

-   prazo;
-   cronograma;
-   custo;
-   escopo;
-   marcos.

Uma Baseline não deve ser silenciosamente sobrescrita.

**Nome técnico:** `baseline`

------------------------------------------------------------------------

## Forecast

**Definição:** previsão atualizada do resultado esperado com base no
estado corrente do projeto.

Exemplo:

``` text
Baseline Go-live: 01/12/2026
Forecast Go-live: 15/12/2026
```

A diferença entre Baseline e Forecast representa um desvio que pode
exigir análise.

**Nome técnico:** `forecast`

------------------------------------------------------------------------

## Milestone / Marco

**Definição:** evento significativo do cronograma que representa uma
conquista, aprovação, entrega relevante ou ponto de controle.

Normalmente possui:

-   data planejada;
-   forecast;
-   responsável;
-   criticidade;
-   status;
-   dependências.

**Nome técnico:** `milestone`

------------------------------------------------------------------------

## Deliverable / Entrega

**Definição:** resultado verificável produzido pelo projeto.

Pode estar associado a um ou mais Milestones.

**Nome técnico:** `deliverable`

------------------------------------------------------------------------

## Schedule / Cronograma

**Definição:** organização temporal das atividades, marcos e entregas do
projeto.

**Nome técnico:** `schedule`

------------------------------------------------------------------------

## Dependency / Dependência

**Definição:** relação na qual uma atividade, entrega, marco, projeto ou
resultado depende de outro elemento para ocorrer conforme planejado.

Pode ser interna ou externa ao projeto.

**Nome técnico:** `dependency`

------------------------------------------------------------------------

# 6. Execução e governança

## Progress / Progresso

**Definição:** medida de avanço do projeto ou de um elemento de
trabalho.

Quando representado percentualmente, sua regra de cálculo deve ser
explícita e não inferida apenas pela interface.

**Nome técnico:** `progress`

------------------------------------------------------------------------

## Status Update / Atualização de Status

**Definição:** processo periódico de governança utilizado para revisar,
consolidar, validar e publicar o estado de um projeto em determinado
período.

Não é uma duplicação dos cadastros operacionais.

Fluxo conceitual:

``` text
Dados operacionais
      ↓
Mudanças desde último status
      ↓
Revisão
      ↓
Validação
      ↓
RAG / KPIs
      ↓
Publicação
      ↓
Snapshot
```

**Nome técnico:** `status_update`

------------------------------------------------------------------------

## Status Period / Período de Status

**Definição:** intervalo de referência de uma Atualização de Status.

Exemplo: semana encerrada em `23/10/2026`.

------------------------------------------------------------------------

## Snapshot

**Definição:** representação imutável do estado relevante de um projeto
ou contexto em determinado momento.

Snapshots publicados suportam histórico, comparação, auditoria e Time
Machine.

**Nome técnico:** `snapshot`

------------------------------------------------------------------------

## Time Machine

**Definição:** capacidade do PMO Control de consultar e comparar estados
históricos preservados por snapshots.

Não representa edição retroativa do estado publicado.

------------------------------------------------------------------------

## Data Quality Score

**Definição:** indicador de qualidade/completude utilizado antes de
processos como publicação de Status Update.

Sua fórmula será definida em Specification própria ou regra transversal
aprovada.

------------------------------------------------------------------------

# 7. Saúde e indicadores

## RAG

**Red / Amber / Green.**

Modelo visual de classificação da saúde de projeto, portfólio ou
dimensão de governança.

No PMO Control:

-   **Green / Verde:** condição saudável;
-   **Amber / Amarelo:** atenção necessária;
-   **Red / Vermelho:** condição crítica.

O RAG deve ser calculado ou recomendado por regras rastreáveis.

------------------------------------------------------------------------

## RAG Engine

**Definição:** mecanismo responsável por avaliar indicadores e regras
para determinar/recomendar o RAG.

**Nome técnico:** `rag_engine`

------------------------------------------------------------------------

## RAG Override

**Definição:** alteração autorizada do RAG recomendado/calculado.

Deve preservar:

-   RAG calculado;
-   RAG efetivo;
-   usuário;
-   data/hora;
-   justificativa;
-   auditoria.

------------------------------------------------------------------------

## KPI

**Key Performance Indicator.**

Indicador utilizado para acompanhar desempenho, saúde ou resultado.

Exemplos:

-   progresso;
-   variação de prazo;
-   variação de orçamento;
-   riscos críticos;
-   issues abertos;
-   ações vencidas.

------------------------------------------------------------------------

## Threshold / Limite

**Definição:** valor utilizado por uma regra para determinar mudança de
condição ou classificação.

Exemplo: desvio de prazo superior a determinado limite pode alterar o
RAG.

------------------------------------------------------------------------

# 8. Riscos, problemas e ações

## Risk / Risco

**Definição:** evento ou condição incerta que, caso ocorra, pode afetar
objetivos do projeto.

Pode possuir:

-   probabilidade;
-   impacto;
-   criticidade;
-   categoria;
-   owner;
-   resposta;
-   plano de mitigação.

**Nome técnico:** `risk`

------------------------------------------------------------------------

## Risk Owner

**Definição:** pessoa responsável pelo acompanhamento e tratamento de um
Risco.

Não significa necessariamente que seja a pessoa que executará todas as
ações de mitigação.

------------------------------------------------------------------------

## Mitigation / Mitigação

**Definição:** ação ou conjunto de ações destinadas a reduzir
probabilidade e/ou impacto de um Risco.

------------------------------------------------------------------------

## Materialized Risk / Risco Materializado

**Definição:** risco cuja condição prevista efetivamente ocorreu.

Sua materialização pode resultar na criação ou associação de um Issue.

------------------------------------------------------------------------

## Issue

**Definição:** problema, impedimento ou condição já existente que requer
tratamento.

Diferença fundamental:

> **Risk = algo que pode acontecer.**\
> **Issue = algo que já aconteceu ou está acontecendo.**

**Nome técnico:** `issue`

------------------------------------------------------------------------

## Action / Ação

**Definição:** atividade com responsável e acompanhamento criada para
produzir um resultado específico.

Pode estar associada a:

-   risco;
-   issue;
-   decisão;
-   reunião;
-   status;
-   projeto.

**Nome técnico:** `action`

------------------------------------------------------------------------

## Action Owner

**Definição:** responsável pela execução ou condução de uma Ação.

------------------------------------------------------------------------

## Overdue Action / Ação Vencida

**Definição:** ação ainda não concluída cuja data limite já foi
ultrapassada.

------------------------------------------------------------------------

# 9. Decisões

## Decision / Decisão

**Definição:** registro governado de uma escolha relevante para o
projeto ou portfólio.

Pode conter:

-   contexto;
-   opções;
-   recomendação;
-   impacto;
-   prazo;
-   decisor;
-   evidências;
-   resultado.

**Nome técnico:** `decision`

------------------------------------------------------------------------

## Decision Request / Solicitação de Decisão

**Definição:** pedido formal para que um decisor autorizado escolha
entre alternativas ou aprove/rejeite uma proposta.

------------------------------------------------------------------------

## Decision Maker / Decisor

**Definição:** usuário ou grupo autorizado a concluir determinada
decisão.

------------------------------------------------------------------------

## Pending Decision / Decisão Pendente

**Definição:** decisão que ainda necessita de manifestação do decisor
autorizado.

------------------------------------------------------------------------

# 10. Financeiro e recursos

## Budget / Orçamento

**Definição:** valor financeiro aprovado ou planejado para um projeto,
portfólio ou período.

**Nome técnico:** `budget`

------------------------------------------------------------------------

## Actual Cost / Custo Realizado

**Definição:** custo efetivamente realizado e registrado até determinado
momento.

------------------------------------------------------------------------

## Financial Forecast

**Definição:** previsão atualizada de custo ou desembolso futuro.

------------------------------------------------------------------------

## Resource / Recurso

**Definição:** pessoa, capacidade ou outro elemento alocável necessário
à execução do projeto.

No contexto inicial do PMO Control, o foco principal de Resources será
capacidade humana.

------------------------------------------------------------------------

## Allocation / Alocação

**Definição:** parcela da capacidade de um recurso comprometida com
determinado projeto ou período.

------------------------------------------------------------------------

## Capacity / Capacidade

**Definição:** quantidade disponível de trabalho de um recurso em
determinado período.

------------------------------------------------------------------------

## Overallocation / Sobrealocação

**Definição:** condição em que a soma das alocações supera a capacidade
disponível.

------------------------------------------------------------------------

# 11. Documentos e evidências

## Document / Documento

**Definição:** arquivo ou registro documental associado a um contexto
autorizado.

**Nome técnico:** `document`

------------------------------------------------------------------------

## Evidence / Evidência

**Definição:** informação ou documento utilizado para comprovar,
contextualizar ou sustentar uma atualização, decisão, entrega, risco ou
outra afirmação de governança.

------------------------------------------------------------------------

## Confidential Document / Documento Confidencial

**Definição:** documento sujeito a política adicional de acesso além da
permissão geral do projeto.

------------------------------------------------------------------------

# 12. Auditoria

## Audit Log

**Definição:** registro imutável ou protegido contra alteração indevida
destinado a preservar eventos relevantes de segurança e governança.

Deve permitir identificar, conforme aplicável:

-   ator;
-   ação;
-   recurso;
-   data/hora;
-   valor anterior;
-   novo valor;
-   motivo;
-   contexto.

**Nome técnico:** `audit_log`

------------------------------------------------------------------------

## Audit Event

**Definição:** evento individual registrado na trilha de auditoria.

Exemplos:

-   `StatusPublished`;
-   `RAGOverridden`;
-   `BaselineChanged`;
-   `PermissionGranted`;
-   `DecisionApproved`.

------------------------------------------------------------------------

# 13. Relatórios e visualização

## Dashboard

**Definição:** visão consolidada e interativa de indicadores e
informações derivadas das fontes governadas.

Dashboard não é fonte primária de dados.

------------------------------------------------------------------------

## Project Dashboard

**Definição:** dashboard orientado à saúde e desempenho de um projeto
específico.

------------------------------------------------------------------------

## Portfolio Dashboard

**Definição:** dashboard consolidado de projetos pertencentes a
determinado portfólio e escopo de acesso.

------------------------------------------------------------------------

## Executive View / Visão Executiva

**Definição:** visão simplificada orientada a saúde, exceções, valor,
riscos, marcos e decisões que requerem atenção executiva.

------------------------------------------------------------------------

## Report

**Definição:** representação estruturada e potencialmente exportável de
informações do sistema.

------------------------------------------------------------------------

## Report Builder

**Definição:** capacidade de configurar e gerar relatórios a partir de
dados autorizados.

------------------------------------------------------------------------

# 14. Inteligência Artificial

## PMO Copilot

**Definição:** camada de inteligência artificial do PMO Control para
consulta, análise, síntese, identificação de padrões, recomendações e
apoio à decisão.

O Copilot não substitui autorização, governança ou aprovação humana.

------------------------------------------------------------------------

## BYOK

**Bring Your Own Key.**

Modelo em que o Tenant fornece credenciais próprias para utilização de
provedores de IA suportados.

**Nome técnico:** `byok`

------------------------------------------------------------------------

## Model Routing

**Definição:** seleção do modelo de IA mais apropriado conforme tarefa,
custo, capacidade, política e disponibilidade.

Exemplo:

``` text
Classificação → modelo econômico
Resumo → modelo intermediário
Análise complexa → modelo avançado
Embeddings → modelo dedicado
```

------------------------------------------------------------------------

## AI Context

**Definição:** conjunto autorizado de informações disponibilizado ao
modelo para executar determinada tarefa.

O contexto deve respeitar Tenant, Scope, Permission e Data Policy.

------------------------------------------------------------------------

## Guardrail

**Definição:** controle destinado a limitar, validar ou orientar
comportamento de funcionalidades de IA.

------------------------------------------------------------------------

# 15. Eventos e automação

## Domain Event / Evento de Domínio

**Definição:** representação de um fato relevante que ocorreu no
domínio.

Exemplos:

``` text
ProjectCreated
RiskEscalated
IssueCreated
ActionOverdue
DecisionMade
StatusPublished
SnapshotCreated
RAGChanged
```

Eventos descrevem fatos no passado e não comandos.

------------------------------------------------------------------------

## Background Job

**Definição:** processamento executado de forma assíncrona fora do fluxo
síncrono principal.

Pode ser utilizado para notificações, agregações, geração de relatórios
e tarefas de IA.

------------------------------------------------------------------------

## Notification / Notificação

**Definição:** comunicação gerada pelo sistema para informar um usuário
sobre evento, responsabilidade, prazo, decisão ou condição relevante.

------------------------------------------------------------------------

# 16. Estados documentais

## Draft

Documento ou registro ainda em elaboração.

## Under Review

Documento ou registro submetido à revisão e ainda não aprovado.

## Approved

Documento ou registro formalmente aprovado para uso.

## Deprecated

Documento, regra ou recurso ainda existente, mas não recomendado para
novos usos.

## Superseded

Documento ou regra substituído por uma versão ou decisão posterior.

------------------------------------------------------------------------

# 17. Termos a evitar ou usar com cuidado

## Administrador

Evitar isoladamente. Preferir:

-   Platform Admin;
-   Tenant Admin;
-   PMO Admin.

Isso evita ambiguidade sobre o nível de autoridade.

## Status

Evitar quando não estiver claro se significa:

-   estado de uma entidade;
-   Status Update periódico;
-   saúde/RAG.

## PM

Pode significar `Project Manager` ou `Product Manager` em outros
contextos. No PMO Control, preferir escrever `Project Manager` em
documentação formal quando houver risco de ambiguidade.

## Entrega

Não utilizar como sinônimo automático de Milestone. `Deliverable` e
`Milestone` são conceitos distintos.

## Problema

Quando o conceito for governado pelo sistema, preferir `Issue`.

------------------------------------------------------------------------

# 18. Convenção bilíngue inicial

  Português / UI          Termo técnico
  ----------------------- ---------------
  Empresa                 Tenant
  Usuário                 User
  Portfólio               Portfolio
  Projeto                 Project
  Marco                   Milestone
  Entrega                 Deliverable
  Risco                   Risk
  Issue / Problema        Issue
  Ação                    Action
  Decisão                 Decision
  Dependência             Dependency
  Atualização de Status   Status Update
  Linha de Base           Baseline
  Previsão                Forecast
  Orçamento               Budget
  Recurso                 Resource
  Documento               Document
  Evidência               Evidence
  Permissão               Permission
  Escopo de acesso        Scope
  Papel                   Role
  Snapshot                Snapshot
  Auditoria               Audit Log

------------------------------------------------------------------------

# 19. Governança do glossário

O Glossary é um documento vivo, mas suas alterações devem ser
controladas.

Um novo termo deve ser adicionado quando:

-   for utilizado por múltiplas Specs;
-   representar uma entidade de domínio;
-   possuir significado específico no PMO Control;
-   houver risco de interpretação divergente.

Uma alteração deve avaliar impacto sobre:

-   PDD;
-   Domain Model;
-   Business Rules;
-   Specifications;
-   APIs;
-   banco de dados;
-   UX;
-   testes;
-   eventos.

------------------------------------------------------------------------

# 20. Referências

-   `/docs/00-foundation/README.md`
-   `/docs/01-product/PDD.md`
-   `/docs/04-specs/002-multi-tenancy/`
-   `/docs/04-specs/003-rbac/`
-   `/docs/04-specs/015-rag-engine/`
-   `/docs/07-security/`
-   `/docs/09-ai/`

------------------------------------------------------------------------

# 21. Status

**Documento:** Glossary\
**Status:** Under Review\
**Responsabilidade:** estabelecer o vocabulário oficial e compartilhado
do domínio PMO Control.

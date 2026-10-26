# PDD --- PMO Control

## Product Definition Document

**Versão:** 1.0\
**Status:** Base para Spec-Driven Development (SDD)\
**Data:** 25/10/2026\
**Produto:** PMO Control --- SaaS de Governança, Gestão e Inteligência
de Projetos e Portfólios de TI

------------------------------------------------------------------------

## 1. Objetivo

Este PDD consolida a visão funcional e conceitual discutida para o **PMO
Control** e deve servir como fonte inicial para a documentação de
**Spec-Driven Development**. Ele descreve problema, visão, personas,
módulos, fluxos, regras de negócio, modelo conceitual, governança, IA,
segurança, MVP e decomposição recomendada em Specifications.

O PDD define **o que e por que construir**. As Specifications
posteriores devem definir contratos funcionais e técnicos implementáveis
e testáveis.

## 2. Visão do produto

O PMO Control é uma plataforma SaaS para centralizar governança,
acompanhamento, execução e inteligência de projetos e portfólios. O
produto substitui controles fragmentados em Excel, PowerPoint, Project,
Jira, e-mails e documentos por uma fonte integrada de verdade.

**Proposta de valor:**

> **PROJETOS MAIS CLAROS. DECISÕES MAIS INTELIGENTES. RESULTADOS
> REAIS.**

A plataforma deve conectar:

`Execução → Governança → Status → Indicadores → Portfólio → Insights → Decisões → Ações → Resultados`

O sistema não deve ser apenas um dashboard: deve ser o ambiente de
trabalho cotidiano do PMO.

## 3. Problemas que o produto resolve

-   duplicação e divergência de dados;
-   reports executivos manuais;
-   baixa rastreabilidade de decisões;
-   riscos identificados tarde;
-   planos de ação sem follow-up;
-   falta de histórico confiável;
-   dificuldade para comparar projetos;
-   dependências pouco visíveis;
-   excesso de tempo consolidando informação;
-   baixa conexão entre dado operacional e decisão executiva.

## 4. Princípios de produto

### 4.1 Single Source of Truth

Cada entidade possui uma fonte principal. Um risco não é duplicado na
atualização de status; a atualização referencia o registro existente.

### 4.2 Update Once, Propagate Everywhere

Uma atualização deve refletir automaticamente nos contextos aplicáveis:

`Registro operacional → KPI → Projeto → Dashboard → Portfólio → Report → Copilot`

### 4.3 Management by Exception

O PMO trabalha prioritariamente sobre atrasos, riscos críticos, issues,
ações vencidas, decisões pendentes, marcos ameaçados, desvios
financeiros, conflitos de capacidade e projetos sem atualização.

### 4.4 Histórico imutável

Status publicados geram snapshots. Alterações posteriores não modificam
snapshots históricos.

### 4.5 IA como camada de inteligência

IA deve apoiar análise, tendência, resumo, preparação de comitês,
riscos, cenários, priorização e reports --- não ser apenas chatbot.

### 4.6 UX por objetivo

**PMO:** "O que preciso fazer agora?"\
**Executivo:** "Onde preciso agir ou decidir?"

## 5. Personas e papéis

-   **PMO:** governança, follow-up, qualidade, status, reports, riscos,
    issues, ações, decisões e portfólio.
-   **Gerente de Projeto:** execução, progresso, entregas, marcos,
    forecast e status.
-   **Sponsor:** saúde, impedimentos e decisões estratégicas.
-   **CIO/Diretoria:** visão executiva, exceções, investimento e
    decisões.
-   **Contributor/Owner:** atualização dos itens atribuídos.
-   **Tenant Admin:** usuários, parâmetros, permissões e configurações.
-   **Platform Admin:** administração da plataforma SaaS.

## 6. Arquitetura conceitual

`Fontes → Base Operacional → Regras/KPIs → Status/Snapshots → Dashboards → Reports → Inteligência`

Fontes possíveis: entrada manual, Excel, Jira, Microsoft Project, APIs,
sistemas financeiros e integrações futuras.

Entidades principais:

-   Tenant
-   User
-   Portfolio
-   Project
-   ProjectStatus
-   Milestone
-   Deliverable
-   Risk
-   Issue
-   Action
-   Decision
-   Dependency
-   Budget
-   Resource
-   Allocation
-   Document
-   Evidence
-   Meeting
-   Snapshot
-   KPI
-   Comment
-   Notification
-   AuditLog

Hierarquia:

`Tenant → Portfolio → Project → entidades operacionais/status/snapshots`

## 7. Navegação

-   Meu Dia
-   Visão Executiva
-   Portfólio
-   Projetos
    -   Visão Geral
    -   Atualização de Status
    -   Cronograma
    -   Entregas
    -   Riscos
    -   Issues
    -   Ações
    -   Decisões
    -   Financeiro
    -   Equipe/Recursos
    -   Documentos
    -   Relatórios
    -   Time Machine
-   Insights IA / PMO Copilot
-   Configurações

## 8. Meu Dia --- PMO Workspace

Home operacional do PMO. Deve responder: **"O que precisa da minha
atenção hoje?"**

### Cards

-   ações vencidas;
-   ações vencendo;
-   riscos críticos;
-   projetos sem status;
-   decisões pendentes;
-   marcos próximos.

### Minhas tarefas

Lista consolidada de ações, riscos, issues, decisões, aprovações e
atualizações. Filtros: Todos, Em atraso, Hoje, Esta semana, Aguardando
mim.

### Projetos que precisam de atenção

Projeto, RAG, progresso, forecast, alertas e acesso rápido.

### Agenda

Reuniões e compromissos relacionados ao portfólio.

### Alterações recentes

Novo risco, marco concluído, forecast alterado, issue atualizado,
decisão registrada etc.

### Copilot

Sugestões como preparar comitê, analisar riscos e iniciar atualização de
status.

## 9. Visão Executiva do Portfólio

Objetivo: permitir decisão rápida, sem poluição visual.

Indicadores: - projetos ativos; - on-time delivery; - projetos
críticos; - orçamento; - marcos no prazo; - riscos/issues críticos; -
ações vencidas; - decisões pendentes.

Blocos: - saúde do portfólio; - principais pontos de atenção; - decisões
necessárias; - próximos marcos; - valor para o negócio; - insight
executivo do PMO.

## 10. Portfólio

Lista e análise de projetos com filtros por área, sponsor, gerente, RAG,
status, categoria, período e prioridade. Visualizações: tabela, cards,
roadmap e timeline.

## 11. Project Control Center

Tela central do projeto.

Exibe: - RAG; - progresso; - prazo; - orçamento; - escopo; - riscos
críticos; - issues; - ações vencidas; - decisões; - próximo marco; -
insights.

Ações rápidas: Atualizar Status, Registrar Risco, Abrir Issue, Nova
Ação, Registrar Decisão.

## 11.1 Exclusão administrativa definitiva de Project

Somente Platform Root Admin com permissão específica pode solicitar a exclusão definitiva de um Project. O comando é diferente de arquivar e ocorre em console de plataforma que expõe somente identidade/estado mínimos do Project, nunca seu conteúdo de negócio.

O sistema exibe prévia de impacto e retenção, exige motivo e confirmação digitada vinculada ao código do Project, bloqueia novas operações e executa purge idempotente em job retomável. Remove definitivamente dados operacionais elegíveis; preserva publicações, snapshots, audit, legal hold e qualquer dado ainda sujeito a retenção, com tombstone mínimo enquanto houver referências. O resultado informa apagados, preservados e bloqueados. Regras centrais em `docs/04-specs/005-projects/` e `docs/06-data/retention-archival.md`.

## 11.2 Destaque visual de box (Box Focus)

Em qualquer tela, o usuário pode ativar o destaque dando duplo clique no título de um box: o restante da tela visível fica em escala de cinza e o box selecionado preserva suas cores. Repetir o duplo clique no mesmo título restaura as cores; selecionar outro box transfere o destaque. A interação é visual e temporária, limitada à tela atual, e termina ao navegar ou recarregar. Deve existir alternativa acessível por teclado com botão/estado “Destacar [nome]” e tecla Escape para restaurar as cores.
## 12. Atualização de Status

É um **ritual periódico de fechamento**, não um formulário que duplica
dados.

Fluxo:

1.  Execução e Indicadores
2.  Marcos e Entregas
3.  Riscos e Issues
4.  Ações e Decisões
5.  Resumo e Publicação

### 12.1 Execução e Indicadores

Dados: projeto, fase, data, responsável, resumo executivo, progresso
planejado/realizado, baseline/forecast, budget/realizado, escopo
total/concluído.

Cálculos: desvio de progresso, prazo, utilização financeira e escopo.

### 12.2 Marcos e Entregas

Mostrar mudanças desde o último status. Permitir confirmar/atualizar
registros, criar marco/entrega, alterar forecast e anexar evidências.

### 12.3 Riscos e Issues

Mostrar riscos novos, agravados, mitigados, críticos e issues. Suportar
`Risk → Materializou → Issue`, preservando vínculo.

### 12.4 Ações e Decisões

Revisar ações abertas/atrasadas, progresso, owners, decisões pendentes e
decisões tomadas.

### 12.5 Resumo e Publicação

Consolidar progresso, entregas, marcos, riscos, issues, ações, decisões,
conquistas, desafios e próximos passos.

Mostrar **Mudanças desde o último status**, por exemplo: - Progresso 64%
→ 70% - Entregas 44 → 48 - Forecast 01/12 → 15/12 - Riscos críticos 1 →
2 - Issues 8 → 5

## 13. Checklist de publicação

Antes de publicar: - indicadores atualizados; - marcos e entregas
revisados; - riscos/issues revisados; - ações/decisões revisadas; -
resumo preenchido.

Alertas: ações vencidas, decisões pendentes, risco sem owner, issue sem
prazo, marco sem forecast.

Pode haver **Data Quality Score**.

## 14. Publicação

Fluxo lógico: validar autorização e dados → calcular KPIs/RAG determinísticos → consolidar → persistir estado publicado, Publication, Snapshot imutável e outbox/audit numa única transação autoritativa → após commit, atualizar projeções e enviar notificações por jobs idempotentes.

Cadência padrão MVP: mensal por projeto; `reporting_period` identifica o mês (`YYYY-MM`), `status_date` é o último dia do mês no fuso do Tenant, e publicação deve ocorrer até o quinto dia de semana (segunda a sexta) do mês seguinte; feriados contam como dias úteis no MVP. Um rascunho ativo por projeto/período; é possível reabrir com grant e motivo.

No fluxo padrão do MVP, Project Manager com `status.update.publish` pode publicar diretamente; aprovação de segunda pessoa não é obrigatória. Correções por PM/PMO Admin autorizado exigem `status.update.correct` e motivo, e criam publicação sucessora ligada à anterior. Nenhum snapshot publicado é alterado. Falha antes do commit reverte as gravações autoritativas; falha pós-commit não desfaz publicação e os jobs são repetidos com segurança. A publicação persiste snapshot imutável `snapshot-v1` com hash canônico na mesma transação, conforme Specs 014 e 016.

## 15. RAG Engine

O sistema calcula Green/Amber/Red deterministicamente usando a versão de regras vigente na data de corte. O algoritmo MVP `rag-v1` usa o pior nível entre variação de prazo, variação de custo, marcos estratégicos vencidos, issues críticas no caminho crítico e riscos. Thresholds, entradas, estado incomplete e override estão em `docs/04-specs/015-rag-engine/business-rules.md`; toda mudança cria nova versão sem reescrever resultados publicados.

-   **Green:** dentro das tolerâncias e sem bloqueios críticos.
-   **Amber:** desvio moderado, risco crítico controlado ou marco
    ameaçado.
-   **Red:** desvio grave, estouro, issue crítico ou marco estratégico
    comprometido.

Thresholds `rag-v1` são defaults de produto configuráveis por versão e precisam de validação do dono do produto antes de ativação comercial. Dados obrigatórios ausentes geram `incomplete`, nunca Green.

Override manual exige permissão, justificativa, usuário e timestamp,
registrados no Audit Log.

## 16. Marcos e Entregas

### Milestone

ID, projeto, nome, tipo, baseline, forecast, data real, owner,
criticidade, status, progresso e evidências.

### Deliverable

ID, projeto, marco, nome, responsável, datas baseline/forecast/real,
progresso, status e evidências.

## 17. Riscos

Campos: ID, título, descrição, causa, consequência, categoria,
probabilidade, impacto, score, nível, owner, status, tendência,
mitigação, contingência, prazo e relações.

Matriz: **Probabilidade × Impacto**.

## 18. Issues

Problema já ocorrido. Campos: ID, descrição, origem, causa raiz,
impacto, prioridade, owner, abertura, prazo, resolução, aging, status,
ação corretiva e risco de origem.

Aging calculado automaticamente.

## 19. Ações

Campos: ID, descrição, origem, projeto, responsável, prioridade, início,
prazo, data real, progresso e status.

Estados: não iniciada, em andamento, bloqueada, concluída, cancelada.

## 20. Decisões

Decision Log deve responder: **o quê, quem, quando, por quê e impacto**.

Campos: ID, assunto, contexto, opções, decisão, decisor, prazo, data,
status, impacto e evidências.

Estados: pendente, aprovada, rejeitada, adiada, cancelada.

## 21. Dependências

Relações possíveis: projeto-projeto, entrega-entrega, marco-marco,
projeto-área e projeto-fornecedor.

Campos: origem, destino, tipo, owner, criticidade, prazo, status e
impacto.

## 22. Financeiro

Indicadores: orçamento aprovado/revisado, realizado, comprometido,
forecast, variação e percentual consumido.

**Baseline:** compromisso aprovado.\
**Actual:** realizado.\
**Forecast:** projeção atual.

Mudança de baseline exige permissão, motivo e histórico.

## 23. Equipe e Recursos

**Equipe** mostra participantes e papéis.\
**Recursos** mostra capacidade, demanda, disponibilidade, alocação,
conflitos, sobrecarga e forecast.

Exemplo: alocação por pessoa/projeto com alerta acima de 100%.

## 24. Documentos e Evidências

Central documental por projeto: planejamento, requisitos, arquitetura,
testes, atas, evidências, contratos e relatórios.

Metadados: versão, autor, data, categoria e entidade relacionada.

## 25. Time Machine

Reconstrói o projeto em qualquer snapshot publicado.

Exibe progresso, prazo, orçamento, escopo, riscos, issues, ações,
decisões, RAG e resumo.

Permite `Snapshot A ↔ Snapshot B` com diferenças.

## 26. Snapshot

Representação imutável do estado publicado.

Mínimo: snapshot_id, project_id, status_date, published_at/by, RAG,
progresso, prazo, orçamento, escopo, contagens, resumo, KPIs e
referências.

MVP usa cabeçalho relacional e payload JSON imutável `snapshot-v1` com
hash SHA-256 sobre JSON canônico RFC 8785. Schema e campos obrigatórios
estão definidos em `docs/04-specs/016-snapshots/database.md`; versões
incompatíveis criam nova versão de schema sem reescrever histórico.

## 27. Report Builder

Tipos: - Status Executivo; - Status Gerencial; - Riscos e Issues; -
Financeiro; - Cronograma; - Equipe e Recursos; - Personalizado.

Configurações: período, projeto/portfólio, seções e detalhe.

Saídas: Web, PDF, PPTX e XLSX quando aplicável.

## 28. Dashboards

### Projeto

Status, progresso, prazo, orçamento, escopo, cronograma, entregas,
marcos, riscos, issues, decisão necessária e insights.

### Portfólio

Projetos, RAG, on-time delivery, marcos, orçamento, benefícios, top
riscos/issues, ações, decisões e próximos marcos.

Princípio: o executivo deve identificar rapidamente **problema → impacto
→ tendência → decisão**.

## 29. PMO Copilot / Insights IA

### Perguntas

Status geral, principais riscos, probabilidade de atraso, orçamento,
prioridades, mudanças e projetos que precisam de atenção.

### Insights proativos

Atraso, economia, sobrecarga, deterioração de risco, anomalia financeira
e marco ameaçado.

### Resumos

Executive Summary, projeto, portfólio e preparação de comitê.

### Recomendações

Sugestões exigem confirmação humana quando gerarem mudanças relevantes.

### Cenários

Simular impacto em prazo, custo, marcos, dependências e riscos.

A IA deve diferenciar **fato registrado**, **inferência** e
**recomendação**.

## 30. Rotina do PMO

-   **Segunda:** portfólio, exceções, prioridades e marcos.
-   **Durante a semana:** follow-up de ações, riscos, issues e
    dependências.
-   **Reuniões:** registrar alterações e decisões diretamente no
    sistema.
-   **Fechamento:** Atualização de Status.
-   **Publicação:** dashboards/portfólio atualizados automaticamente.
-   **Comitê:** apresentar exceções e decisões necessárias.

## 31. Reuniões e governança

Durante status/comitê: revisar indicadores, marcos, riscos, ações e
registrar decisões/follow-ups.

Resultado: ata, ações, decisões e atualização do projeto.

## 32. Notificações

Eventos: ação vencendo/vencida, risco crítico, mudança de RAG, decisão
pendente, marco ameaçado, status atrasado, orçamento fora da tolerância
e recurso sobrealocado.

Canais futuros: in-app, e-mail, Teams, Slack.

## 33. Auditoria

Registrar actor, timestamp, ação, entidade, tenant, antes/depois minimizado, origem e correlation ID. Obrigatório para RAG, baseline, forecast, orçamento, decisão, publicação, exclusões críticas, administração de tenant e acesso de suporte. Acesso de suporte é Just-in-Time, motivo/ticket vinculado, aprovado por pessoa diferente, tenant/resource-scoped, read-only por padrão, até 60 minutos e auditado; break-glass exige revisão posterior. Ver `docs/07-security/admin-support-access.md`.

## 34. Multi-tenancy e RBAC

Estrutura: `Platform → Tenant → Usuários → Portfólios → Projetos`.

Perfis iniciais de produto: Platform Admin, Tenant Admin, PMO Admin, PMO, Project Manager, Contributor, Executive e Viewer, com scope explícito. Platform Root Admin é entitlement privilegiado de plataforma separado e limitado a operações de purge explicitamente concedidas; não herda acesso a conteúdo de Tenant.

Decisões MVP: somente equipe da plataforma cria, suspende e encerra tenants. Usuários podem ter memberships em vários tenants; após login, escolhem uma membership ativa (a última pode ser sugerida, nunca presumida como autorização). Convites expiram em 7 dias, são de uso único e podem ser revogados/reemitidos. Não há limite fixo no produto para tenants/usuários; quotas por plano são configuráveis pela plataforma. Encerramento exige exportação pronta antes da janela de purge de 90 dias, salvo legal hold/obrigação, conforme `docs/06-data/retention-archival.md`.

Isolamento rigoroso entre tenants. Permissões por recurso e ação.

## 35. IA por tenant / BYOK

Cada Tenant configura sua própria credencial para um ou mais providers de IA habilitados: OpenAI GPT, Google Gemini, Anthropic Claude, Meta Llama, DeepSeek e OpenRouter. A credencial é independente por Tenant/provider, gravada em secret manager e nunca retorna em respostas, logs ou audit; pode ser validada, rotacionada e desabilitada com auditoria. Meta Llama requer endpoint de inferência compatível cadastrado e validado. Sem credencial válida, recursos dependentes de IA degradam de forma segura e sem usar silenciosamente credencial de outro Tenant.

Cada configuração associa três modelos: baixa, média e alta complexidade. O AI Gateway classifica solicitações automaticamente por regra determinística e versionada baseada em use case, profundidade/forma de saída, volume/diversidade de fontes, etapas de raciocínio e orçamento de contexto; seleciona o modelo associado à classe. O usuário não escolhe ou força a classe. Mudanças de regra/configuração afetam novas solicitações e ficam rastreáveis.

A administração do Tenant inclui tela de uso/gastos de IA com período, provider, modelo, caso de uso e classe, totais de chamadas/tokens, custo reportado ou estimado e estado de medição; acesso é restrito por permissão. A medição do produto não substitui a fatura do provider.

## 36. Login

MVP: somente e-mail e senha por Supabase Auth. MFA fica para uma fase posterior; SSO Google/Microsoft está fora do MVP.

Tela split-screen.

**Esquerda:** logo, slogan, proposta de valor, arte do produto e benefícios.  
**Direita:** e-mail, senha, lembrar, recuperar senha, entrar e solicitar acesso.

Após autenticação, usuário com uma membership ativa segue para esse tenant; usuário com múltiplas memberships escolhe o tenant. O servidor revalida membership e permissions em cada operação.

## 37. Identidade visual

Dark premium, navy/grafite, azul elétrico, ciano, roxo, verde, âmbar e
vermelho para criticidade.

Cards arredondados, bordas sutis, glow moderado, alta legibilidade e
hierarquia executiva. Evitar poluição visual.

## 38. UX

-   reduzir cliques;
-   evitar duplicação;
-   gestão por exceção;
-   ações rápidas contextuais;
-   drawers para edições simples;
-   páginas para fluxos complexos;
-   filtros persistentes;
-   empty states úteis;
-   feedback imediato;
-   prevenção de erros;
-   pesquisa global via `Ctrl/Cmd + K`.

## 39. Importação e Exportação

### Importação Excel

Para dados do projeto, o usuário escolhe um Project já cadastrado e ativo em seu Tenant autorizado; a lista nunca contém projeto de outra empresa. A tela disponibiliza um `.xlsx` v1 vazio e um exemplo completo com dados sintéticos. O arquivo valida contra abas/cabeçalhos estritos do template oficial.

`Escolher Project → baixar modelo vazio/exemplo → upload .xlsx → validar/preview → carga inicial sem escolha de modo se dataset estiver vazio; caso contrário escolher Adicionar ou Reiniciar → aplicar`

Adicionar inclui somente chaves novas e bloqueia duplicatas sem sobrescrever silenciosamente. Reiniciar substitui atomicamente o conjunto operacional suportado pelo template no Project selecionado, após permissão separada, resumo de impacto e confirmação digitada. Mantém audit, publicações, snapshots, retenção e legal holds; não equivale a hard delete. Escopo v1, abas, campos e regras estão em `docs/04-specs/028-import-export/project-import-template-v1.md`.

### Exportação

Excel/CSV/PDF/PPTX conforme contexto e permissões.

## 40. KPIs

Definições padrão MVP, com corte no fim de `status_date` e timezone do Tenant; fonte, timestamp e disponibilidade acompanham cada valor. Persistir `kpi_rule_set_version='kpi-v1'` em toda publicação.

### Projeto

`progress_planned_pct` = média simples do progresso planejado dos marcos e entregas ativos na baseline para a data de corte; `progress_actual_pct` = média simples do progresso atual dos mesmos itens (0–100); itens cancelados por decisão aprovada antes do corte são excluídos de ambos. `schedule_variance_days` = `forecast_finish_date - baseline_finish_date` (dias corridos); `schedule_variance_pct` = variação em dias ÷ duração baseline em dias × 100. `cost_variance_pct` = (`forecast_at_completion - approved_budget`) ÷ `approved_budget` × 100; valor positivo é estouro. Se faltar baseline ou orçamento aprovado, retornar `null` + `not_applicable` e motivo; valor zero não pode ser inferido. Entregas no prazo = aceitas até baseline date ÷ entregas com baseline date no período × 100. Exibir também utilização de budget, forecast, riscos/issues críticos, ações vencidas e decisões pendentes como contagens/valores de fonte autorizada.

### Portfólio

Projetos ativos/por RAG, on-time delivery (mesma definição da visão Projeto agregada sobre entregas de projetos autorizados), marcos, investimento/forecast, projetos críticos, riscos/issues, ações vencidas e decisões.

## 41. Integridade e versionamento

- progresso 0–100%;
- concluído exige data real;
- risco exige owner;
- baseline alterada exige justificativa;
- status publicado não é editado diretamente; correção cria publicação sucessora imutável;
- usuários comuns arquivam/fecham, não fazem hard delete de entidades governadas; exclusão definitiva de Project só por `platform.projects.purge`, com confirmação/audit e preservação das retenções obrigatórias;
- solicitações de exclusão/anonimização de dados pessoais passam por triagem e workflow auditado;
- retenção recomendada por categoria, expiração de backup e janela de encerramento estão em `docs/06-data/retention-archival.md`; são defaults configuráveis sujeitos à revisão jurídica/contratual.

## 42. Segurança e LGPD

-   TLS;
-   hash seguro;
-   RBAC;
-   tenant isolation;
-   secrets protegidos;
-   Audit Log;
-   rate limiting;
-   validação server-side;
-   OWASP Top 10;
-   backups;
-   menor privilégio;
-   minimização, finalidade, retenção, acesso, exportação e exclusão
    quando aplicável.

## 43. Observabilidade

Logs estruturados, métricas, tracing, erros, jobs, IA, tokens, latência
e custos.

## 44. Arquitetura técnica inicial sugerida

-   Frontend/Web: **Next.js + TypeScript**
-   Deploy: **Vercel**
-   Database/Auth/Storage: **Supabase/PostgreSQL**
-   Jobs/Workflows: **Inngest**
-   Repositório/CI: **GitHub**
-   E-mail: SMTP/provider configurável
-   IA: BYOK por tenant

Redis, Kafka/RabbitMQ, Elasticsearch, Neo4j e Kubernetes ficam fora do
MVP salvo necessidade comprovada.

## 45. Requisitos não funcionais

-   performance adequada a dashboards;
-   tenant-aware desde o início;
-   agregações pesadas assíncronas quando necessário;
-   acessibilidade com objetivo WCAG AA;
-   desktop como prioridade PMO;
-   executivo responsivo para tablet/mobile;
-   disponibilidade/SLA definidos por plano futuramente.

## 46. MVP

### P0

Autenticação, tenants, RBAC, portfólios, projetos, Project Control
Center, marcos, entregas, riscos, issues, ações, decisões, dependências,
atualização de status, snapshots, dashboards, Meu Dia, notificações
in-app e audit log básico.

### P1

Financeiro, recursos, documentos, Time Machine, Report Builder,
importação Excel, PMO Copilot e exports executivos.

### P2

Integrações, cenários avançados, benefícios, capacidade avançada,
automações, analytics e workflows configuráveis.

### Fora do MVP

ERP financeiro completo, timesheet completo, substituição integral de
Jira/Project, BPM genérico, DMS corporativo, chat e videoconferência.

## 47. Métricas de sucesso

-   projetos com status atualizado;
-   tempo para preparar report;
-   ações vencidas;
-   tempo de resolução de issue;
-   riscos com owner;
-   decisões no prazo;
-   usuários ativos;
-   tempo da atualização semanal;
-   uso do Copilot;
-   redução de trabalho manual;
-   Data Quality Score.

## 48. Eventos de domínio

Os eventos candidatos oficiais do MVP, publicados após o commit da fonte autoritativa, são:

`TenantCreated`, `TenantSuspended`, `TenantTerminationStarted`, `TenantExportReady`, `TenantTerminated`, `ProjectPurgeRequested`, `ProjectPurgeProgressed`, `ProjectPurgeBlocked`, `ProjectPurged`, `MembershipGranted`, `MembershipRevoked`, `AccessGrantGranted`, `AccessGrantRevoked`, `PortfolioCreated`, `ProjectCreated`, `ProjectUpdated`, `ProjectArchived`, `BaselineChanged`, `ForecastChanged`, `MilestoneCreated`, `MilestoneCompleted`, `DeliverableCreated`, `DeliverableDelivered`, `DeliverableAccepted`, `RiskCreated`, `RiskEscalated`, `RiskMaterialized`, `RiskClosed`, `IssueCreated`, `IssueResolved`, `ActionCreated`, `ActionOverdue`, `ActionCompleted`, `DecisionRequested`, `DecisionMade`, `DependencyCreated`, `DependencyResolved`, `StatusDraftCreated`, `StatusPublished`, `StatusCorrected`, `RAGChanged`, `RAGOverridden`, `SnapshotCreated`, `BudgetThresholdExceeded`, `ResourceOverallocated`, `DocumentUploaded`, `DocumentVersionCreated`, `DocumentArchived`, `ReportRequested`, `ReportGenerated`, `ReportFailed`, `NotificationQueued`, `NotificationDelivered`, `NotificationFailed`, `ImportStarted`, `ImportValidated`, `ImportApplied`, `ProjectDataImportReplaced`, `ImportFailed`, `ExportGenerated`, `TenantSettingChanged`, `AIProviderConfigChanged`, `AIRequestStarted`, `AIResponseGenerated`, `AIUsageRecorded`, `AIActionProposed`, `AIActionConfirmed`.

Cada evento usa envelope versionado, Tenant/resource/actor/correlation IDs, payload mínimo e idempotência. Projeções, notificações, integrações e outros consumidores executam após commit; evento não substitui Audit Log. Catálogo final e compatibilidade de payload são governados por ADR/API antes da implementação.

Lifecycle de Tenant inclui `TenantAdminTransferred`, `TenantExportDisputed` e `TenantExportDisputeResolved`; eventos registram ator, motivo, escopo e versão, sem conteúdo exportado ou segredo.

## 49. Estados

### Project

planning, execution, paused, completed, cancelled.

### Portfolio

MVP: `active`, `archived`. Archive is a timestamped lifecycle action; it does not delete Projects or historical associations.

### Milestone

MVP: `planned`, `in_progress`, `blocked`, `completed`, `cancelled`. Completion records `actual_date`; baseline and forecast dates remain separate.

### Deliverable

MVP delivery state: `planned`, `in_progress`, `delivered`, `cancelled`. Acceptance is separate: `not_required`, `pending`, `accepted`, `rejected`; formal rejection preserves delivery/evidence and allows a later acceptance decision.

### Action

MVP: `not_started`, `in_progress`, `blocked`, `completed`, `cancelled`, corresponding to PDD §19. Completion requires progress 100%, actual completion timestamp and required evidence/outcome; source links remain traceable.

### Dependency

MVP: `active`, `resolved`, `cancelled`; dependency types: `finish_to_start`, `start_to_start`, `finish_to_finish`, `start_to_finish`. Self-links and cycles are rejected.

### Priority scale

Project, Issue and Action priority use the same MVP allowlist: `low`, `medium`, `high`, `critical`. Priority does not grant access or replace the explicit Issue `blocker` field.

### Status Update

MVP: `draft`, `published`, `superseded`; `under_review`/PMO approval is future scope, not required.

### Risk

identified, assessing, treating, monitoring, closed, materialized.

### Issue

open, analyzing, in_progress, blocked, resolved, closed.

## 50. Princípios de API

APIs tenant-aware, RBAC, IDs estáveis, paginação, filtros, ordenação,
versionamento quando necessário, idempotência em operações críticas e
validação server-side.

## 51. Estratégia de Spec-Driven Development

Não transformar este PDD em uma mega-spec. Decompor:

``` text
/docs
  /product
    PDD.md
  /specs
    001-authentication/
    002-multi-tenancy/
    003-rbac/
    004-portfolios/
    005-projects/
    006-project-control-center/
    007-milestones/
    008-deliverables/
    009-risks/
    010-issues/
    011-actions/
    012-decisions/
    013-dependencies/
    014-status-update/
    015-rag-engine/
    016-snapshots/
    017-my-day/
    018-project-dashboard/
    019-portfolio-dashboard/
    020-financial/
    021-resources/
    022-documents/
    023-time-machine/
    024-report-builder/
    025-pmo-copilot/
    026-notifications/
    027-audit-log/
    028-import-export/
    029-settings/
```

## 52. Estrutura recomendada de cada Spec

-   README.md
-   requirements.md
-   domain-model.md
-   user-flows.md
-   business-rules.md
-   api.md
-   database.md
-   ui.md
-   permissions.md
-   events.md
-   acceptance-criteria.md
-   test-cases.md
-   edge-cases.md

Cada spec deve responder: contexto, objetivo, atores, pré-condições,
fluxo principal, fluxos alternativos, regras, dados, permissões,
eventos, UI, API, critérios de aceitação, edge cases e testes.

## 53. Exemplo de Acceptance Criteria

``` gherkin
Given um projeto possui uma atualização de status em rascunho
And os campos obrigatórios estão válidos
When um usuário autorizado publica o status
Then o sistema deve calcular os KPIs
And calcular o RAG recomendado
And criar um snapshot imutável
And registrar o evento StatusPublished
And atualizar a visão atual do projeto
And atualizar as agregações do portfólio
And registrar a operação no Audit Log
```

## 54. Definition of Ready

Uma spec está pronta quando possui objetivo, escopo, fora de escopo,
atores, regras, modelo de dados, estados, fluxos, permissões, acceptance
criteria, edge cases, dependências e UX suficiente.

## 55. Definition of Done

Implementação, testes unitários e integração, acceptance criteria, RBAC,
tenant isolation, auditabilidade, observabilidade, erro/loading/empty
states e documentação atualizada.

## 56. Registro de decisões de produto

### Decisões confirmadas para o MVP

- Login por e-mail e senha; MFA posterior; SSO Google/Microsoft fora do MVP.
- Criação, suspensão e encerramento de tenants somente pela equipe da plataforma.
- Um usuário pode pertencer a vários tenants e seleciona uma membership ativa após login.
- Convites são single-use e expiram em 7 dias.
- Encerramento de tenant exige exportação pronta antes de janela de purge de 90 dias; legal hold/obrigação retém o escopo aplicável.
- Sem limite fixo de tenants/usuários no MVP; quotas configuráveis por plano.
- Transferência do administrador principal exige solicitação autenticada do administrador atual e confirmação de identidade do substituto. Sem administrador ativo, recuperação usa suporte JIT com ticket, aprovação independente, escopo mínimo, expiração e auditoria.
- Export de encerramento deve ser verificada e disponibilizada ao contato autorizado antes de iniciar a janela padrão de purge de 90 dias. Contestação fundamentada em até 30 dias pausa purge somente no escopo contestado até resolução auditada; silêncio não prorroga o prazo.
- Retenção recomendada por categoria consta em `docs/06-data/retention-archival.md`; usuário comum arquiva, e pedidos de exclusão/anonimização passam por triagem auditada.
- Publicação de status pode ser feita diretamente por Project Manager com permission explícita; não exige segunda aprovação no workflow padrão.
- Correção de status publicado exige permission e motivo, cria sucessora imutável ligada à anterior.
- Suporte a dados de cliente é deny-by-default e Just-in-Time, aprovado, escopado, read-only por padrão, limitado a 60 minutos e auditado.
- Status mensal no MVP: fechamento no último dia do mês no timezone do Tenant e publicação até o quinto dia útil seguinte; fórmulas e checklist `kpi-v1` em Spec 014.
- Não há limite de produto hardcoded; equipe da plataforma configura quotas por plano.

### Ainda requer decisão/validação antes de produção

- Revisão jurídica/contratual dos prazos de retenção e do fluxo de direitos dos titulares.
- Quotas específicas por plano, quando planos comerciais forem definidos.
- Duração de sessão, cookies e rate limits na revisão técnica de segurança.
- Se clientes poderão exigir approval workflow customizado numa fase futura.

As decisões de escopo MVP acima substituem a lista anterior de decisões em aberto; os detalhes de implementação permanecem nos contratos das Specs e ADRs correspondentes.

## 57. Riscos do produto

-   **Complexidade:** modularizar e priorizar.
-   **Virar sistema para alimentar:** integração, importação, gestão por
    exceção e propagação automática.
-   **Dashboard poluído:** separar executivo/operacional e usar
    progressive disclosure.
-   **Dados ruins:** validações, ownership e Data Quality Score.
-   **IA sem confiança:** explicitar fontes internas, separar
    fato/inferência e exigir confirmação em ações críticas.

## 58. Diferenciais

1.  Meu Dia;
2.  gestão por exceção;
3.  update once / propagate everywhere;
4.  status periódico estruturado;
5.  snapshots imutáveis;
6.  Time Machine;
7.  Decision Log;
8.  relação risco → issue → ação → decisão;
9.  dashboards derivados da operação;
10. Copilot contextual;
11. projeto + portfólio;
12. inteligência baseada na evolução histórica.

## 59. Visão futura

Evoluir de "como está?" para "por que?", "o que provavelmente
acontecerá?" e "onde agir primeiro?".

Modelo conceitual:

`STATE → CAUSE → IMPACT → EVIDENCE → SIMULATION → DECISION → ACTION → OUTCOME`

## 60. Ordem recomendada de especificação

1.  Foundation --- Multi-tenancy, Authentication e RBAC
2.  Portfolio & Project Core
3.  Milestones & Deliverables
4.  Risks & Issues
5.  Actions & Decisions
6.  Status Update
7.  RAG Engine
8.  Snapshots & Time Machine
9.  My Day
10. Dashboards
11. Financial & Resources
12. Documents & Reports
13. Notifications & Audit
14. PMO Copilot

------------------------------------------------------------------------

## Conclusão

O PMO Control deve ser construído como uma plataforma operacional de
**governança, execução, rastreabilidade e inteligência**, não como uma
coleção de dashboards.

Princípio central:

> **Cada dado deve possuir uma fonte de verdade, cada mudança relevante
> deve ser rastreável e cada tela deve ajudar o usuário a tomar uma ação
> ou decisão.**

Este PDD permanece como documento de visão e escopo; as Specifications
derivadas devem transformar essa visão em contratos funcionais e
técnicos testáveis.


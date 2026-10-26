# PMO Control --- Business Rules

**Documento:** `business-rules.md`\
**Camada:** Foundation\
**Status:** Under Review\
**Tipo:** Regras de negócio transversais

------------------------------------------------------------------------

## 1. Objetivo

Este documento define as regras de negócio globais do PMO Control que
atravessam múltiplos módulos e Specifications.

Regras exclusivas de uma funcionalidade devem permanecer na
Specification correspondente. Uma regra deve entrar neste documento
quando representar um princípio compartilhado do produto, uma invariante
de domínio ou um comportamento que precise ser consistente em diversos
módulos.

------------------------------------------------------------------------

## 2. Convenção das regras

As regras utilizam identificadores estáveis:

``` text
BR-<DOMÍNIO>-<NÚMERO>
```

Exemplos:

``` text
BR-TEN-001
BR-PRJ-001
BR-STS-001
BR-RAG-001
```

Os IDs devem ser usados por Specs, Acceptance Criteria, testes e ADRs
quando fizer sentido.

Níveis:

-   **MUST** --- obrigatório;
-   **SHOULD** --- recomendado, podendo existir exceção formal;
-   **MAY** --- permitido/opcional.

------------------------------------------------------------------------

# 3. Tenant e isolamento

## BR-TEN-001 --- Todo dado de negócio pertence a um Tenant --- MUST

Toda entidade de negócio persistida deve possuir associação inequívoca a
um Tenant, direta ou derivada de uma relação segura.

## BR-TEN-002 --- Isolamento entre Tenants --- MUST

Dados pertencentes a um Tenant não podem ser consultados, modificados,
exportados ou utilizados por outro Tenant.

## BR-TEN-003 --- Relações cross-tenant são negadas por padrão --- MUST

Uma entidade de um Tenant não pode referenciar uma entidade de negócio
pertencente a outro Tenant, salvo recurso explicitamente projetado e
aprovado para esse fim.

## BR-TEN-004 --- Configurações são isoladas --- MUST

Configurações, regras, integrações, chaves de IA e políticas de um
Tenant não podem alterar o comportamento de outro.

## BR-TEN-005 --- Administração da plataforma não implica acesso ao negócio --- MUST

`Platform Admin` não recebe automaticamente permissão para visualizar
conteúdo operacional dos Tenants.

------------------------------------------------------------------------

# 4. Autorização

## BR-AUTHZ-001 --- Autorização efetiva --- MUST

O acesso deve considerar:

> **Tenant + Role + Scope + Permission + Data Policy + Workflow Rule**

## BR-AUTHZ-002 --- Validação server-side --- MUST

Ocultar um botão ou menu não constitui controle de acesso. Toda operação
protegida deve ser validada no backend.

## BR-AUTHZ-003 --- Menor privilégio --- MUST

Usuários recebem somente o acesso necessário para suas
responsabilidades.

## BR-AUTHZ-004 --- Deny by default para dados sensíveis --- MUST

Na ausência de permissão explícita para informação sensível, o resultado
deve ser negação.

## BR-AUTHZ-005 --- Mesmo usuário, diferentes escopos --- MUST

Um usuário pode possuir papéis ou permissões diferentes em diferentes
escopos.

## BR-AUTHZ-006 --- Executive predominantemente read-only --- SHOULD

O perfil Executive deve ser predominantemente de consulta, podendo
executar decisões e aprovações explicitamente atribuídas.

## BR-AUTHZ-007 --- Contributor limitado --- MUST

Contributor não recebe automaticamente autoridade de gestão sobre o
projeto inteiro. Seu acesso deve ser limitado ao escopo concedido e,
quando aplicável, aos itens atribuídos.

## BR-AUTHZ-008 --- Alteração de acesso é auditável --- MUST

Concessão, revogação e mudança relevante de autorização devem gerar
registro de auditoria.

------------------------------------------------------------------------

# 5. Projeto e portfólio

## BR-PRJ-001 --- Projeto é fonte operacional central --- MUST

Informações do projeto devem ser mantidas nas entidades de domínio
correspondentes e não duplicadas em dashboards.

## BR-PRJ-002 --- Dashboard é projeção --- MUST

Dashboards de projeto, portfólio e executivo são projeções/agregações e
não fontes primárias.

## BR-PRJ-003 --- Atualizar uma vez, propagar --- MUST

Uma alteração válida em uma entidade operacional deve refletir nas
visões derivadas que utilizam aquela informação.

``` text
Update
  ↓
Domain State
  ↓
Project View
  ↓
Status Update
  ↓
Portfolio
  ↓
Executive View
  ↓
Reports / Copilot
```

## BR-PRJ-004 --- Agregações respeitam autorização --- MUST

Uma visão consolidada só pode agregar entidades que o usuário esteja
autorizado a consultar.

## BR-PRJ-005 --- Projeto encerrado preserva histórico --- MUST

Conclusão ou cancelamento de um projeto não deve eliminar sua trilha
histórica e de governança.

------------------------------------------------------------------------

# 6. Baseline e Forecast

## BR-BAS-001 --- Baseline aprovada não é sobrescrita silenciosamente --- MUST

Alterações de Baseline devem preservar versão anterior e contexto da
mudança.

## BR-BAS-002 --- Alteração relevante exige justificativa --- MUST

Mudanças de Baseline devem registrar motivo e, quando a política exigir,
aprovação.

## BR-BAS-003 --- Forecast não substitui Baseline --- MUST

Forecast representa a expectativa corrente; Baseline representa o
compromisso de referência.

## BR-BAS-004 --- Desvio deve ser calculável --- MUST

Sempre que existirem Baseline e Forecast compatíveis, o sistema deve
permitir determinar a variação.

## BR-BAS-005 --- Histórico de Baseline deve ser consultável --- MUST

Versões aprovadas devem permanecer disponíveis conforme política de
retenção.

------------------------------------------------------------------------

# 7. Milestones e Deliverables

## BR-MIL-001 --- Milestone e Deliverable são conceitos distintos --- MUST

Milestone representa um ponto significativo do cronograma. Deliverable
representa um resultado verificável.

## BR-MIL-002 --- Datas devem distinguir planejado, previsão e realizado --- MUST

Quando aplicável:

``` text
Baseline / Planned
Forecast
Actual
```

não devem ser tratados como o mesmo campo conceitual.

## BR-MIL-003 --- Marco crítico deve ser identificável --- MUST

O sistema deve permitir distinguir Milestones críticos para governança.

## BR-DEL-001 --- Entrega deve possuir critério verificável --- SHOULD

Uma Deliverable deve permitir determinar quando pode ser considerada
concluída.

## BR-DEL-002 --- Evidências podem sustentar conclusão --- SHOULD

Deliverables podem exigir ou associar Evidence conforme política do
projeto/tenant.

------------------------------------------------------------------------

# 8. Riscos

## BR-RSK-001 --- Risk representa incerteza --- MUST

Risk descreve algo que pode acontecer e afetar objetivos.

## BR-RSK-002 --- Risk possui responsável --- MUST

Riscos ativos devem possuir owner quando a governança exigir
acompanhamento.

## BR-RSK-003 --- Criticidade deve ser derivável --- MUST

Probabilidade, impacto e/ou regras configuradas devem permitir
determinar a criticidade do risco.

## BR-RSK-004 --- Risco crítico deve ser destacado --- MUST

Riscos que ultrapassem os thresholds definidos devem aparecer nas
projeções de governança apropriadas.

## BR-RSK-005 --- Materialização deve preservar rastreabilidade --- MUST

Quando um Risk se materializar, o relacionamento com o Issue resultante
deve ser preservado quando aplicável.

## BR-RSK-006 --- Encerramento não apaga histórico --- MUST

Fechar um Risk não remove seu histórico.

------------------------------------------------------------------------

# 9. Issues

## BR-ISS-001 --- Issue representa condição existente --- MUST

Issue é problema, impedimento ou condição que já ocorreu ou está
ocorrendo.

## BR-ISS-002 --- Issue e Risk não são intercambiáveis --- MUST

O sistema deve manter distinção semântica e histórica entre risco e
problema materializado.

## BR-ISS-003 --- Issue crítico deve possuir tratamento --- SHOULD

Issues críticos devem possuir owner e plano de resolução ou
justificativa equivalente.

## BR-ISS-004 --- Resolução deve preservar histórico --- MUST

Resolver ou fechar um Issue não deve apagar seu histórico.

------------------------------------------------------------------------

# 10. Actions

## BR-ACT-001 --- Action deve possuir responsável --- MUST

Ações rastreáveis devem possuir owner.

## BR-ACT-002 --- Action deve possuir prazo quando houver compromisso temporal --- SHOULD

Ações de governança normalmente devem possuir due date.

## BR-ACT-003 --- Ação vencida deve ser identificável --- MUST

Se:

``` text
due_date < current_date
AND status != completed
```

a ação deve ser identificável como vencida, respeitando regras
definitivas da Spec.

## BR-ACT-004 --- Ação pode ter origem rastreável --- MUST

Quando criada a partir de Risk, Issue, Decision, Meeting, Milestone ou
Status Update, essa origem deve poder ser preservada.

------------------------------------------------------------------------

# 11. Decisions

## BR-DEC-001 --- Decisão relevante deve possuir contexto --- MUST

Uma Decision deve preservar informação suficiente para entender o que
foi decidido e por quê.

## BR-DEC-002 --- Decisor deve ser autorizado --- MUST

Apenas usuário autorizado dentro do escopo pode concluir uma decisão.

## BR-DEC-003 --- Resultado é auditável --- MUST

Aprovação, rejeição, adiamento ou outra conclusão deve registrar ator,
timestamp e resultado.

## BR-DEC-004 --- Decisão pode gerar ações --- MUST

Ações decorrentes devem poder manter referência à Decision de origem.

## BR-DEC-005 --- Decisão pendente pode ser escalada --- SHOULD

Decisões próximas ou além do prazo devem poder aparecer em mecanismos de
atenção e notificação.

------------------------------------------------------------------------

# 12. Dependencies

## BR-DEP-001 --- Dependência possui origem e destino --- MUST

Uma Dependency deve identificar os elementos relacionados.

## BR-DEP-002 --- Dependência crítica deve ser visível --- MUST

Dependências capazes de comprometer marco, entrega ou projeto devem
aparecer nas projeções adequadas.

## BR-DEP-003 --- Dependência externa deve ser distinguível --- SHOULD

O sistema deve permitir identificar dependências que não estão sob
controle direto do projeto.

------------------------------------------------------------------------

# 13. Status Update

## BR-STS-001 --- Status Update não duplica a operação --- MUST

Status Update deve consolidar/referenciar dados operacionais existentes
em vez de criar cadastros paralelos para Risks, Issues, Milestones,
Deliverables, Actions e Decisions.

## BR-STS-002 --- Mudanças desde a publicação anterior devem ser identificáveis --- MUST

O usuário deve conseguir compreender o que mudou desde o último Status
publicado.

## BR-STS-003 --- Status possui período de referência --- MUST

Toda atualização deve estar associada a um Project e período/data de
referência.

## BR-STS-004 --- Draft é editável --- MUST

Status em Draft pode ser alterado por usuários autorizados.

## BR-STS-005 --- Under Review obedece workflow --- MUST

Quando a política exigir revisão, o Status deve respeitar o fluxo
configurado antes da publicação.

## BR-STS-006 --- Publicado é imutável --- MUST

Um Status publicado não deve ser editado como se ainda fosse Draft.

Correções devem utilizar mecanismo formal posterior, preservando o
registro publicado.

## BR-STS-007 --- Publicação deve ser atômica do ponto de vista de negócio --- MUST

Não pode existir cenário em que parte do Status esteja publicada e o
Snapshot correspondente não represente a mesma publicação.

## BR-STS-008 --- Publicação gera Snapshot --- MUST

Cada publicação deve produzir o registro histórico necessário para
reconstruir o estado publicado.

## BR-STS-009 --- Publicação gera auditoria --- MUST

Usuário, data/hora e contexto da publicação devem ser registrados.

## BR-STS-010 --- Publicação atualiza projeções --- MUST

Após publicação bem-sucedida, visões derivadas relevantes devem refletir
o novo estado conforme sua estratégia de consistência.

------------------------------------------------------------------------

# 14. Qualidade antes da publicação

## BR-DQ-001 --- Campos obrigatórios devem ser validados --- MUST

Status não pode ser publicado quando requisitos obrigatórios definidos
pela governança não forem atendidos.

## BR-DQ-002 --- Inconsistências devem ser apresentadas --- MUST

O sistema deve informar ao usuário quais condições impedem ou
comprometem a publicação.

## BR-DQ-003 --- Data Quality Score deve ser explicável --- MUST

Caso utilizado, sua composição não pode ser uma pontuação opaca sem
critérios conhecidos.

## BR-DQ-004 --- Warning e blocking error são distintos --- MUST

A governança deve poder diferenciar alertas que permitem publicação de
erros que bloqueiam a publicação.

------------------------------------------------------------------------

# 15. RAG

## BR-RAG-001 --- RAG deve ser baseado em regras rastreáveis --- MUST

A saúde não deve depender exclusivamente de escolha manual sem contexto.

## BR-RAG-002 --- Regra aplicada deve ser identificável --- MUST

Deve ser possível determinar quais fatores contribuíram para o
resultado.

## BR-RAG-003 --- RAG pode considerar múltiplas dimensões --- MUST

Exemplos:

-   prazo;
-   orçamento;
-   escopo;
-   riscos;
-   issues;
-   marcos críticos.

## BR-RAG-004 --- Thresholds podem ser configuráveis --- SHOULD

A arquitetura deve permitir evolução para regras por Tenant, portfólio
ou tipo de projeto.

## BR-RAG-005 --- Override exige autorização --- MUST

Somente usuários autorizados podem alterar o RAG efetivo quando ele
divergir do calculado/recomendado.

## BR-RAG-006 --- Override exige justificativa --- MUST

O motivo deve ser registrado.

## BR-RAG-007 --- Calculado e efetivo devem ser preservados --- MUST

Exemplo:

``` text
Calculated: RED
Effective: AMBER
Override: true
Reason: Plano de contingência aprovado
```

## BR-RAG-008 --- Override é auditável --- MUST

Ator, timestamp, resultado anterior, resultado efetivo e justificativa
devem ser preservados.

------------------------------------------------------------------------

# 16. Snapshots e histórico

## BR-SNP-001 --- Snapshot publicado é imutável --- MUST

Snapshot representa estado histórico e não deve acompanhar alterações
futuras das entidades operacionais.

## BR-SNP-002 --- Snapshot possui referência temporal --- MUST

Deve ser possível determinar quando e em qual contexto foi criado.

## BR-SNP-003 --- Time Machine utiliza histórico preservado --- MUST

Time Machine não deve reconstruir silenciosamente um estado passado
utilizando apenas os valores atuais.

## BR-SNP-004 --- Comparação histórica deve usar versões compatíveis --- SHOULD

Quando houver mudança de regras ou estrutura, a comparação deve
considerar versão/metadados suficientes para evitar interpretação
incorreta.

------------------------------------------------------------------------

# 17. Financeiro

## BR-FIN-001 --- Financeiro pode exigir permissão adicional --- MUST

Acesso geral ao Project não implica automaticamente `financial.view`.

## BR-FIN-002 --- Budget, Actual e Forecast são distintos --- MUST

Valores planejados/aprovados, realizados e previstos não devem ser
tratados como o mesmo conceito.

## BR-FIN-003 --- Variação deve ser calculável --- MUST

Quando houver valores comparáveis, o sistema deve permitir calcular
variação.

## BR-FIN-004 --- Alterações sensíveis devem ser auditáveis --- MUST

Mudanças financeiras definidas como sensíveis pela política devem gerar
auditoria.

## BR-FIN-005 --- Agregação financeira respeita Data Policy --- MUST

Dashboard ou relatório não pode revelar valores financeiros a usuário
sem autorização.

------------------------------------------------------------------------

# 18. Recursos e capacidade

## BR-RES-001 --- Alocação é temporal --- MUST

Resource Allocation deve estar relacionada a período ou intervalo.

## BR-RES-002 --- Capacidade e alocação são distintas --- MUST

A capacidade disponível não deve ser confundida com a quantidade
alocada.

## BR-RES-003 --- Sobrealocação deve ser detectável --- MUST

Quando alocação total ultrapassar capacidade conforme regra vigente, a
condição deve ser identificável.

## BR-RES-004 --- Dados de recursos podem possuir política adicional --- SHOULD

Determinadas informações de pessoas podem exigir restrição específica.

------------------------------------------------------------------------

# 19. Documentos e evidências

## BR-DOC-001 --- Documento pertence a contexto autorizado --- MUST

Documentos devem estar associados a Tenant e contexto de negócio
apropriado.

## BR-DOC-002 --- Classificação pode restringir acesso --- MUST

Acesso ao Project não implica automaticamente acesso a todo documento
confidencial.

## BR-DOC-003 --- Evidência deve manter vínculo com sua finalidade --- SHOULD

Quando uma Evidence sustentar uma decisão, entrega, risco ou publicação,
o relacionamento deve ser preservado.

## BR-DOC-004 --- Documento removido não pode quebrar auditoria silenciosamente --- MUST

Quando um documento fizer parte de evidência histórica, sua política de
retenção deve considerar esse vínculo.

------------------------------------------------------------------------

# 20. Auditoria

## BR-AUD-001 --- Eventos críticos devem ser auditados --- MUST

Incluem, inicialmente:

-   mudança de acesso;
-   alteração de Baseline;
-   alteração financeira sensível;
-   RAG Override;
-   publicação de Status;
-   decisão executiva;
-   exclusão/arquivamento relevante;
-   exportação sensível;
-   acesso administrativo excepcional.

## BR-AUD-002 --- Audit Log não é editável por usuário comum --- MUST

Usuários operacionais não podem alterar registros de auditoria.

## BR-AUD-003 --- Auditoria deve identificar ator e contexto --- MUST

Quando aplicável:

``` text
Actor
Action
Resource
Timestamp
Before
After
Reason
Tenant
```

## BR-AUD-004 --- Auditoria respeita retenção --- MUST

A política de retenção deve considerar requisitos de governança,
segurança e legislação.

------------------------------------------------------------------------

# 21. IA e PMO Copilot

## BR-AI-001 --- IA herda autorização do usuário --- MUST

O PMO Copilot não pode acessar dados fora do contexto autorizado do
usuário.

## BR-AI-002 --- IA não contorna Data Policy --- MUST

Dados financeiros, confidenciais ou restritos permanecem protegidos
quando a interface de acesso é IA.

## BR-AI-003 --- IA deve distinguir fato de recomendação --- MUST

Respostas que combinem dados observados e inferência devem permitir
compreender essa diferença.

## BR-AI-004 --- Ação consequencial exige confirmação --- MUST

IA não deve executar silenciosamente operação de governança relevante
sem confirmação/aprovação exigida.

## BR-AI-005 --- BYOK é isolado por Tenant --- MUST

Credenciais de um Tenant não podem ser utilizadas por outro.

## BR-AI-006 --- Segredos não são expostos ao frontend --- MUST

Credenciais de provedores devem ser protegidas pela arquitetura.

## BR-AI-007 --- Contexto enviado ao modelo deve ser minimizado --- SHOULD

Enviar somente informação necessária para a tarefa e autorizada para o
usuário.

## BR-AI-008 --- Saída de IA não vira fato automaticamente --- MUST

Resumo, recomendação ou classificação gerada por IA não deve alterar o
estado oficial sem fluxo apropriado.

------------------------------------------------------------------------

# 22. Relatórios e exportações

## BR-RPT-001 --- Relatório respeita autorização --- MUST

Um Report não pode incluir dado que o usuário não possa consultar.

## BR-RPT-002 --- Exportação não amplia acesso --- MUST

CSV, Excel, PDF, PPTX ou outro formato deve respeitar Scope, Permission
e Data Policy.

## BR-RPT-003 --- Relatório publicado deve indicar contexto temporal --- SHOULD

Quando relevante, deve indicar período, data de geração e/ou versão dos
dados.

## BR-RPT-004 --- Exportações sensíveis podem ser auditadas --- MUST

Quando definido pela Data Policy, exportações devem gerar Audit Event.

------------------------------------------------------------------------

# 23. Meu Dia

## BR-DAY-001 --- My Day é projeção personalizada --- MUST

Não deve se tornar uma base paralela de Actions, Decisions, Risks ou
Milestones.

## BR-DAY-002 --- Somente itens autorizados aparecem --- MUST

A consolidação deve respeitar o escopo do usuário.

## BR-DAY-003 --- Prioridade deve ser explicável --- SHOULD

Quando o sistema ordenar itens por criticidade ou urgência, os critérios
devem ser compreensíveis.

------------------------------------------------------------------------

# 24. Notificações

## BR-NOT-001 --- Notificação não concede acesso --- MUST

Receber uma notificação não concede permissão ao recurso associado.

## BR-NOT-002 --- Link deve revalidar autorização --- MUST

Ao abrir um recurso a partir de notificação, o sistema deve executar
autorização normalmente.

## BR-NOT-003 --- Preferências podem reduzir ruído --- SHOULD

Notificações não críticas podem respeitar preferências configuráveis.

## BR-NOT-004 --- Alertas críticos podem possuir política obrigatória --- MAY

Tenants podem definir determinados alertas que não podem ser
desabilitados por usuários comuns.

------------------------------------------------------------------------

# 25. Integridade e concorrência

## BR-INT-001 --- Operações críticas devem evitar atualização perdida --- MUST

Publicação, aprovação, alteração de Baseline e outras operações críticas
devem possuir estratégia de concorrência.

## BR-INT-002 --- Idempotência deve ser considerada --- MUST

Operações suscetíveis a repetição por retry não devem produzir
duplicidades indevidas.

## BR-INT-003 --- Falha parcial deve ser tratada --- MUST

Workflows com múltiplas etapas devem definir comportamento de
compensação, retry ou atomicidade.

------------------------------------------------------------------------

# 26. Exclusão, cancelamento e arquivamento

## BR-LIFE-001 --- Delete não é sinônimo de Archive --- MUST

As operações possuem semânticas distintas.

## BR-LIFE-002 --- Histórico de governança deve ser preservado --- MUST

Entidades relacionadas a publicações, decisões ou auditoria não devem
desaparecer de forma que invalide o histórico.

## BR-LIFE-003 --- Exclusão física exige política explícita --- MUST

Hard delete de dados de negócio deve ser definido por regra de retenção,
segurança e/ou legislação.

------------------------------------------------------------------------

# 27. Datas e temporalidade

## BR-TIME-001 --- Datas de negócio devem possuir semântica explícita --- MUST

Exemplos:

-   planned date;
-   baseline date;
-   forecast date;
-   actual date;
-   due date;
-   published at.

## BR-TIME-002 --- Histórico utiliza timestamp confiável --- MUST

Eventos de auditoria e publicação devem possuir timestamp consistente.

## BR-TIME-003 --- Timezone deve ser tratado explicitamente --- MUST

A estratégia técnica será definida nas convenções/arquitetura, evitando
interpretações ambíguas de datas e horários.

------------------------------------------------------------------------

# 28. Consistência de estados

## BR-STATE-001 --- Estados devem ser enumerados e documentados --- MUST

Estados de entidades relevantes não devem ser strings livres sem
contrato.

## BR-STATE-002 --- Transições inválidas devem ser impedidas --- MUST

Transições são específicas por domínio. Para Status no MVP, o fluxo é `draft → published`; correção cria publicação sucessora e não altera a versão anterior. `under_review` é uma extensão futura, não etapa obrigatória. Isso não altera workflows de approval de outros domínios.

## BR-STATE-003 --- Estado derivado não deve contradizer estado persistido --- MUST

Indicadores e projeções devem seguir regras determinísticas ou
explicitamente versionadas.

------------------------------------------------------------------------

# 29. Regras de UX com impacto de negócio

## BR-UX-001 --- UI não pode simular autorização --- MUST

A ausência de controle visual não substitui autorização real.

## BR-UX-002 --- Ações irreversíveis exigem clareza --- MUST

Operações como publicação, aprovação, exclusão relevante e override
devem informar claramente seu efeito.

## BR-UX-003 --- Estado e saúde não devem depender apenas de cor --- MUST

RAG e demais estados visuais devem possuir texto, ícone ou outro
indicador acessível além da cor.

## BR-UX-004 --- Dados críticos devem indicar contexto --- SHOULD

Informações como orçamento, prazo e RAG devem deixar claro
projeto/período quando houver risco de ambiguidade.

------------------------------------------------------------------------

# 30. Regras para integrações

## BR-EXT-001 --- Integração não contorna validação --- MUST

Dados recebidos de Jira, Microsoft Project, Excel, APIs ou outros
sistemas devem passar pelas validações aplicáveis.

## BR-EXT-002 --- Origem deve ser rastreável --- SHOULD

Quando dado vier de integração, sua origem deve poder ser identificada
quando relevante.

## BR-EXT-003 --- Conflito de fonte deve possuir regra --- MUST

Quando integração e edição interna puderem alterar o mesmo dado, a
autoridade da fonte deve ser explicitamente definida.

------------------------------------------------------------------------

# 31. Regras para observabilidade

## BR-OBS-001 --- Falhas críticas devem ser rastreáveis --- MUST

Falhas em publicação, autorização, integração, jobs e operações de IA
devem possuir telemetria suficiente para diagnóstico.

## BR-OBS-002 --- Logs técnicos não devem expor segredos --- MUST

Tokens, chaves BYOK e credenciais não devem aparecer em logs.

## BR-OBS-003 --- Observabilidade respeita classificação de dados --- MUST

Logs e traces não devem se tornar canal alternativo de exposição de
informação protegida.

------------------------------------------------------------------------

# 32. Regras para Specifications

## BR-SDD-001 --- Spec deve referenciar regras globais --- MUST

Uma Specification não deve copiar e modificar silenciosamente uma
Business Rule global.

## BR-SDD-002 --- Exceção exige explicitação --- MUST

Se uma Spec precisar divergir de uma regra `SHOULD`, deve registrar
justificativa.

Uma regra `MUST` só pode ser alterada mediante atualização formal da
Foundation e análise de impacto.

## BR-SDD-003 --- Critérios de aceitação devem ser verificáveis --- MUST

Regras implementáveis devem resultar em Acceptance Criteria e testes
correspondentes.

## BR-SDD-004 --- Regra não definida não deve ser inventada pelo agente --- MUST

Ambiguidades relevantes devem ser documentadas ou elevadas para decisão.

------------------------------------------------------------------------

# 33. Catálogo resumido por domínio

  Prefixo      Domínio
  ------------ -------------------------
  `BR-TEN`     Tenant
  `BR-AUTHZ`   Autorização
  `BR-PRJ`     Projeto/Portfólio
  `BR-BAS`     Baseline/Forecast
  `BR-MIL`     Milestones
  `BR-DEL`     Deliverables
  `BR-RSK`     Risks
  `BR-ISS`     Issues
  `BR-ACT`     Actions
  `BR-DEC`     Decisions
  `BR-DEP`     Dependencies
  `BR-STS`     Status Update
  `BR-DQ`      Data Quality
  `BR-RAG`     RAG
  `BR-SNP`     Snapshots
  `BR-FIN`     Financeiro
  `BR-RES`     Recursos
  `BR-DOC`     Documentos
  `BR-AUD`     Auditoria
  `BR-AI`      IA
  `BR-RPT`     Relatórios
  `BR-DAY`     My Day
  `BR-NOT`     Notificações
  `BR-INT`     Integridade
  `BR-LIFE`    Ciclo de vida
  `BR-TIME`    Temporalidade
  `BR-STATE`   Estados
  `BR-UX`      UX
  `BR-EXT`     Integrações
  `BR-OBS`     Observabilidade
  `BR-SDD`     Spec-Driven Development

------------------------------------------------------------------------

# 34. Pontos que permanecem para Specs/ADRs

Este documento deliberadamente não fecha:

1.  thresholds exatos do RAG;
2.  fórmula do Data Quality Score;
3.  workflow final de aprovação por Tenant;
4.  cardinalidades físicas;
5.  políticas de retenção;
6.  modelo de soft delete;
7.  fórmulas financeiras;
8.  fórmula de progresso;
9.  estratégia de consistência das projeções;
10. política de notificações;
11. estratégia de conflito de integrações;
12. modelo físico de snapshots;
13. permissões customizadas;
14. regras finais de custom fields;
15. limites por plano.

Essas decisões devem ser tomadas no documento apropriado sem contradizer
as invariantes aqui definidas.

------------------------------------------------------------------------

# 35. Referências

-   `/docs/00-foundation/README.md`
-   `/docs/00-foundation/glossary.md`
-   `/docs/00-foundation/domain-model.md`
-   `/docs/00-foundation/permission-model.md`
-   `/docs/00-foundation/data-classification.md`
-   `/docs/01-product/PDD.md`
-   `/docs/03-adrs/`
-   `/docs/04-specs/`

------------------------------------------------------------------------

# 36. Status

**Documento:** Business Rules\
**Status:** Under Review\
**Responsabilidade:** estabelecer regras de negócio transversais e
invariantes compartilhadas por todo o PMO Control.

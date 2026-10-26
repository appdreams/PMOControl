# Schedule

**Status:** Approved\
**Official path:** `/docs/05-ux/04-screens/04-project/schedule.md`\
**Visual reference:**
`/docs/05-ux/05-visual-references/schedule/schedule-main-reference.png`

## 1. Objetivo

A tela **Schedule** oferece a visão temporal consolidada do projeto,
permitindo ao PMO e aos responsáveis compreender rapidamente o
planejamento, o realizado, o forecast, os principais marcos,
dependências e desvios de prazo.

A tela deve responder principalmente:

-   Onde o projeto está no tempo?
-   O projeto está adiantado, no prazo ou atrasado?
-   Quais atividades ou marcos estão impactando o cronograma?
-   O que mudou em relação à baseline?
-   Quais dependências podem comprometer as próximas entregas?
-   Quais itens exigem atenção do PMO?

O Schedule é uma **visão operacional do cronograma**. Ele não substitui
Milestones, Deliverables ou Dependencies como fontes de verdade.

------------------------------------------------------------------------

## 2. Princípios de UX

1.  **Baseline, Forecast e Actual devem ser visualmente distinguíveis.**
2.  Desvios relevantes devem ser percebidos sem exigir leitura linha a
    linha.
3.  Itens críticos devem aparecer antes de detalhes secundários.
4.  A tela deve permitir navegar do cronograma para o registro que
    originou o evento.
5.  Alterações de datas governadas devem respeitar permissões e
    workflows.
6.  A timeline é uma representação; não cria uma segunda fonte de
    verdade.
7.  O usuário deve distinguir claramente dados atuais de informações
    históricas/publicadas.

------------------------------------------------------------------------

## 3. Atores

### PMO Admin

Visualiza todo o cronograma autorizado, acompanha desvios e pode
executar operações de governança permitidas.

### PMO

Monitora cronograma, milestones, deliverables, dependências, forecast e
exceções dentro do escopo autorizado.

### Project Manager

Atualiza informações permitidas do projeto sob sua responsabilidade,
incluindo forecast e itens operacionais conforme permissões.

### Contributor

Visualiza e atualiza somente itens atribuídos quando permitido.

### Executive

Possui visão predominantemente de leitura, focada em marcos, atrasos,
impactos e tendências.

### Viewer

Somente leitura dentro do escopo concedido.

------------------------------------------------------------------------

## 4. Permissões

A tela deve respeitar o modelo:

`Tenant + Role + Scope + Permission + Data Policy + Workflow Rule`

A autorização efetiva é validada no backend.

Possíveis capacidades:

-   visualizar cronograma;
-   visualizar milestones;
-   visualizar deliverables;
-   visualizar dependencies;
-   editar forecast autorizado;
-   criar/editar itens operacionais permitidos;
-   solicitar alteração de baseline;
-   visualizar histórico;
-   acessar evidências relacionadas.

Alteração de baseline nunca deve ser inferida apenas pela possibilidade
de arrastar um item na interface.

------------------------------------------------------------------------

## 5. Estrutura da tela

### 5.1 Header

Exibir:

-   nome do projeto;
-   código/identificador quando aplicável;
-   fase;
-   responsável;
-   RAG/health atual;
-   última atualização;
-   período exibido.

Ações possíveis:

-   alterar período;
-   filtros;
-   zoom;
-   Today;
-   exportar, quando autorizado;
-   acessar histórico;
-   criar item permitido.

------------------------------------------------------------------------

## 6. Summary Cards

A parte superior pode apresentar indicadores compactos:

-   progresso planejado;
-   progresso realizado;
-   variação;
-   milestones próximos;
-   milestones atrasados;
-   deliverables atrasados;
-   dependências críticas;
-   forecast de conclusão.

Os indicadores são derivados das fontes oficiais e não editados
diretamente no card.

------------------------------------------------------------------------

## 7. Timeline / Gantt

A região principal apresenta uma timeline/Gantt do projeto.

### Linhas possíveis

-   fases;
-   workstreams;
-   milestones;
-   deliverables;
-   atividades agregadas quando existentes;
-   dependências relevantes.

### Representações temporais

Quando disponíveis:

-   Baseline;
-   Forecast;
-   Actual.

A identidade visual deve permitir comparação sem ambiguidade.

### Milestones

Marcos aparecem como eventos destacados na linha do tempo e devem
permitir acesso ao registro de Milestone correspondente.

### Deliverables

Entregáveis aparecem no período planejado/previsto e refletem o estado
oficial de Deliverables.

------------------------------------------------------------------------

## 8. Baseline x Forecast x Actual

A tela deve preservar semanticamente:

**Baseline** --- compromisso aprovado.

**Forecast** --- previsão atual.

**Actual** --- realizado.

Exemplo conceitual:

``` text
Baseline   ────────────────●
Forecast      ─────────────────●
Actual        ───────────►
                         ↑
                      Today
```

O sistema pode calcular e apresentar variações entre essas dimensões.

Alterar Forecast não altera automaticamente Baseline.

------------------------------------------------------------------------

## 9. Today Line

A timeline deve apresentar uma indicação clara da data atual quando
estiver dentro do período visível.

Isso permite identificar:

-   atividades que deveriam ter terminado;
-   milestones próximos;
-   entregas atrasadas;
-   itens em andamento;
-   diferença entre progresso esperado e realizado.

------------------------------------------------------------------------

## 10. Dependências

Dependências relevantes podem ser representadas entre itens.

A visualização deve destacar:

-   dependência normal;
-   dependência em risco;
-   dependência bloqueadora;
-   dependência cross-project quando autorizada.

Selecionar uma dependência deve permitir acessar seus detalhes.

A tela não deve criar relacionamentos paralelos aos registros oficiais
de Dependencies.

------------------------------------------------------------------------

## 11. Exceções e criticidade

O Schedule deve priorizar visualmente:

-   atraso;
-   milestone comprometido;
-   deliverable vencido;
-   dependência bloqueadora;
-   forecast além da baseline;
-   ausência de atualização relevante.

O objetivo é permitir **gestão por exceção**.

------------------------------------------------------------------------

## 12. Painel lateral de detalhes

Ao selecionar um item, abrir painel contextual sem necessariamente
abandonar o cronograma.

Pode apresentar:

-   nome;
-   tipo;
-   status;
-   owner;
-   baseline date;
-   forecast date;
-   actual date;
-   variação;
-   dependências;
-   evidências;
-   observações;
-   última atualização.

Ações aparecem somente quando autorizadas.

------------------------------------------------------------------------

## 13. Filtros

Filtros recomendados:

-   período;
-   tipo de item;
-   status;
-   owner;
-   workstream;
-   criticidade;
-   atrasados;
-   próximos milestones;
-   dependencies;
-   somente exceções.

Os filtros alteram a visualização, não o estado do projeto.

------------------------------------------------------------------------

## 14. Zoom e navegação temporal

Suportar níveis adequados ao contexto:

-   semana;
-   mês;
-   trimestre;
-   visão completa do projeto.

A interface deve permitir:

-   voltar/avançar período;
-   ir para Today;
-   ajustar zoom;
-   preservar contexto durante navegação.

------------------------------------------------------------------------

## 15. Edição

Quando a edição estiver disponível, mudanças devem seguir regras do
domínio.

### Forecast

Pode ser atualizado por ator autorizado.

### Baseline

Não deve ser alterada silenciosamente por edição direta.

Fluxo conceitual:

`Change Request → Reason/Impact/Evidence → Approval → New Baseline Version → Audit`

### Actual

Datas reais devem refletir eventos efetivamente concluídos e regras do
módulo correspondente.

------------------------------------------------------------------------

## 16. Integração com Milestones

Fonte principal:

`/docs/04-specs/007-milestones/`

A tela deve refletir:

-   baseline date;
-   forecast date;
-   actual date;
-   status;
-   criticidade;
-   milestone ownership.

Alterações devem respeitar as regras da Spec.

------------------------------------------------------------------------

## 17. Integração com Deliverables

Fonte principal:

`/docs/04-specs/008-deliverables/`

O cronograma pode representar períodos e datas relevantes dos
entregáveis.

Deve preservar:

`Delivered ≠ Accepted`

------------------------------------------------------------------------

## 18. Integração com Dependencies

Fonte principal:

`/docs/04-specs/013-dependencies/`

Dependências exibidas na timeline devem utilizar os registros oficiais
do domínio.

Cross-project dependencies somente aparecem quando o usuário possui
acesso adequado aos recursos envolvidos.

------------------------------------------------------------------------

## 19. Integração com Status Update

O Schedule fornece contexto operacional para:

`/docs/04-specs/014-status-update/`

Mudanças de cronograma podem influenciar:

-   progresso;
-   milestones;
-   deliverables;
-   riscos;
-   resumo executivo;
-   cálculo determinístico de RAG.

A publicação de Status não transforma o Schedule em fonte histórica; o
histórico oficial é preservado por Snapshot.

------------------------------------------------------------------------

## 20. Integração com RAG

O cronograma pode fornecer sinais determinísticos para o RAG Engine,
conforme regras configuradas.

Exemplos:

-   atraso acima do threshold;
-   milestone estratégico ameaçado;
-   forecast ultrapassando tolerância.

A tela apenas apresenta o resultado aplicável.

O cálculo oficial pertence ao RAG Engine.

------------------------------------------------------------------------

## 21. Integração com Time Machine

Quando o usuário estiver consultando um ponto histórico, a interface
deve deixar explícito que se trata de **Published Historical State**.

Não misturar silenciosamente:

-   Current Operational State;
-   Published Historical State.

O histórico deve ser derivado de snapshots.

------------------------------------------------------------------------

## 22. Estados da tela

### Loading

Skeleton/feedback sem indicar dados inexistentes.

### Empty

Projeto ainda não possui itens temporais relevantes.

### Filtered Empty

Existem dados, mas nenhum atende aos filtros.

### Error

Falha ao carregar cronograma, com opção segura de retry.

### Forbidden

Usuário não possui acesso ao projeto/recurso.

### Partial External Failure

Se uma integração externa falhar, dados oficiais existentes continuam
disponíveis quando possível.

------------------------------------------------------------------------

## 23. Responsividade

O produto é desktop-first.

Em larguras menores:

-   preservar informações críticas;
-   permitir scroll horizontal controlado na timeline;
-   evitar compressão que torne datas ilegíveis;
-   painel lateral pode virar drawer;
-   filtros podem ser agrupados.

Nenhuma informação crítica deve desaparecer sem alternativa acessível.

------------------------------------------------------------------------

## 24. Acessibilidade

-   navegação por teclado;
-   foco visível;
-   labels e nomes acessíveis;
-   estado não comunicado apenas por cor;
-   contraste adequado;
-   tooltips não podem ser única fonte de informação;
-   timeline deve possuir alternativa textual/tabular utilizável.

------------------------------------------------------------------------

## 25. Direção visual

Seguir:

`/docs/05-ux/01-foundations/design-system.md`

e a referência:

`/docs/05-ux/05-visual-references/schedule/schedule-main-reference.png`

Direção:

-   navy/grafite premium;
-   azul/ciano para informação e estrutura;
-   verde para saudável/concluído;
-   âmbar para atenção;
-   vermelho para crítico;
-   roxo para inteligência/decisão quando aplicável;
-   cards e superfícies discretas;
-   alta densidade informacional sem poluição visual.

A referência visual orienta aparência; não substitui Specs.

------------------------------------------------------------------------

## 26. Interações principais

### Selecionar item

Abre detalhes.

### Hover/focus

Apresenta informações resumidas sem esconder dados essenciais.

### Criar

Disponível conforme tipo/permissão.

### Editar forecast

Executa comando de domínio autorizado.

### Solicitar mudança de baseline

Inicia workflow de governança.

### Abrir dependência

Navega para contexto autorizado.

### Abrir milestone/deliverable

Navega para a entidade oficial.

------------------------------------------------------------------------

## 27. Audit

Eventos sensíveis devem gerar Audit Event quando aplicável, incluindo:

-   mudança de baseline;
-   mudança relevante de forecast;
-   alterações governadas;
-   ações administrativas;
-   export sensível.

A UI não é responsável por garantir auditabilidade; o backend deve
fazê-lo.

------------------------------------------------------------------------

## 28. Segurança

-   tenant isolation obrigatória;
-   autorização server-side;
-   proteção contra IDOR/BOLA;
-   IDs recebidos do browser não são confiáveis;
-   dados financeiros/sensíveis relacionados não devem aparecer sem
    permissão;
-   cross-project dependency não pode revelar projeto não autorizado;
-   export deve respeitar scope e data policy.

------------------------------------------------------------------------

## 29. Acceptance Criteria de UX

1.  Usuário autorizado consegue visualizar o cronograma do projeto.
2.  Baseline, Forecast e Actual são distinguíveis.
3.  Atrasos e exceções são identificáveis rapidamente.
4.  Milestones e Deliverables apontam para entidades oficiais.
5.  Dependências relevantes podem ser compreendidas sem criar estado
    paralelo.
6.  Usuário não autorizado não recebe dados protegidos.
7.  Alterar Forecast não altera Baseline automaticamente.
8.  Mudança de Baseline segue workflow de governança.
9.  Current e Historical State não são confundidos.
10. A timeline possui alternativa acessível.
11. A tela funciona sem depender de IA.
12. Falha de integração não corrompe o estado oficial.
13. Visual segue o design system e a referência existente.
14. Ações sensíveis respeitam permission, scope, workflow e audit.

------------------------------------------------------------------------

## 30. Relações documentais

### Functional Source

-   `/docs/04-specs/005-projects/`
-   `/docs/04-specs/007-milestones/`
-   `/docs/04-specs/008-deliverables/`
-   `/docs/04-specs/013-dependencies/`
-   `/docs/04-specs/014-status-update/`
-   `/docs/04-specs/015-rag-engine/`
-   `/docs/04-specs/016-snapshots/`

### UX

-   `/docs/05-ux/01-foundations/design-system.md`
-   `/docs/05-ux/01-foundations/accessibility.md`
-   `/docs/05-ux/01-foundations/responsive-rules.md`
-   `/docs/05-ux/03-patterns/interaction-patterns.md`
-   `/docs/05-ux/05-visual-references/schedule/schedule-main-reference.png`

### Data / Security / API

-   `/docs/06-data/`
-   `/docs/07-security/`
-   `/docs/08-api/`

### Testing

-   `/docs/11-testing/`

------------------------------------------------------------------------

## 31. Invariante final

> **Schedule visualiza e opera sobre o tempo do projeto; não cria uma
> segunda verdade sobre o projeto.**

As entidades oficiais continuam sendo governadas por suas respectivas
Specs, e o histórico oficial continua sendo preservado por snapshots
publicados.

Behavioral contract trace: [SCREEN-TRACEABILITY.md](../../SCREEN-TRACEABILITY.md).

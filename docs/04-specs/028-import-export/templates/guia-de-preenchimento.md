# Guia simples para preencher a planilha de importação do projeto

Este guia explica, sem exigir conhecimento técnico, como preencher os arquivos Excel de importação do PMO Control.

## Baixe o arquivo certo

- [Modelo vazio](project-import-template-v1-empty.xlsx): use para preparar seus próprios dados.
- [Exemplo preenchido](project-import-template-v1-example.xlsx): consulte para entender como preencher cada coluna. Os dados são fictícios; não importe o exemplo sem substituir o conteúdo.

Os dois arquivos têm as mesmas abas e colunas. Não renomeie abas, colunas ou arquivo de modelo, e não acrescente abas ou colunas. O sistema reconhece os nomes exatamente como estão.

## Antes de preencher

1. Na tela de importação, selecione o projeto correto. A lista deve mostrar somente projetos da sua empresa aos quais você tem acesso.
2. Baixe o modelo vazio da própria tela. Quando o recurso estiver implementado, essa cópia virá identificada com o projeto selecionado. O arquivo-mestre deste repositório deixa o código em branco.
3. Abra também o exemplo preenchido para consultar formatos e relações entre registros.
4. Preencha uma linha por item, começando na linha abaixo dos cabeçalhos. Não apague nem altere a primeira linha.
5. Salve como arquivo `.xlsx`. Não use `.xls` ou `.xlsm`.

> **Atenção:** o projeto precisa já existir no sistema. Esta planilha cadastra dados operacionais dentro dele; não cria empresa nem projeto.

## O que significa cada coluna

As palavras entre parênteses são os nomes que aparecem nos cabeçalhos do Excel.

### Aba `Projeto` — identificação do projeto

| Coluna | O que informar |
|---|---|
| `project_code` | Código do projeto selecionado na tela. Deve ser o mesmo código do projeto. Não invente outro. No download feito pela tela, o sistema preencherá esse campo. |
| `template_version` | Versão do modelo. Mantenha `project-import-v1` exatamente como está. |

Preencha somente as duas células da linha de identificação; não crie outras linhas nessa aba.

### Aba `Marcos` — etapas importantes e datas planejadas

| Coluna | O que informar |
|---|---|
| `external_key` | Código único que você cria para identificar este marco, por exemplo `M-001`. Não repita o código nesta aba. |
| `title` | Nome curto do marco. |
| `description` | Explicação ou resultado esperado. |
| `planned_start_date` | Data planejada para começar, no formato `AAAA-MM-DD`, por exemplo `2026-04-10`. |
| `planned_due_date` | Data planejada para terminar, no mesmo formato. |
| `forecast_start_date` | Previsão atual de início, se diferente ou mais atual que o planejamento. |
| `forecast_due_date` | Previsão atual de término. |
| `actual_date` | Data em que o marco foi realmente concluído, se já ocorreu. |
| `status` | Situação do marco. Use uma das opções oferecidas na lista do Excel, se disponível. |
| `owner_email` | E-mail da pessoa responsável, que já deve ser integrante ativo da empresa e autorizada no projeto. |
| `progress_percent` | Percentual concluído, número de 0 a 100. Informe apenas o número, sem o símbolo `%`. |

### Aba `Entregas` — produtos ou resultados a entregar

| Coluna | O que informar |
|---|---|
| `external_key` | Código único da entrega nesta aba, por exemplo `E-001`. |
| `title` | Nome curto do que será entregue. |
| `description` | Detalhes do conteúdo ou do resultado esperado. |
| `due_date` | Data limite prevista, em `AAAA-MM-DD`. |
| `status` | Situação atual da entrega; use uma opção válida da lista do modelo. |
| `acceptance_status` | Informa se a entrega ainda aguarda avaliação ou se foi aceita/rejeitada; escolha um valor permitido no modelo. |
| `delivered_at` | Data e hora em que foi entregue, quando aplicável. Use data/hora ISO 8601 em UTC, por exemplo `2026-04-10T15:30:00Z`. |
| `accepted_at` | Data e hora em que foi aceita, quando aplicável, no mesmo formato UTC. |
| `owner_email` | E-mail do responsável, que deve ser integrante ativo e autorizado no projeto. |

### Aba `Riscos` — situações incertas que podem afetar o projeto

| Coluna | O que informar |
|---|---|
| `external_key` | Código único do risco nesta aba, por exemplo `R-001`. |
| `title` | Nome curto do risco. |
| `description` | O que pode acontecer e como pode afetar o projeto. |
| `cause` | Causa que pode gerar o risco. |
| `consequence` | Consequência caso o risco aconteça. |
| `category` | Código da categoria de risco. Os valores padrão iniciais e seus significados estão na tabela de códigos abaixo; a empresa pode configurar categorias adicionais permitidas, que devem aparecer na cópia de modelo baixada na tela. |
| `probability` | Chance de acontecer, de 1 (baixa) a 5 (alta). Use número inteiro. |
| `impact` | Gravidade do efeito, de 1 (baixo) a 5 (alto). Use número inteiro. |
| `status` | Situação atual do risco; use um valor permitido no modelo. |
| `trend` | Tendência do risco: use um dos códigos padrão `improving`, `stable` ou `worsening`, explicados na tabela abaixo. |
| `owner_email` | E-mail da pessoa que acompanha o risco, integrante ativo e autorizado no projeto. |
| `due_date` | Data prevista para tratar ou revisar o risco, em `AAAA-MM-DD`. |
| `mitigation` | Medidas para diminuir a chance ou o impacto. |
| `contingency` | O que fazer se o risco realmente acontecer. |

### Aba `Issues` — problemas que já aconteceram

| Coluna | O que informar |
|---|---|
| `external_key` | Código único do problema nesta aba, por exemplo `I-001`. |
| `title` | Nome curto do problema. |
| `description` | O que aconteceu e qual parte do projeto foi afetada. |
| `root_cause` | Causa principal conhecida, se identificada. |
| `impact` | Efeito do problema no projeto. |
| `priority` | Urgência: `low` (baixa), `medium` (média), `high` (alta) ou `critical` (crítica). |
| `blocker` | Indica se impede o avanço do trabalho. Use o formato booleano aceito pelo modelo (por exemplo, verdadeiro/falso). |
| `status` | Situação atual do problema; escolha um valor permitido. |
| `owner_email` | E-mail da pessoa responsável por resolver, integrante ativo e autorizado no projeto. |
| `due_date` | Data prevista para resolver, em `AAAA-MM-DD`. |
| `resolved_at` | Data e hora em que foi resolvido, quando aplicável, em UTC ISO 8601. |
| `resolution` | O que foi feito para resolver o problema. |

### Aba `Acoes` — tarefas de acompanhamento

| Coluna | O que informar |
|---|---|
| `external_key` | Código único da ação nesta aba, por exemplo `A-001`. |
| `title` | Nome curto da tarefa. |
| `description` | Passos ou resultado esperado. |
| `source_type` | Use `risk`, `issue`, `milestone`, `deliverable` ou `decision` para vincular a ação a um item desse tipo; use `manual` se não houver item de origem. |
| `source_external_key` | Código do item de origem, igual ao `external_key` na aba correspondente. Obrigatório para `risk`, `issue`, `milestone`, `deliverable` e `decision`; deixe vazio para `manual`. |
| `owner_email` | E-mail da pessoa responsável, integrante ativo e autorizada no projeto. |
| `due_date` | Data limite, em `AAAA-MM-DD`. |
| `priority` | Urgência: `low`, `medium`, `high` ou `critical`. |
| `status` | Situação da ação, usando valor permitido no modelo. |
| `progress_percent` | Percentual concluído, de 0 a 100, sem o símbolo `%`. |
| `actual_completed_at` | Data e hora reais de conclusão, se concluída, em UTC ISO 8601. |
| `completion_outcome` | Resultado obtido ao concluir a ação. |
| `cancellation_reason` | Motivo pelo qual a ação foi cancelada, se aplicável. |

### Aba `Decisoes` — decisões tomadas ou pendentes

| Coluna | O que informar |
|---|---|
| `external_key` | Código único da decisão nesta aba, por exemplo `D-001`. |
| `title` | Assunto da decisão. |
| `description` | Contexto e detalhes necessários para entendê-la. |
| `decision_maker_email` | E-mail de quem tomou ou deve tomar a decisão; essa pessoa precisa estar ativa e autorizada no projeto. |
| `due_date` | Data limite para decidir, em `AAAA-MM-DD`. |
| `status` | Situação da decisão, conforme valores permitidos. |
| `decided_at` | Data e hora em que a decisão foi tomada, se já ocorreu, em UTC ISO 8601. |
| `outcome` | Decisão final ou resultado, quando já definido. |

### Aba `Dependencias` — relações entre itens do projeto

| Coluna | O que informar |
|---|---|
| `external_key` | Código único desta relação nesta aba, por exemplo `DEP-001`. |
| `source_type` | Tipo do item de origem: `project`, `deliverable`, `milestone`, `area` ou `supplier`. |
| `source_external_key` | Código do primeiro item, igual ao `external_key` na aba desse tipo. |
| `target_type` | Tipo do item de destino: `project`, `deliverable`, `milestone`, `area` ou `supplier`. |
| `target_external_key` | Código do segundo item na aba correspondente. |
| `dependency_type` | Tipo da relação ou dependência, conforme valores aceitos. |
| `status` | Situação da dependência, usando uma opção permitida. |
| `lag_days` | Atraso ou intervalo entre os itens, em dias inteiros, se aplicável. |

## Valores aceitos e significado dos códigos

Os códigos abaixo devem ser digitados exatamente como aparecem, em letras minúsculas e com `_` no lugar dos espaços. O Excel de exemplo traz listas suspensas para os campos de enumeração fixa. Se abrir o arquivo em um leitor que não mostre essas listas, use as tabelas desta seção.

### Valores fechados definidos pelo sistema

| Aba e coluna | Valores aceitos | O que cada valor significa |
|---|---|---|
| `Marcos.status` | `planned`, `in_progress`, `blocked`, `completed`, `cancelled` | `planned`: planejado; `in_progress`: em andamento; `blocked`: impedido; `completed`: concluído; `cancelled`: cancelado. |
| `Entregas.status` | `planned`, `in_progress`, `delivered`, `cancelled` | `planned`: planejada; `in_progress`: em andamento; `delivered`: entregue; `cancelled`: cancelada. |
| `Entregas.acceptance_status` | `not_required`, `pending`, `accepted`, `rejected` | `not_required`: não exige aceite formal; `pending`: aguarda avaliação; `accepted`: aceita; `rejected`: rejeitada. |
| `Riscos.status` | `identified`, `assessing`, `treating`, `monitoring`, `closed`, `materialized` | `identified`: identificado; `assessing`: em avaliação; `treating`: com resposta em andamento; `monitoring`: em acompanhamento; `closed`: encerrado; `materialized`: convertido em problema (Issue). |
| `Issues.priority` | `low`, `medium`, `high`, `critical` | Baixa, média, alta ou crítica. |
| `Issues.blocker` | `TRUE`, `FALSE` | `TRUE`: impede ou bloqueia o avanço; `FALSE`: não bloqueia. Use esses códigos em inglês, mesmo que o Excel localize outras funções ou palavras. |
| `Issues.status` | `open`, `analyzing`, `in_progress`, `blocked`, `resolved`, `closed` | Aberto; em análise; em andamento; bloqueado; resolvido; encerrado. `resolved` e `closed` exigem data e descrição da resolução. |
| `Acoes.priority` | `low`, `medium`, `high`, `critical` | Baixa, média, alta ou crítica. |
| `Acoes.status` | `not_started`, `in_progress`, `blocked`, `completed`, `cancelled` | Não iniciada; em andamento; bloqueada; concluída; cancelada. Uma ação concluída exige 100% e data real de conclusão. |
| `Decisoes.status` | `pending`, `approved`, `rejected`, `deferred`, `cancelled` | Pendente; aprovada; rejeitada; adiada; cancelada. Estados finais precisam de data, responsável pela decisão e resultado. |
| `Dependencias.source_type` e `Dependencias.target_type` | `project`, `deliverable`, `milestone`, `area`, `supplier` | Tipo do item de origem ou destino: projeto; entrega; marco; área; fornecedor. O item precisa existir e ser permitido para aquela relação. |
| `Dependencias.dependency_type` | `finish_to_start`, `start_to_start`, `finish_to_finish`, `start_to_finish` | `finish_to_start`: o destino só começa quando a origem termina; `start_to_start`: ambos podem começar juntos; `finish_to_finish`: o destino só termina quando a origem termina; `start_to_finish`: o destino só termina depois que a origem começa. |
| `Dependencias.status` | `active`, `resolved`, `cancelled` | Relação ativa; dependência resolvida; relação cancelada. |

### Valores padrão iniciais do sistema

Ao criar a empresa (Tenant), o sistema cadastra estas opções. Os códigos são digitados como abaixo; os nomes em português explicam seu significado. A empresa pode personalizar os rótulos exibidos e, nas taxonomias indicadas, configurar opções adicionais. Na importação, só são aceitos códigos habilitados para a empresa selecionada.

| Aba e coluna | Código aceito inicialmente | Significado |
|---|---|---|
| Cadastro de marcos — `type` | `project_start` | Início do projeto. Este campo não está na planilha de importação v1. |
| Cadastro de marcos — `type` | `phase_gate` | Aprovação ou passagem de uma fase. Este campo não está na planilha de importação v1. |
| Cadastro de marcos — `type` | `major_deliverable` | Entrega principal ou marco associado a uma entrega importante. Este campo não está na planilha de importação v1. |
| Cadastro de marcos — `type` | `review` | Revisão ou avaliação planejada. Este campo não está na planilha de importação v1. |
| Cadastro de marcos — `type` | `project_end` | Encerramento do projeto. Este campo não está na planilha de importação v1. |
| Cadastro de marcos — `type` | `other` | Outro tipo de marco não coberto pelas opções anteriores. Este campo não está na planilha de importação v1. |
| Cadastro de marcos — `criticality` | `low` / `medium` / `high` / `critical` | Criticidade baixa / média / alta / crítica. Este campo não está na planilha de importação v1. |
| `Riscos.category` | `scope` | Escopo do projeto. |
| `Riscos.category` | `schedule` | Cronograma e prazos. |
| `Riscos.category` | `cost` | Custos e orçamento. |
| `Riscos.category` | `quality` | Qualidade dos resultados ou processos. |
| `Riscos.category` | `resource` | Disponibilidade de pessoas ou outros recursos. |
| `Riscos.category` | `supplier` | Fornecedor ou parceiro externo. |
| `Riscos.category` | `technical` | Tecnologia, arquitetura ou viabilidade técnica. |
| `Riscos.category` | `security` | Segurança da informação ou acesso. |
| `Riscos.category` | `compliance` | Leis, normas, contratos ou políticas. |
| `Riscos.category` | `other` | Outra categoria de risco. |
| `Riscos.trend` | `improving` | O risco está diminuindo (probabilidade ou impacto menor). |
| `Riscos.trend` | `stable` | O risco não mudou de forma relevante. |
| `Riscos.trend` | `worsening` | O risco está aumentando (probabilidade ou impacto maior). |
| `Acoes.source_type` | `risk` | A ação foi criada para tratar um risco. |
| `Acoes.source_type` | `issue` | A ação foi criada para resolver um problema ocorrido. |
| `Acoes.source_type` | `milestone` | A ação está ligada a um marco. |
| `Acoes.source_type` | `deliverable` | A ação está ligada a uma entrega. |
| `Acoes.source_type` | `decision` | A ação executa ou acompanha uma decisão. |
| `Acoes.source_type` | `manual` | Ação independente, sem registro de origem. Nesse caso, deixe `source_external_key` vazio. |

Os códigos acima são os padrões iniciais do sistema e são provisionados para cada empresa. A empresa pode personalizar os rótulos e, para categorias de risco, configurar categorias adicionais. A cópia do modelo baixada pela tela deve refletir as categorias habilitadas para a empresa; o arquivo-mestre deste repositório contém somente a lista inicial. Os padrões de tipo e criticidade de marco se aplicam ao cadastro de marcos na aplicação; a planilha `Marcos` v1 não tem colunas para esses dois campos. Para `Acoes.source_type`, os códigos diferentes de `manual` exigem que o item relacionado exista no mesmo projeto e seu `external_key` seja informado. `manual` nunca recebe uma chave de origem.
### Formato aceito nos demais campos

| Tipo de campo | Colunas | O que preencher |
|---|---|---|
| Código externo | `external_key` em todas as abas de dados | Texto criado por você, não vazio e único dentro da aba. Exemplos: `M-001`, `R-001`, `A-001`. O código não é o ID interno do sistema. |
| Referência a outro item | `source_external_key`, `target_external_key` | Copie exatamente o `external_key` do item relacionado. O tipo informado deve apontar para a aba/tipo correspondente e o item precisa ser do mesmo projeto. |
| Código do projeto e versão | `Projeto.project_code`, `Projeto.template_version` | Código do projeto escolhido na tela; versão literal `project-import-v1`. Não altere a versão. |
| Data | `planned_start_date`, `planned_due_date`, `forecast_start_date`, `forecast_due_date`, `actual_date`, `due_date` | Data real do calendário no formato `AAAA-MM-DD`, por exemplo `2026-04-10`. Não use formatos como `10/04/26`. |
| Data e hora | `delivered_at`, `accepted_at`, `resolved_at`, `actual_completed_at`, `decided_at` | Data/hora ISO 8601 em UTC, terminando em `Z`, por exemplo `2026-04-10T15:30:00Z`. Deixe vazio se ainda não ocorreu. |
| Percentual | `progress_percent` | Número de 0 a 100, inclusive. Use `0` a `100` sem o caractere `%`; casas decimais podem ser usadas quando necessário. |
| Escala de risco | `probability`, `impact` | Número inteiro de 1 a 5. Em `probability`, 1 significa muito improvável e 5 muito provável; em `impact`, 1 significa efeito muito baixo e 5 efeito muito alto. |
| Intervalo | `lag_days` | Número inteiro igual ou maior que zero, contado em dias. `0` significa sem intervalo/atraso adicional. |
| E-mail de pessoa | `owner_email`, `decision_maker_email` | E-mail de uma pessoa que já seja integrante ativa da empresa e esteja autorizada no projeto. O e-mail não concede acesso. |
| Texto livre | `title`, `description`, `cause`, `consequence`, `mitigation`, `contingency`, `root_cause`, `impact`, `resolution`, `completion_outcome`, `cancellation_reason`, `outcome` | Texto legível que descreve o item, causa, consequência, medida ou resultado. Não há códigos fechados para esses campos; respeite os limites exibidos pela aplicação. Campos opcionais sem informação devem ficar vazios. |

> Os códigos padrão iniciais e suas regras estão definidos nas Specs dos módulos e no contrato v1. Antes de importar, confira os valores habilitados para a empresa. O importador não aceita que o usuário crie códigos diretamente no arquivo.

## Regras para a planilha ser aceita

- Mantenha os nomes das oito abas e dos cabeçalhos exatamente iguais aos do modelo.
- Cada item precisa de um `external_key` preenchido e único dentro da respectiva aba. Você pode usar sequências como `M-001`, `M-002`, `R-001` e `A-001`; não use o mesmo código duas vezes na mesma aba.
- Para ligar uma ação ou dependência a outro item, copie exatamente o código desse item para a coluna de referência. O item relacionado precisa estar no mesmo projeto e na aba correta.
- Datas sem horário usam `AAAA-MM-DD`. Datas com horário usam UTC e terminam em `Z`, como `2026-04-10T15:30:00Z`.
- Deixe em branco o que não se aplica; não escreva “N/A” ou “não sei”, a menos que o campo peça essa informação.
- Não use fórmulas, macros, links externos, células mescladas para substituir dados, nem abas ou colunas extras. Digite os valores finais nas células.
- Os e-mails informados devem pertencer a integrantes ativos da empresa e autorizados no projeto. Um endereço digitado na planilha não concede acesso.
- Use as listas de opções e validações do arquivo como referência para campos de situação, categoria, prioridade e tipo. Não invente variações de escrita.
- O arquivo de exemplo contém códigos e pessoas fictícias: troque-os por informações do seu projeto.

## O que acontece depois do envio

O sistema confere o arquivo e mostra uma prévia com os itens que serão importados e os problemas encontrados. Se houver erro, nenhum dado será gravado; corrija as células indicadas e envie novamente.

- **Projeto sem dados operacionais importáveis:** após uma validação sem erros e a prévia, os dados são carregados sem perguntar se deseja acrescentar ou reiniciar.
- **Projeto que já tem dados operacionais:** será necessário escolher entre acrescentar os novos itens ou reiniciar os dados operacionais cobertos por este modelo. O sistema apresenta quantidades e pede confirmação.
- **Acrescentar dados:** cria itens novos. Se um código já existir, o sistema informa conflito em vez de substituir o item existente.
- **Reiniciar dados do projeto:** arquiva os registros operacionais atuais cobertos pela importação e carrega os novos, após permissão e confirmação reforçada. Não apaga o projeto, publicações de status, auditoria, snapshots ou histórico que precise ser retido.

Este modelo cobre marcos, entregas, riscos, problemas, ações, decisões e dependências. Equipe, finanças, recursos, documentos anexos e publicações de status são tratados em outras áreas e não serão importados por estas abas.




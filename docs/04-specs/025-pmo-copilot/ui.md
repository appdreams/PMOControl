# SPEC-025 — PMO Copilot — UI

**Status:** Draft — estados e conteúdo de tela definidos

## Conteúdo e ações

Exibir `CopilotInteraction` dentro do scope `Actor + authorized sources`, campos prioritários `tenant_id, actor_id, question, authorized_scope, source_refs, fact_inference_recommendation`, origem/status e timestamps relevantes. Ações conforme grant: askCopilot, getSources, proposeAction, confirmAction. Exibir Current vs Published quando a fonte for snapshot.

### Configuração de IA do Tenant

Área de administração do Tenant com provider, credencial própria (entrada protegida, nunca reapresentada), ações validar/rotacionar/desabilitar e estado da última validação. Exibir os três modelos mapeados para complexidade baixa, média e alta; classificação é automática, com explicação curta de categoria/regra para cada solicitação e sem controle manual para forçar classe/modelo. A tela mostra versão e data da configuração e falhas sem expor segredo.

### Uso e gastos de IA

Tela autorizada `ai.cost.view` com filtro de período e agrupamento por provider, modelo, use case, complexidade e dia; totais de solicitações, tokens de entrada/saída/cache e custo. Diferenciar custo reportado pelo provider, estimativa por tarifa local e uso sem preço/telemetria. Mostrar moeda, fonte da tarifa, timestamp de atualização, estado vazio e exportação só com `ai.cost.export`. Nunca somar moedas distintas sem conversão explicitamente identificada; métricas locais não substituem a fatura oficial do provider.

## Estados

Loading skeleton; empty state com ação permitida; validation errors junto ao campo; forbidden sem revelar recurso; conflict com opção recarregar; erro recuperável com retry; sucesso confirmado após commit. Campos sensíveis mascarados/ocultos pela data policy, não apenas CSS.

## Acessibilidade

Ações por teclado, foco visível, labels associados, mensagens anunciadas e status não comunicado somente por cor. Referência visual é não normativa; permissão/regra segue esta Spec e Security docs.

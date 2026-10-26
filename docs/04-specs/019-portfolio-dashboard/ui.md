# SPEC-019 — Portfolio Dashboard — UI

**Status:** Draft — estados e conteúdo de tela definidos

## Conteúdo e ações

Exibir `PortfolioDashboardProjection` dentro do scope `Portfolio + authorized Projects`, campos prioritários `portfolio_id, temporal_mode, as_of, authorized_project_count, rag_distribution, delivery_metrics`, origem/status e timestamps relevantes. Ações conforme grant: getPortfolioDashboard, refreshProjection. Exibir Current vs Published quando a fonte for snapshot.

## Estados

Loading skeleton; empty state com ação permitida; validation errors junto ao campo; forbidden sem revelar recurso; conflict com opção recarregar; erro recuperável com retry; sucesso confirmado após commit. Campos sensíveis mascarados/ocultos pela data policy, não apenas CSS.

## Acessibilidade

Ações por teclado, foco visível, labels associados, mensagens anunciadas e status não comunicado somente por cor. Referência visual é não normativa; permissão/regra segue esta Spec e Security docs.

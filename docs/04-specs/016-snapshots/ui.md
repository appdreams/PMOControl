# SPEC-016 — Snapshots — UI

**Status:** Draft — estados e conteúdo de tela definidos

## Conteúdo e ações

Exibir Snapshot imutável no scope `Project/Snapshot`, campos publicados, origem/publication, data, versão e integridade. Ações conforme grant: getSnapshot, listSnapshots, compareSnapshots, verifySnapshotHash. A criação ocorre somente ao publicar/corrigir Status. Exibir Current vs Published quando a fonte for snapshot.

## Estados

Loading skeleton; empty state com ação permitida; validation errors junto ao campo; forbidden sem revelar recurso; conflict com opção recarregar; erro recuperável com retry; sucesso confirmado após commit. Campos sensíveis mascarados/ocultos pela data policy, não apenas CSS.

## Acessibilidade

Ações por teclado, foco visível, labels associados, mensagens anunciadas e status não comunicado somente por cor. Referência visual é não normativa; permissão/regra segue esta Spec e Security docs.

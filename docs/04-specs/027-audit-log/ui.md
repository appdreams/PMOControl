# SPEC-027 — Audit Log — UI

**Status:** Draft — estados e conteúdo de tela definidos

## Conteúdo e ações

Exibir `AuditEvent` dentro do scope `Tenant + audit permission`, campos prioritários `tenant_id, actor_id, action, resource_type, resource_id, occurred_at`, origem/status e timestamps relevantes. Ações conforme grant: appendAuditEvent, queryAuditEvents, exportAuditEvidence. Exibir Current vs Published quando a fonte for snapshot.

## Estados

Loading skeleton; empty state com ação permitida; validation errors junto ao campo; forbidden sem revelar recurso; conflict com opção recarregar; erro recuperável com retry; sucesso confirmado após commit. Campos sensíveis mascarados/ocultos pela data policy, não apenas CSS.

## Acessibilidade

Ações por teclado, foco visível, labels associados, mensagens anunciadas e status não comunicado somente por cor. Referência visual é não normativa; permissão/regra segue esta Spec e Security docs.

# SPEC-003 — RBAC — UI

**Status:** Draft — estados e conteúdo de tela definidos

## Conteúdo e ações

Exibir `AccessGrant` dentro do scope `Tenant/Membership/Portfolio/Project`, campos prioritários `user_id, role_id, permission_key, scope_type, scope_id, effect`, origem/status e timestamps relevantes. Ações conforme grant: assignRole, revokeGrant, evaluateAccess, listEffectivePermissions. Exibir Current vs Published quando a fonte for snapshot.

## Estados

Loading skeleton; empty state com ação permitida; validation errors junto ao campo; forbidden sem revelar recurso; conflict com opção recarregar; erro recuperável com retry; sucesso confirmado após commit. Campos sensíveis mascarados/ocultos pela data policy, não apenas CSS.

## Acessibilidade

Ações por teclado, foco visível, labels associados, mensagens anunciadas e status não comunicado somente por cor. Referência visual é não normativa; permissão/regra segue esta Spec e Security docs.

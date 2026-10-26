# SPEC-005 — Projects — UI

**Status:** Draft — estados e conteúdo de tela definidos

## Conteúdo e ações

Exibir `Project` dentro do scope `Tenant/Portfolio/Project`, campos prioritários `tenant_id, portfolio_id, name, code, sponsor_id, project_manager_id`, origem/status e timestamps relevantes. Ações conforme grant: createProject, updateProject, changeBaseline, assignMember, archiveProject. Exibir Current vs Published quando a fonte for snapshot.

## Estados

Loading skeleton; empty state com ação permitida; validation errors junto ao campo; forbidden sem revelar recurso; conflict com opção recarregar; erro recuperável com retry; sucesso confirmado após commit. Campos sensíveis mascarados/ocultos pela data policy, não apenas CSS.

## Acessibilidade

Ações por teclado, foco visível, labels associados, mensagens anunciadas e status não comunicado somente por cor. Referência visual é não normativa; permissão/regra segue esta Spec e Security docs.

## Exclusão administrativa

Ações normais oferecem archive, nunca hard delete. Um console administrativo separado mostra somente identificadores/metadados mínimos a Platform Root Admin. O botão “Excluir definitivamente” abre uma prévia com código/nome do Project, Tenant, contagens por módulo, dados que serão apagados, histórico que será retido, holds e impedimentos. A confirmação exige motivo e digitação do código do Project; durante execução, mostrar job/status e separar concluído, retido e bloqueado. Não exibir conteúdo de negócio do Tenant ao Platform Root Admin.

# SPEC-004 — Portfolios — Test Cases

**Status:** Partial — criação/listagem/update/archive/associação cobertos por smoke transacional DEV; demais workflows pendentes

- **TC-004-01:** Happy path de `createPortfolio` com campos mínimos válidos e Tenant/scope corretos.
- **TC-004-02:** Cada operação relevante (createPortfolio, updatePortfolio, archivePortfolio, associateProject, removeProject) verifica persistência e evento/audit esperado.
- **TC-004-03:** Campos inválidos e transições não permitidas retornam validação sem escrita parcial.
- **TC-004-04:** Tenant/scope errado, forged IDs e grant ausente são negados em API, RLS, jobs e exports.
- **TC-004-05:** Relações pai/filho cross-tenant falham; mesmos IDs em Tenant distinto não colidem.
- **TC-004-06:** `expected_version` stale retorna 409; retry/idempotency não duplica command/event.
- **TC-004-07:** Falha de consumer pós-commit não reverte fonte oficial e retry é seguro.
- **TC-004-08:** Projeção/AI/report recebe somente dados autorizados e não é fonte de escrita.
- **TC-004-09:** Archive preserva trilha; hard delete segue legal hold/retention workflow.

Gates: tenant isolation, authorization, invariants e data integrity bloqueiam release.

- **TC-004-10:** executar o fluxo positivo e uma tentativa de violar a invariante BR-004-02; confirmar resultado esperado, ausência de escrita parcial e registro de auditoria quando a mudança for sensível.
- **TC-004-11 (executado no DEV, rollback):** Tenant Admin cria Portfolio autorizado; grant `pmo_admin` fica no scope Portfolio, create+grant geram audit, replay não duplica e leitura filtra acesso exato.
- **TC-004-12 (executado no DEV, rollback):** editar com versão atual incrementa versão e registra audit; versão stale falha; archive depende de Projects inativos, preserva associação e remove Portfolio da lista ativa.
- **TC-004-13 (executado no DEV, rollback):** associar Projeto existente exige `portfolio.projects.associate` no Portfolio e `project.view` exato no Projeto; vínculo ativo e replay idempotente foram confirmados no smoke.
- **TC-004-14 (executado no DEV, rollback):** remover associação exige `portfolio.projects.remove`, versão atual, motivo e chave idempotente; replay não duplica audit, versão stale retorna conflito e relink cria associação nova preservando histórico e Projeto.

# SPEC-016 — Snapshots — Test Cases

**Status:** Draft — testes de domínio e integração propostos

- **TC-016-01:** publicação autorizada de Status cria snapshot-v1 com campos obrigatórios/hash correto na mesma transação.
- **TC-016-02:** get/list/compare/verify exigem grants e retornam somente campos permitidos; divergência de hash gera alerta auditado.
- **TC-016-03:** Campos inválidos e transições não permitidas retornam validação sem escrita parcial.
- **TC-016-04:** Tenant/scope errado, forged IDs e grant ausente são negados em API, RLS, jobs e exports.
- **TC-016-05:** Relações pai/filho cross-tenant falham; mesmos IDs em Tenant distinto não colidem.
- **TC-016-06:** retry de publish com mesma idempotency key não duplica snapshot; correção cria sucessor ligado ao anterior.
- **TC-016-07:** Falha de consumer pós-commit não reverte fonte oficial e retry é seguro.
- **TC-016-08:** Projeção/AI/report recebe somente dados autorizados e não é fonte de escrita.
- **TC-016-09:** Archive preserva trilha; hard delete segue legal hold/retention workflow.
- **TC-016-10:** Update/delete direto do snapshot é negado; serialização canônica estável e alteração de um byte invalida hash.

Gates: tenant isolation, authorization, invariants e data integrity bloqueiam release.

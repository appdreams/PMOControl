# SPEC-009 — Risks — Test Cases

**Status:** Draft — testes de domínio e integração propostos

- **TC-009-01:** Happy path de `createRisk` com campos mínimos válidos e Tenant/scope corretos.
- **TC-009-02:** Cada operação relevante (createRisk, assessRisk, updateResponse, materializeRisk, closeRisk) verifica persistência e evento/audit esperado.
- **TC-009-03:** Campos inválidos e transições não permitidas retornam validação sem escrita parcial.
- **TC-009-04:** Tenant/scope errado, forged IDs e grant ausente são negados em API, RLS, jobs e exports.
- **TC-009-05:** Relações pai/filho cross-tenant falham; mesmos IDs em Tenant distinto não colidem.
- **TC-009-06:** `expected_version` stale retorna 409; retry/idempotency não duplica command/event.
- **TC-009-07:** Falha de consumer pós-commit não reverte fonte oficial e retry é seguro.
- **TC-009-08:** Projeção/AI/report recebe somente dados autorizados e não é fonte de escrita.
- **TC-009-09:** Archive preserva trilha; hard delete segue legal hold/retention workflow.

Gates: tenant isolation, authorization, invariants e data integrity bloqueiam release.

- **TC-009-10:** executar o fluxo positivo e uma tentativa de violar a invariante BR-009-02; confirmar resultado esperado, ausência de escrita parcial e registro de auditoria quando a mudança for sensível.

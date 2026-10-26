# SPEC-021 — Resources — Test Cases

**Status:** Draft — testes de domínio e integração propostos

- **TC-021-01:** Happy path de `listCapacity` com campos mínimos válidos e Tenant/scope corretos.
- **TC-021-02:** Cada operação relevante (listCapacity, allocateResource, updateAllocation, resolveConflict, deallocateResource) verifica persistência e evento/audit esperado.
- **TC-021-03:** Campos inválidos e transições não permitidas retornam validação sem escrita parcial.
- **TC-021-04:** Tenant/scope errado, forged IDs e grant ausente são negados em API, RLS, jobs e exports.
- **TC-021-05:** Relações pai/filho cross-tenant falham; mesmos IDs em Tenant distinto não colidem.
- **TC-021-06:** `expected_version` stale retorna 409; retry/idempotency não duplica command/event.
- **TC-021-07:** Falha de consumer pós-commit não reverte fonte oficial e retry é seguro.
- **TC-021-08:** Projeção/AI/report recebe somente dados autorizados e não é fonte de escrita.
- **TC-021-09:** Archive preserva trilha; hard delete segue legal hold/retention workflow.

Gates: tenant isolation, authorization, invariants e data integrity bloqueiam release.

- **TC-021-10:** executar o fluxo positivo e uma tentativa de violar a invariante BR-021-02; confirmar resultado esperado, ausência de escrita parcial e registro de auditoria quando a mudança for sensível.

# SPEC-022 — Documents — Test Cases

**Status:** Draft — testes de domínio e integração propostos

- **TC-022-01:** Happy path de `uploadDocument` com campos mínimos válidos e Tenant/scope corretos.
- **TC-022-02:** Cada operação relevante (uploadDocument, getMetadata, downloadDocument, createVersion, linkEvidence, archiveDocument) verifica persistência e evento/audit esperado.
- **TC-022-03:** Campos inválidos e transições não permitidas retornam validação sem escrita parcial.
- **TC-022-04:** Tenant/scope errado, forged IDs e grant ausente são negados em API, RLS, jobs e exports.
- **TC-022-05:** Relações pai/filho cross-tenant falham; mesmos IDs em Tenant distinto não colidem.
- **TC-022-06:** `expected_version` stale retorna 409; retry/idempotency não duplica command/event.
- **TC-022-07:** Falha de consumer pós-commit não reverte fonte oficial e retry é seguro.
- **TC-022-08:** Projeção/AI/report recebe somente dados autorizados e não é fonte de escrita.
- **TC-022-09:** Archive preserva trilha; hard delete segue legal hold/retention workflow.

Gates: tenant isolation, authorization, invariants e data integrity bloqueiam release.

- **TC-022-10:** executar o fluxo positivo e uma tentativa de violar a invariante BR-022-02; confirmar resultado esperado, ausência de escrita parcial e registro de auditoria quando a mudança for sensível.

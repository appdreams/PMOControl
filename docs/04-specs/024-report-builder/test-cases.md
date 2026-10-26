# SPEC-024 — Report Builder — Test Cases

**Status:** Draft — testes de domínio e integração propostos

- **TC-024-01:** Happy path de `listTemplates` com campos mínimos válidos e Tenant/scope corretos.
- **TC-024-02:** Cada operação relevante (listTemplates, previewReport, createReportJob, getReportJob, downloadReport) verifica persistência e evento/audit esperado.
- **TC-024-03:** Campos inválidos e transições não permitidas retornam validação sem escrita parcial.
- **TC-024-04:** Tenant/scope errado, forged IDs e grant ausente são negados em API, RLS, jobs e exports.
- **TC-024-05:** Relações pai/filho cross-tenant falham; mesmos IDs em Tenant distinto não colidem.
- **TC-024-06:** `expected_version` stale retorna 409; retry/idempotency não duplica command/event.
- **TC-024-07:** Falha de consumer pós-commit não reverte fonte oficial e retry é seguro.
- **TC-024-08:** Projeção/AI/report recebe somente dados autorizados e não é fonte de escrita.
- **TC-024-09:** Archive preserva trilha; hard delete segue legal hold/retention workflow.

Gates: tenant isolation, authorization, invariants e data integrity bloqueiam release.

- **TC-024-10:** executar o fluxo positivo e uma tentativa de violar a invariante BR-024-02; confirmar resultado esperado, ausência de escrita parcial e registro de auditoria quando a mudança for sensível.

# SPEC-015 — RAG Engine — Test Cases

**Status:** Draft — testes de domínio e integração propostos

- **TC-015-01:** Happy path de `evaluateRag` com campos mínimos válidos e Tenant/scope corretos.
- **TC-015-02:** Cada operação relevante (evaluateRag, getRagHistory, overrideRag, revokeOverride) verifica persistência e evento/audit esperado.
- **TC-015-03:** Campos inválidos e transições não permitidas retornam validação sem escrita parcial.
- **TC-015-04:** Tenant/scope errado, forged IDs e grant ausente são negados em API, RLS, jobs e exports.
- **TC-015-05:** Relações pai/filho cross-tenant falham; mesmos IDs em Tenant distinto não colidem.
- **TC-015-06:** `expected_version` stale retorna 409; retry/idempotency não duplica command/event.
- **TC-015-07:** Falha de consumer pós-commit não reverte fonte oficial e retry é seguro.
- **TC-015-08:** Projeção/AI/report recebe somente dados autorizados e não é fonte de escrita.
- **TC-015-09:** Archive preserva trilha; hard delete segue legal hold/retention workflow.
- **TC-015-10:** cada indicador testa valor nos limites, imediatamente abaixo/acima e agregação pelo pior caso.
- **TC-015-11:** `incomplete`, denominador zero, mudança de rule version e repetição com mesma entrada/version produzem os resultados/hash definidos.

Gates: tenant isolation, authorization, invariants e data integrity bloqueiam release.

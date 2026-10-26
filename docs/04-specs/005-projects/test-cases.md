# SPEC-005 — Projects — Test Cases

**Status:** Draft — testes de domínio e integração propostos

- **TC-005-01:** Happy path de `createProject` com campos mínimos válidos e Tenant/scope corretos.
- **TC-005-02:** Cada operação relevante (createProject, updateProject, changeBaseline, assignMember, archiveProject) verifica persistência e evento/audit esperado.
- **TC-005-03:** Campos inválidos e transições não permitidas retornam validação sem escrita parcial.
- **TC-005-04:** Tenant/scope errado, forged IDs e grant ausente são negados em API, RLS, jobs e exports.
- **TC-005-05:** Relações pai/filho cross-tenant falham; mesmos IDs em Tenant distinto não colidem.
- **TC-005-06:** `expected_version` stale retorna 409; retry/idempotency não duplica command/event.
- **TC-005-07:** Falha de consumer pós-commit não reverte fonte oficial e retry é seguro.
- **TC-005-08:** Projeção/AI/report recebe somente dados autorizados e não é fonte de escrita.
- **TC-005-09:** Archive preserva trilha; hard delete segue legal hold/retention workflow.

Gates: tenant isolation, authorization, invariants e data integrity bloqueiam release.

- **TC-005-10:** executar o fluxo positivo e uma tentativa de violar a invariante BR-005-02; confirmar resultado esperado, ausência de escrita parcial e registro de auditoria quando a mudança for sensível.
- **TC-005-11:** Platform Root Admin obtém preview somente com metadados, confirma com motivo/código e inicia purge job; nenhuma escrita ocorre antes da confirmação.
- **TC-005-12:** Platform Admin comum, Tenant Admin e usuário sem grant falham em preview/confirm/status cross-tenant sem enumeração.
- **TC-005-13:** purge apaga registros operacionais elegíveis, preserva snapshots/publicações/audit/holds vigentes e cria tombstone mínimo; validar referências e contagens do resultado.
- **TC-005-14:** retry, concorrência, preview stale, retenção/hold e dependência externa são idempotentes/seguros e não executam cascade proibido.

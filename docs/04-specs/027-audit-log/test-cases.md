# SPEC-027 — Audit Log — Test Cases

**Status:** MVP regression coverage in DEV; query/export cases remain future scope

- **TC-027-01:** comando sensível com audit obrigatório gera evento redigido no mesmo commit/outbox.
- **TC-027-02:** Cada operação relevante (appendAuditEvent, queryAuditEvents, exportAuditEvidence) verifica persistência e evento/audit esperado.
- **TC-027-03:** schema inválido ou conteúdo proibido é rejeitado/redigido; falha de audit aborta comando de origem.
- **TC-027-04:** Tenant/scope errado, forged IDs e grant ausente são negados em API, RLS, jobs e exports.
- **TC-027-05:** Relações pai/filho cross-tenant falham; mesmos IDs em Tenant distinto não colidem.
- **TC-027-06:** replay da mesma event/deduplication key não duplica evento; idempotência preserva vínculo com comando de origem.
- **TC-027-07:** Falha de consumer pós-commit não reverte fonte oficial e retry é seguro.
- **TC-027-08:** Projeção/AI/report recebe somente dados autorizados e não é fonte de escrita.
- **TC-027-09:** export aplica audit.export, field policy, cursor limit e retention/legal hold.
- **TC-027-10:** app role não pode inserir, atualizar ou remover audit_events; tentativa é negada e evento anterior permanece inalterado.
- **TC-027-11:** reason/payload com chave ou valor com formato conhecido de credencial é recusado pelo constraint do banco; mutação de domínio e evento permanecem sem gravação parcial.

Gates: tenant isolation, authorization, invariants e data integrity bloqueiam release.

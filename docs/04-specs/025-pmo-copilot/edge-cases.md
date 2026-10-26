# SPEC-025 — PMO Copilot — Edge Cases

**Status:** Draft — casos domain-specific

1. Recurso ausente, arquivado ou em estado terminal ao executar `askCopilot`.
2. Tenant suspenso ou membership revogada entre leitura e commit.
3. Scope correto no objeto principal, mas relação vinculada fora do Tenant/scope.
4. Campo obrigatório inválido, enum desconhecido ou data invertida em `tenant_id, actor_id, question, authorized_scope, source_refs`.
5. Update concorrente usa versão stale.
6. Retry após timeout quando commit ocorreu, com idempotency duplicada.
7. Evento/outbox gravado, mas consumer indisponível; source permanece consistente.
8. Campo sensível incluído em list/export/AI grounding sem data policy.
9. Hard delete solicitado para registro com histórico ou referência.
10. Grande volume supera limite de paginação/tempo e requer job assíncrono.

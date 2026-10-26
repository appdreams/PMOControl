# SPEC-005 — Projects — Edge Cases

**Status:** Draft — casos domain-specific

1. Recurso ausente, arquivado ou em estado terminal ao executar `createProject`.
2. Tenant suspenso ou membership revogada entre leitura e commit.
3. Scope correto no objeto principal, mas relação vinculada fora do Tenant/scope.
4. Campo obrigatório inválido, enum desconhecido ou data invertida em `tenant_id, portfolio_id, name, code, sponsor_id`.
5. Update concorrente usa versão stale.
6. Retry após timeout quando commit ocorreu, com idempotency duplicada.
7. Evento/outbox gravado, mas consumer indisponível; source permanece consistente.
8. Campo sensível incluído em list/export/AI grounding sem data policy.
9. Hard delete solicitado para registro com histórico ou referência.
10. Grande volume supera limite de paginação/tempo e requer job assíncrono.
11. Purge de Project com legal hold/retention ativo preserva somente o escopo obrigatório e informa bloqueios sem remover o restante fora da autorização.
12. FK/artefato externo ao Project impede cascade inseguro; preservar registro e devolver referência/owner responsável.
13. Preview expira ou o Project muda após preview; exigir novo preview e confirmação.
14. Retry, execução concorrente ou falha entre lotes retoma pelo mesmo job sem duplicar audit, apagar histórico ou reativar o Project.
15. Platform Admin comum possui lifecycle de Tenant, mas não `platform.projects.purge`; acesso a conteúdo permanece negado.

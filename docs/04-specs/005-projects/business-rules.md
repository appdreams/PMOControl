# SPEC-005 — Projects — Business Rules

**Status:** Draft — regras de domínio iniciais

- **BR-005-01 — Ownership:** cada registro pertence ao Tenant/scope autorizado; relações inválidas são rejeitadas.
- **BR-005-02 — Invariant:** Baseline, Forecast e Actual são fatos distintos; Project define scope de autorização.
- **BR-005-03 — Lifecycle:** Project só transiciona por comandos autorizados entre estados declarados; update genérico não pode forjar estado.
- **BR-005-04 — Source of truth:** projeções, dashboards e AI consomem fonte oficial autorizada e não gravam cópia paralela.
- **BR-005-05 — Audit:** registrar actor, tenant, ação, resource, timestamp UTC, correlation ID e motivo em mutações sensíveis; remover secrets/PII desnecessária.
- **BR-005-06 — Concurrency:** update sensível usa versão esperada; conflito não perde alteração concorrente.
- **BR-005-07 — Retention:** usuários arquivam/fecham quando permitido; hard delete segue `docs/06-data/retention-archival.md`.

- **BR-005-08 — Platform purge:** exclusão definitiva é um comando privilegiado distinto de archive, somente Platform Root Admin com `platform.projects.purge`; Platform Admin comum, Tenant Admin e usuários do Tenant não recebem esse grant implicitamente.
- **BR-005-09 — Confirmation and audit:** antes do comando, gerar prévia com identidade do Project, contagens por categoria e itens impedidos/retidos; exigir confirmação inequívoca vinculada ao Project, motivo e `Idempotency-Key`. Auditar solicitação, confirmação, execução, exceções e conclusão, sem copiar conteúdo apagado para audit.
- **BR-005-10 — History and retention:** purge é retomável e idempotente. Apagar somente dados operacionais cujo prazo/hold permita purge; preservar publicações, snapshots, eventos de auditoria e quaisquer registros sob retenção/hold em armazenamento histórico sem uso operacional. Manter tombstone mínimo para referências históricas. Hold aplicável nunca é contornado; itens retidos ficam identificados no resultado e seguem o workflow central de retenção.
- **BR-005-11 — No platform content access:** o console do Platform Root Admin revela apenas metadados mínimos de identificação e estado/impacto do purge; não expõe documentos, finanças, riscos, narrativas ou outros conteúdos do Tenant.

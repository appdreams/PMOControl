# SPEC-016 — Snapshots — Business Rules

**Status:** Draft — contrato snapshot-v1 definido; revisão de retenção/transversal pendente

- **BR-016-01 — Ownership:** cada registro pertence ao Tenant/scope autorizado; relações inválidas são rejeitadas.
- **BR-016-02 — Invariant:** Snapshot publicado é imutável; criação ocorre junto à publicação autoritativa e payload versionado.
- **BR-016-03 — Lifecycle:** Snapshot não possui estado mutável; é criado apenas no publish/correct Status e é imutável depois do commit.
- **BR-016-04 — Source of truth:** projeções, dashboards e AI consomem fonte oficial autorizada e não gravam cópia paralela.
- **BR-016-05 — Audit:** registrar actor, tenant, ação, resource, timestamp UTC, correlation ID e motivo em mutações sensíveis; remover secrets/PII desnecessária.
- **BR-016-06 — Integrity:** hash SHA-256 de envelope JSON canônico RFC 8785 deve validar; divergência retorna `invalid`, gera alerta auditado e nunca repara/regrava silenciosamente o snapshot.
- **BR-016-07 — Retention:** usuários arquivam/fecham quando permitido; hard delete segue `docs/06-data/retention-archival.md`.
- **BR-016-08 — Successor:** correção de status cria snapshot sucessor com `supersedes_snapshot_id`; snapshot anterior permanece consultável e intacto conforme data policy.

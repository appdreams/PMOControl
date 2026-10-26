# SPEC-027 — Audit Log — Business Rules

**Status:** Draft — append-only, atomic write and redaction defined

- **BR-027-01 — Atomic write:** quando audit é requisito do domínio, evento e comando de origem commitam juntos; falha de audit aborta o comando.
- **BR-027-02 — Append-only invariant:** app role não insere, atualiza nem remove evento diretamente; escrita é interna ao domínio/outbox. Evento committed é imutável; correção é novo evento referenciado.
- **BR-027-03 — Envelope:** contém event_id, tenant_id, actor_id/system_actor, action, resource_type/id, occurred_at UTC, correlation_id e schema_version.
- **BR-027-04 — Redaction:** before/after só incluem campos allowlisted/redigidos; passwords, tokens, secrets, prompt/output de IA e payload binário nunca entram.
- **BR-027-05 — Query/export:** exige audit.view/export no scope e data policy; não revela existência ou campos de recursos fora do escopo.
- **BR-027-06 — Retention:** categoria padrão 12 meses; legal hold prevalece apenas no escopo coberto; purge separado, idempotente e auditado.

# SPEC-027 — Audit Log — Permissions

**Status:** Draft — acesso read/export por scope; matriz final na Spec 003

- `audit.view`: consulta eventos do Tenant e recursos permitidos.
- `audit.export`: exportação explícita, filtrada por scope/data policy e auditada.
- Não existe `audit.update` ou `audit.delete` para usuários comuns.
- Escrita de audit é interna ao serviço de domínio/outbox e não é conferida a um papel cliente como CRUD.
- Support/Platform Admin não recebe leitura automática de conteúdo de negócio; suporte segue `docs/07-security/admin-support-access.md`.

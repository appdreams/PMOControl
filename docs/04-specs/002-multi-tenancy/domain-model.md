# SPEC-002 — Multi-Tenancy — Domain Model

**Status:** Draft — decisões MVP incorporadas; schema detalhado pendente

## Entidades

- `Tenant`: `id`, `slug` gerado pelo sistema a partir de `display_name`, `status (active|suspended|termination_pending|export_ready|purging|terminated)`, timestamps e versão.
- `Membership`: `tenant_id`, `user_id`, status, grants/role references, invited/activated/revoked timestamps.
- `Invitation`: tenant, e-mail alvo, grants propostos, token hash, expiry de 7 dias, uso/revogação.
- `TenantExport`: tenant, contato autorizado, escopo/version, estado, artefato protegido/checksum, disponível/notificado/baixado e retenção do artefato.
- `ExportDispute` (`tenant_export_disputes`): export, tenant, autor, motivo, escopo contestado, estado, resolução, timestamps e audit event; contestação válida pausa purge somente no escopo afetado.
- `TenantAdminTransfer`: comando/workflow não mutável; resultado persiste como alteração de Membership/AccessGrant mais audit event, sem tabela operacional independente.
- `TenantContext`: valor resolvido no servidor a partir de sessão e membership ativa; não é entidade persistida confiável do cliente.

## Ownership e integridade

Tenant 1—N Membership, Invitation, Portfolio, Project, TenantExport e dados tenant-owned. Memberships permitem um usuário participar de vários tenants. Chaves e relações entre recursos precisam incluir/validar `tenant_id`; referências globais devem ser explicitamente classificadas.

## Lifecycle

Somente equipe da plataforma cria/ativa/suspende/inicia encerramento. Tenant ativo aceita operações de negócio. Suspenso bloqueia novas mutações, integrações e jobs, preservando dados para reativação/export. Encerramento exige bloqueio, geração e entrega/validação da exportação, janela de 90 dias após export pronta e purge/anonymization ao fim, salvo legal hold/obrigação. Estados são versionados e transições auditadas.

Membership pode existir em múltiplos tenants; seleção ocorre após login e cada requisição revalida membership/status. Convites são de uso único, expiram em 7 dias e podem ser revogados.

Transferência do administrador primário exige solicitação de administrador atual e confirmação do novo administrador verificado. Recuperação sem administrador ativo segue suporte JIT com ticket, aprovação independente, escopo mínimo, expiração e auditoria. Contestações de export podem ser abertas em até 30 dias da notificação; ausência de contestação não estende o purge padrão de 90 dias.

## Quotas

Sem limite fixo hardcoded no MVP. Plataforma configura quotas por plano; ausência de quota explícita significa sem limite específico de produto, sujeita a controles de abuso/capacidade.

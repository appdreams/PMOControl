# SPEC-001 — Authentication — Acceptance Criteria

**Status:** MVP criteria implemented for DEV; release-specific production settings excluded

## AC-001-01 — login MVP

**Given** conta ativa e credencial válida de e-mail/senha
**When** o usuário autentica
**Then** Supabase Auth cria sessão segura
**And** a aplicação resolve memberships ativas sem conceder acesso apenas por login.

## AC-001-02 — credencial inválida / enumeração

**Given** e-mail inexistente ou senha inválida
**When** tenta login ou recuperação
**Then** a resposta de recuperação não revela se a conta existe
**And** tokens/credenciais não aparecem em logs.

## AC-001-03 — MFA/SSO fora do MVP

**Given** configuração do MVP
**When** usuário acessa login
**Then** o fluxo oferecido é e-mail/senha e recovery
**And** MFA e SSO Google/Microsoft não são exigidos nem oferecidos como escopo MVP.

## AC-001-04 — escolha de tenant

**Given** usuário tem memberships ativas em mais de um tenant
**When** conclui login
**Then** escolhe o tenant para a sessão
**And** servidor valida membership antes de estabelecer o contexto.

## AC-001-05 — membership revogada

**Given** membership foi suspensa/revogada depois do login
**When** usuário faz próxima operação ou tenta selecionar tenant
**Then** servidor nega acesso sem depender de logout manual.

## AC-001-06 — recovery

**Given** pedido de recuperação para qualquer e-mail
**When** solicitação é submetida
**Then** resposta pública é indistinguível para conta existente/inexistente
**And** token é de uso único e expira conforme provider.

## AC-001-07 — sessão e cookie SSR

**Given** uma sessão iniciada pelo fluxo web MVP
**When** tokens são emitidos, renovados ou encerrados
**Then** JWT tem validade de 3.600 segundos, refresh rotation fica ativa e cookie SSR é host-only, `Path=/`, `SameSite=Lax`, `Secure` em HTTPS, sem expiração curta customizada
**And** logout padrão revoga somente a sessão atual e respostas de refresh não são compartilhadas por cache.

## AC-001-08 — proteção CSRF e limite do provider

**Given** mutação browser autenticada por cookie
**When** Origin está ausente ou não corresponde à origem/Host esperado
**Then** o servidor rejeita antes da mutação
**And** no plano DEV Free a aplicação não declara timeout absoluto/inatividade sem implementação própria; essa proteção é gate de produção.

## AC-001-09 — nome de exibição do perfil

**Given** uma identidade Auth sem nome nos metadados
**When** um perfil é criado ou carregado
**Then** existe um rótulo temporário não vazio e o perfil é marcado incompleto
**And** o usuário informa seu próprio nome no workspace, que passa a aparecer nas listas de membros e gerentes
**And** a API só permite ao ator atualizar o próprio perfil.

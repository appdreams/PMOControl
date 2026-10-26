# SPEC-001 — Authentication — Acceptance Criteria

**Status:** Draft — requisitos MVP alinhados; provider/security review pendente

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

# SPEC-002 — Multi-Tenancy — Acceptance Criteria

**Status:** Draft — decisões MVP alinhadas; fluxo de export/purge operacional pendente

## AC-002-01 — provisionamento controlado

**Given** operador da equipe da plataforma com permission de provisionamento  
**When** cria tenant  
**Then** tenant e primeiro administrador são provisionados consistentemente e a ação é auditada.

## AC-002-02 — cliente não provisiona tenant

**Given** usuário cliente ou Tenant Admin sem permission de plataforma  
**When** tenta criar, suspender ou encerrar Tenant  
**Then** servidor nega sem alterar estado.

## AC-002-03 — memberships múltiplas

**Given** usuário tem memberships ativas em múltiplos tenants  
**When** autentica  
**Then** escolhe um tenant disponível  
**And** cada requisição subsequente valida essa membership no servidor.

## AC-002-04 — convite expirável e single-use

**Given** convite emitido por administrador permitido  
**When** aceito antes de 7 dias e não usado/revogado  
**Then** ativa apenas identidade/e-mail alvo e grants contidos no convite  
**And** uso repetido, expirado ou revogado é recusado.

## AC-002-05 — isolamento cross-tenant

**Given** recurso pertence a Tenant A  
**When** ator de Tenant B tenta acessar por ID, filtro, relação, storage ou export  
**Then** a operação é negada e não revela existência do recurso.

## AC-002-06 — suspensão

**Given** tenant suspenso  
**When** usuário, integração ou job tenta mutação  
**Then** operação é bloqueada sem apagar histórico.

## AC-002-07 — encerramento export-first

**Given** tenant autorizado para encerramento  
**When** exportação ainda não está pronta/entregue  
**Then** janela de purge não começa  
**And** após export pronta inicia 90 dias, salvo hold/obrigação que bloqueie purge.

## AC-002-08 — quotas

**Given** sem quota configurada para plano  
**When** tenant é usado dentro de controles de abuso/capacidade  
**Then** não se aplica limite arbitrário de produto; quotas explicitamente configuradas são aplicadas e auditáveis.

## AC-002-09 — transferência de administração

**Given** administrador atual autenticado e novo administrador com identidade verificada  
**When** a transferência é confirmada com a versão atual do Tenant  
**Then** o novo grant é criado no mesmo Tenant, a ação é auditada e o administrador anterior só perde acesso se essa revogação for solicitada e autorizada.

## AC-002-10 — contestação de export

**Given** contato de export autorizado recebe notificação de disponibilidade  
**When** protocola contestação fundamentada em até 30 dias  
**Then** purge pausa apenas para o escopo contestado até resolução auditada, sem reiniciar ou apagar o prazo dos dados não contestados.

# SPEC-002 — Multi-Tenancy — Acceptance Criteria

**Status:** MVP lifecycle and export/retention criteria implemented in DEV; production infrastructure retention excluded

## AC-002-01 — provisionamento controlado

**Given** operador da equipe da plataforma com permission de provisionamento
**When** cria tenant informando o nome da organização
**Then** o sistema gera o identificador conforme a regra de normalização, sem campo editável no formulário
**And** tenant, sete presets e auditoria são provisionados consistentemente; o primeiro administrador só recebe membership após aceite de convite autorizado e auditado.
**And** slug já existente retorna conflito sem criar estado parcial.

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

### Primeiro administrador do Tenant

**Given** Tenant ativo sem administrador ativado
**When** o operador criador, autorizado por `tenant.lifecycle.create` e sem deny, gera o convite
**Then** o link de uso único concede somente `tenant_admin` e expira em sete dias
**And** a reemissão revoga o link pendente anterior
**When** uma sessão Auth com e-mail confirmado correspondente aceita o link
**Then** membership, grant, consumo do convite e audit são gravados atomicamente
**And** e-mail incompatível, link expirado/revogado ou replay não concede acesso.

### Convite comum de membro Tenant

**Given** administrador com membership ativa e `membership.invite` exato
**When** convida um e-mail para um papel de sistema Tenant
**Then** o banco valida que cada permission do papel está no ceiling do emissor e sem deny
**And** token bruto não é persistido, o link expira em sete dias e o reenvio revoga o anterior para o mesmo endereço
**When** a pessoa aceita com e-mail Auth confirmado correspondente
**Then** emissor e delegation ceiling são revalidados e convite, membership, grant e audit são atualizados atomicamente
**And** tentativa fora do ceiling, com conta/e-mail divergente, convite expirado/revogado/reutilizado ou membership suspensa não concede acesso.

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

## AC-002-11 — transições de lifecycle

**Given** Tenant ou Membership em estado atual e versão conhecidos
**When** ator autorizado solicita uma transição listada na SPEC-002
**Then** a transição e seu AuditEvent são commitados atomicamente com lock/controle de versão
**And** estado terminal, transição inválida, replay ou versão obsoleta falham sem escrita parcial.

## AC-002-12 — revogação concorrente

**Given** uma operação protegida concorre com suspensão/revogação de membership
**When** ambas tentam commit
**Then** as operações são serializadas e nenhuma operação iniciada depois da revogação usa a autorização antiga.

## AC-002-13 — identificador automático

**Given** operador autorizado informa um nome válido para a organização
**When** o formulário é enviado
**Then** o servidor gera um slug estável em minúsculas, sem diacríticos, separado por hífens e com até 63 caracteres
**And** valores de slug fornecidos diretamente pelo cliente são rejeitados
**And** nome que não gere ao menos três caracteres ASCII alfanuméricos é rejeitado.

## AC-002-14 — revogação administrativa de membership

**Given** administrador com membership ativa, permission `membership.revoke` no Tenant exato e membro ativo/suspenso diferente de si
**When** solicita revogação com motivo e versão atual
**Then** membership passa para `revoked`, todos os grants desse usuário no Tenant são revogados e um evento de audit é gravado atomicamente
**And** versão obsoleta, transição repetida, actor sem permission ou deny explícito não altera estado
**And** o sistema preserva pelo menos um Tenant Admin ativo e impede auto-revogação pela interface/API.

## AC-002-15 — suspensão e reativação administrativa de membership

**Given** administrador com `membership.manage` no Tenant exato e membership ativa/suspensa de outra pessoa
**When** solicita suspensão ou reativação com motivo e versão atual
**Then** o estado e o AuditEvent são commitados atomicamente, com incremento de versão
**And** suspensão mantém os grants existentes, bloqueia acesso pela membership suspensa e não permite suspender o último Tenant Admin ativo
**And** ator sem permission, deny explícito, auto-transição, versão obsoleta ou membership revogada não altera o estado.

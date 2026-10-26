# SPEC-026 — Notifications — Acceptance Criteria

**Status:** Draft — critérios domain-specific; thresholds de contrato pendentes

## AC-026-01 — consulta autorizada

**Given** ator com membership ativa, scope `Recipient/Tenant` e permission de view  
**When** consulta Notification  
**Then** recebe somente registros e campos autorizados do Tenant.

## AC-026-02 — operação principal

**Given** Notification válido e ator com grant necessário  
**When** executa `listInbox` com payload válido  
**Then** domínio persiste a transição permitida e registra actor/version/audit.

## AC-026-03 — regra central

**Given** dados que satisfazem regras do domínio  
**When** fluxo é concluído  
**Then** Notificação é pós-commit, minimizada e idempotente; falha nunca altera estado oficial.

## AC-026-04 — negação e isolamento

**Given** scope/Tenant incorreto, membership revogada ou grant ausente  
**When** ator usa ID direto ou payload forjado  
**Then** servidor nega sem alterar dados nem revelar existência cross-tenant.

## AC-026-05 — versão concorrente

**Given** registro mudou desde `expected_version`  
**When** update obsoleto é enviado  
**Then** retorna conflict e mantém ambas as versões sem perda silenciosa.


## AC-026-06 — invariante de domínio

**Given** ator autorizado e dados válidos no scope do módulo  
**When** executa o comando de domínio aplicável  
**Then** Notificação é pós-commit, minimizada e idempotente; falha nunca altera estado oficial.

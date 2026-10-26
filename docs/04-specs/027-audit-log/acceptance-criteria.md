# SPEC-027 — Audit Log — Acceptance Criteria

**Status:** Draft — critérios domain-specific; thresholds de contrato pendentes

## AC-027-01 — consulta autorizada

**Given** ator com membership ativa, scope `Tenant + audit permission` e permission de view  
**When** consulta AuditEvent  
**Then** recebe somente registros e campos autorizados do Tenant.

## AC-027-02 — operação principal

**Given** um comando de domínio que exige AuditEvent  
**When** o comando commit  
**Then** event writer deriva ator/Tenant e grava evento redigido na mesma transação/outbox.

## AC-027-03 — regra central

**Given** dados que satisfazem regras do domínio  
**When** fluxo é concluído  
**Then** Eventos append-only para usuários comuns; payload minimizado, sem secrets, com integridade e acesso restrito.

## AC-027-04 — negação e isolamento

**Given** scope/Tenant incorreto, membership revogada ou grant ausente  
**When** ator usa ID direto ou payload forjado  
**Then** servidor nega sem alterar dados nem revelar existência cross-tenant.

## AC-027-05 — exportação escopada

**Given** ator com `audit.export` no escopo e data policy válidos  
**When** exporta intervalo filtrado  
**Then** recebe somente eventos/campos autorizados, paginados e redigidos.

## AC-027-06 — trilha imutável e sem segredo

**Given** evento auditado committed  
**When** usuário/API tenta inserir, alterar ou apagar evento, ou evento de origem contém secret  
**Then** mutação é negada e secret é removido antes da persistência; correção permitida somente como evento sucessor.

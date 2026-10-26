# SPEC-016 — Snapshots — Acceptance Criteria

**Status:** Draft — critérios alinhados ao contrato `snapshot-v1`

## AC-016-01 — consulta autorizada

**Given** ator com membership ativa, scope `Project/Snapshot` e permission de view  
**When** consulta Snapshot  
**Then** recebe somente registros e campos autorizados do Tenant.

## AC-016-02 — operação principal

**Given** Snapshot válido e ator com grant necessário  
**When** um comando autorizado de publicação/correção cria o snapshot interno  
**Then** domínio persiste a transição permitida e registra actor/version/audit.

## AC-016-03 — regra central

**Given** dados que satisfazem regras do domínio  
**When** fluxo é concluído  
**Then** Snapshot publicado é imutável; criação ocorre junto à publicação autoritativa e payload versionado.

## AC-016-04 — negação e isolamento

**Given** scope/Tenant incorreto, membership revogada ou grant ausente  
**When** ator usa ID direto ou payload forjado  
**Then** servidor nega sem alterar dados nem revelar existência cross-tenant.

## AC-016-05 — versão concorrente

**Given** registro mudou desde `expected_version`  
**When** update obsoleto é enviado  
**Then** retorna conflict e mantém ambas as versões sem perda silenciosa.

## AC-016-06 — publicação atômica e integridade

**Given** publicação de Status autorizada  
**When** Spec 014 confirma commit  
**Then** existe exatamente um Snapshot `snapshot-v1` com hash verificável; falha antes do commit deixa zero Publication/Snapshot, e qualquer tentativa de update/delete é negada.

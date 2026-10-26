# SPEC-005 — Projects — Acceptance Criteria

**Status:** Draft — critérios domain-specific; thresholds de contrato pendentes

## AC-005-01 — consulta autorizada

**Given** ator com membership ativa, scope `Tenant/Portfolio/Project` e permission de view  
**When** consulta Project  
**Then** recebe somente registros e campos autorizados do Tenant.

## AC-005-02 — operação principal

**Given** Project válido e ator com grant necessário  
**When** executa `createProject` com payload válido  
**Then** domínio persiste a transição permitida e registra actor/version/audit.

## AC-005-03 — regra central

**Given** dados que satisfazem regras do domínio  
**When** fluxo é concluído  
**Then** Baseline, Forecast e Actual são fatos distintos; Project define scope de autorização.

## AC-005-04 — negação e isolamento

**Given** scope/Tenant incorreto, membership revogada ou grant ausente  
**When** ator usa ID direto ou payload forjado  
**Then** servidor nega sem alterar dados nem revelar existência cross-tenant.

## AC-005-05 — versão concorrente

**Given** registro mudou desde `expected_version`  
**When** update obsoleto é enviado  
**Then** retorna conflict e mantém ambas as versões sem perda silenciosa.


## AC-005-06 — invariante de domínio

**Given** ator autorizado e dados válidos no scope do módulo  
**When** executa o comando de domínio aplicável  
**Then** Baseline, Forecast e Actual são fatos distintos; Project define scope de autorização.

## AC-005-07 — purge restrito e confirmado

**Given** Platform Root Admin com `platform.projects.purge`, preview atual e Project sem bloqueio de autorização
**When** informa motivo, confirma o código do Project e envia `Idempotency-Key`
**Then** servidor cria purge job, desativa o Project para novas operações e retorna somente status/metadados mínimos, sem revelar conteúdo do Tenant.

## AC-005-08 — retenção e histórico preservados

**Given** Project possui publicações, snapshots, audit, legal hold ou outras retenções vigentes
**When** purge é executado
**Then** dados operacionais elegíveis são apagados; histórico/hold obrigatório permanece isolado e imutável, um tombstone mínimo mantém referências e o resultado discrimina itens apagados, retidos e bloqueados.

## AC-005-09 — ausência de privilégio

**Given** Platform Admin sem grant root, Tenant Admin ou usuário comum
**When** tenta pré-visualizar, confirmar ou consultar purge cross-tenant
**Then** recebe negação sem enumeração nem alteração de dados.

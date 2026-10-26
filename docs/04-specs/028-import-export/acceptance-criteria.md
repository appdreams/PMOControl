# SPEC-028 — Import & Export — Acceptance Criteria

**Status:** Draft — critérios domain-specific; thresholds de contrato pendentes

## AC-028-01 — consulta autorizada

**Given** ator com membership ativa, scope `Tenant + authorized entities/fields` e permission de view  
**When** consulta DataJob  
**Then** recebe somente registros e campos autorizados do Tenant.

## AC-028-02 — operação principal

**Given** DataJob válido e ator com grant necessário  
**When** executa `createImportJob` com payload válido  
**Then** domínio persiste a transição permitida e registra actor/version/audit.

## AC-028-03 — regra central

**Given** dados que satisfazem regras do domínio  
**When** fluxo é concluído  
**Then** importação genérica segue staging→validate→preview→confirm→apply, project XLSX v1 respeita AC-028-09–12, e export revalida permissão/data policy por campo e linha.

## AC-028-04 — negação e isolamento

**Given** scope/Tenant incorreto, membership revogada ou grant ausente  
**When** ator usa ID direto ou payload forjado  
**Then** servidor nega sem alterar dados nem revelar existência cross-tenant.

## AC-028-05 — versão concorrente

**Given** registro mudou desde `expected_version`  
**When** update obsoleto é enviado  
**Then** retorna conflict e mantém ambas as versões sem perda silenciosa.


## AC-028-06 — invariante de domínio

**Given** ator autorizado e dados válidos no scope do módulo  
**When** executa o comando de domínio aplicável  
**Then** importação genérica segue staging→validate→preview→confirm→apply, project XLSX v1 respeita AC-028-09–12, e export revalida permissão/data policy por campo e linha.

## AC-028-07 — seleção de projeto tenant-scoped

**Given** usuário com membership ativa e `project.data.import`  
**When** abre o seletor de projeto  
**Then** só vê projetos ativos do Tenant e escopo autorizados; IDs/tentativas de upload de outro Tenant são negados sem revelar existência.

## AC-028-08 — modelos Excel oficiais

**Given** usuário autorizado e projeto selecionado  
**When** baixa o modelo vazio e o exemplo  
**Then** ambos são `.xlsx`, mesma versão/abas/colunas exatas; o vazio identifica o alvo e não tem dados de negócio, enquanto o exemplo é coerente, completo no escopo v1 e sintético.

## AC-028-09 — carga inicial sem prompt de modo

**Given** projeto sem registros operacionais ativos no escopo v1  
**When** o arquivo passa validação e preview  
**Then** o sistema não pergunta adicionar/reiniciar e aplica a carga inicial; arquivo inválido não escreve nenhuma entidade.

## AC-028-10 — adicionar dados sem sobrescrever

**Given** projeto com registros existentes e workbook válido  
**When** usuário escolhe “Adicionar dados” e confirma  
**Then** somente novas external keys são inseridas; duplicadas geram conflito antes do commit e nenhuma entidade preexistente é alterada.

## AC-028-11 — reinício de dados controlado

**Given** projeto com dados ativos e usuário com `project.data.import.replace`  
**When** escolhe “Reiniciar dados do projeto”, vê contagens, informa motivo e confirma token vinculado ao projeto  
**Then** entidades v1 ativas são arquivadas e o novo dataset é inserido atomicamente; audit, publicações, snapshots, holds e histórico permanecem imutáveis.

## AC-028-12 — atomicidade e restrição ao alvo

**Given** workbook com ao menos um erro bloqueante, conflito de versão, relação externa insegura ou falha durante apply  
**When** valida/adiciona/reinicia  
**Then** nenhuma escrita parcial ocorre, nenhum outro Project é alterado e o relatório aponta aba/linha/campo e correção possível.

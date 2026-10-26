# SPEC-028 — Import & Export — Test Cases

**Status:** Draft — testes de domínio e integração propostos

- **TC-028-01:** Happy path de `createImportJob` com campos mínimos válidos e Tenant/scope corretos.
- **TC-028-02:** Cada operação relevante (createImportJob, mapColumns, validateImport, previewImport, confirmImport, createExportJob, downloadExport) verifica persistência e evento/audit esperado.
- **TC-028-03:** Campos inválidos e transições não permitidas retornam validação sem escrita parcial.
- **TC-028-04:** Tenant/scope errado, forged IDs e grant ausente são negados em API, RLS, jobs e exports.
- **TC-028-05:** Relações pai/filho cross-tenant falham; mesmos IDs em Tenant distinto não colidem.
- **TC-028-06:** `expected_version` stale retorna 409; retry/idempotency não duplica command/event.
- **TC-028-07:** Falha de consumer pós-commit não reverte fonte oficial e retry é seguro.
- **TC-028-08:** Projeção/AI/report recebe somente dados autorizados e não é fonte de escrita.
- **TC-028-09:** Archive preserva trilha; hard delete segue legal hold/retention workflow.

Gates: tenant isolation, authorization, invariants e data integrity bloqueiam release.

- **TC-028-10:** executar o fluxo positivo e uma tentativa de violar a invariante BR-028-02; confirmar resultado esperado, ausência de escrita parcial e registro de auditoria quando a mudança for sensível.
- **TC-028-11:** listar projetos de dois Tenants e usuário com escopo parcial; seletor inclui somente projetos ativos autorizados do Tenant atual.
- **TC-028-12:** forjar `targetProjectId`/project code cross-tenant no request e no workbook; negar antes de staging/apply e sem revelar o recurso externo.
- **TC-028-13:** baixar ambos workbooks e comparar template version, sheets, headers, enums e target guard; exemplo contém somente dados sintéticos consistentes para todos os tipos suportados v1.
- **TC-028-14:** rejeitar `.xls`, `.xlsm`, versão velha/desconhecida, fórmula, macro, link externo, aba oculta/adicional, coluna extra, cabeçalho alterado e project_code divergente.
- **TC-028-15:** validar dates/enums/células obrigatórias, chaves duplicadas, owner sem membership, vínculo externo/cross-project e limite de arquivo/linhas; erros apontam aba/célula e não escrevem fonte.
- **TC-028-16:** projeto com zero registros ativos importáveis recebe carga válida sem modal de modo; falha de validação não aplica.
- **TC-028-17:** modo adicionar insere novas external keys, não altera entidades antigas e atualiza relações conforme preview; contagem final coincide com planilha.
- **TC-028-18:** modo adicionar com chave repetida no arquivo ou no projeto retorna conflito e não sobrescreve nem cria duplicata.
- **TC-028-19:** reinício sem `project.data.import.replace`, sem reason, token incorreto, versão stale ou `target_scope_checksum` divergente é negado antes de qualquer arquivo/fonte ser substituído.
- **TC-028-20:** reinício autorizado arquiva apenas as entidades operacionais dos sheets v1 no Project alvo e insere novo dataset; audit, snapshots, publicações, legal hold e entidades fora do escopo continuam íntegros.
- **TC-028-21:** simular falha transacional entre arquivamento e inserção; rollback mantém conjunto antigo ativo e nenhum conjunto novo parcialmente ativo.
- **TC-028-22:** dependência de/in para outro Project ou registro imutável que impeça arquivamento bloqueia reset e identifica registros afetados, sem apagar/alterar o Project relacionado.

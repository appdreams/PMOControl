# SPEC-028 — Import & Export — UI

**Status:** Draft — estados e conteúdo de tela definidos

## Conteúdo e ações

Exibir `DataJob` dentro do scope `Tenant + authorized entities/fields`, campos prioritários `tenant_id, actor_id, direction, entity_type, source_file_key, mapping_version`, origem/status e timestamps relevantes. Ações conforme grant: createImportJob, mapColumns, validateImport, previewImport, confirmImport, createExportJob, downloadExport. Exibir Current vs Published quando a fonte for snapshot.

### Importar dados de um projeto

O formulário primeiro carrega um seletor de projetos já cadastrados e ativos, filtrado pelo Tenant ativo verificado no servidor e pelo escopo/grant do usuário. O usuário não informa Tenant por texto nem escolhe projeto fora dessa lista. Após selecionar o projeto, oferecer dois downloads: modelo `.xlsx` vazio e exemplo completo preenchido com dados sintéticos; ambos seguem `project-import-template-v1.md` e têm a mesma versão de abas/colunas.

O usuário anexa `.xlsx`; o sistema verifica versão/cabeçalhos/abas, tamanho, macros/fórmulas/links, relações e permissões, então exibe preview com erros por aba/célula, contagens e áreas preservadas fora do escopo v1. Com escopo operacional v1 vazio, não mostrar escolha de modo; após preview limpo, a tela chama `apply-initial` sem prompt de modo. Com dados ativos, mostrar resumo e as escolhas “Adicionar dados” e “Reiniciar dados do projeto” antes de aplicar. Adicionar somente cria registros e rejeita chaves duplicadas. Reiniciar mostra contagens afetadas, declara quais áreas serão preservadas, exige `project.data.import.replace`, motivo e confirmação digitada claramente vinculada ao projeto; mantém histórico imutável conforme a política.

O resultado informa linhas criadas/arquivadas/rejeitadas, versão do template, projeto e audit reference. Se houver erro, nenhuma linha é aplicada; indicar ação corrigível e permitir novo upload. Detalhes do escopo do workbook e de preservação histórica estão no contrato v1.

## Estados

Loading skeleton; empty state com ação permitida; validation errors junto ao campo; forbidden sem revelar recurso; conflict com opção recarregar; erro recuperável com retry; sucesso confirmado após commit. Campos sensíveis mascarados/ocultos pela data policy, não apenas CSS.

## Acessibilidade

Ações por teclado, foco visível, labels associados, mensagens anunciadas e status não comunicado somente por cor. Referência visual é não normativa; permissão/regra segue esta Spec e Security docs.

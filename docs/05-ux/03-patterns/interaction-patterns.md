# Interaction Patterns

**Status:** Draft — Box Focus interaction added; implementation and accessibility verification pending

## CRUD

List → Filter/Search → Detail → Authorized Action → Validation →
Feedback → Refresh projection.

## Work by Exception

Itens críticos, atrasados, ameaçados e pendentes aparecem antes de itens
saudáveis.

## Confirmation

Ações consequenciais usam confirmação explícita: Publish Status, RAG
Override, baseline changes, approvals, destructive/archive operations e
AI proposed writes.

## Feedback

-   success: confirmação curta;
-   validation: próxima ao campo;
-   permission denied: sem revelar dado protegido;
-   async: queued/running/completed/failed;
-   optimistic UI somente quando rollback é seguro.

## Current vs Published

Sempre rotular quando ambas as visões puderem ser confundidas.

## Tables

Filtros, sorting, paginação, estados vazios e drill-down. Export somente
quando autorizado.

## AI

Fact, Inference e Recommendation devem ser distinguíveis.

## Box Focus (spotlight)

Todos os cards/boxes titulados com semântica `data-focus-box` participam do comportamento global. Duplo clique no título ativa o Box Focus: o restante da tela visível fica em escala de cinza e somente o box ativo mantém as cores originais. Duplo clique no mesmo título encerra; duplo clique em outro título transfere o foco para aquele box. A função é somente visual, não altera dados, permissões ou navegação, vale para a tela atual e encerra ao navegar/recarregar.

A ação também deve estar disponível por controle explícito acessível no título (botão “Destacar [nome do box]”, com estado pressionado) e por teclado. `Escape` encerra o foco. Manter indicadores de foco/seleção compreensíveis sem cor, preservar contraste e respeitar forced-colors/reduced-motion. Overlay, navegação e conteúdo fora do box seguem em escala de cinza; portais associados ao box selecionado mantêm as cores apenas quando semanticamente pertencem a ele.

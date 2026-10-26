# Accessibility

**Status:** Draft — requisito Box Focus adicionado; verificação de acessibilidade pendente

## Meta

WCAG 2.2 AA como referência.

## Requisitos

-   navegação por teclado;
-   foco visível;
-   labels associados;
-   contraste adequado;
-   cor não é único indicador;
-   icon-only controls possuem accessible name;
-   erros identificam campo e correção;
-   modais gerenciam foco;
-   tabelas possuem headers;
-   gráficos possuem resumo textual;
-   animações respeitam reduced motion;
-   RAG usa texto/ícone além de cor.

## IA

Respostas do Copilot devem permanecer legíveis por tecnologias
assistivas e indicar natureza de recomendações.

## Box Focus

Duplo clique não pode ser o único meio: oferecer botão nomeado por box, operável por teclado e com estado selecionado exposto à tecnologia assistiva. `Escape` restaura a tela. A distinção entre box focado e restante deve ser comunicada por rótulo/estado além de cor, com contraste suficiente em escala de cinza e suporte a forced-colors.

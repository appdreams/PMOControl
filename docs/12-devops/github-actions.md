# GitHub Actions

**Status:** Approved

## Responsabilidades

CI, testes, security checks, migration validation e tarefas de release
quando aplicável.

## Segurança

-   usar GitHub Secrets/Environment Secrets;
-   permissões mínimas do workflow;
-   pin/controle de actions;
-   não imprimir secrets;
-   proteger Production environment.

## Artefatos

Test reports e logs podem ser retidos sem dados sensíveis.

## Workflow web inicial

`.github/workflows/ci.yml` executa lint, typecheck e build para mudanças em `apps/web` e no próprio workflow, em Pull Requests e push na branch `main`. Usa permissões somente de leitura e actions fixadas por commit SHA. O primeiro resultado remoto depende de conectar este diretório a um repositório GitHub.

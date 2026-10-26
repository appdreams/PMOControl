# SPEC-028 --- Import & Export --- Readme

**Status:** Draft — remediation required\
**Spec:** 028\
**Módulo:** Import & Export\
**Arquivo:** `README.md`

------------------------------------------------------------------------

## Objetivo

Entrada/saída governada de dados.

## Invariante principal

Importação de dados de projeto segue o workbook versionado [Project Import Workbook v1](project-import-template-v1.md): o alvo é escolhido na tela e permanece limitado ao Tenant ativo. Escopo vazio não pergunta o modo; com dados, é necessário escolher acrescentar ou reiniciar com as permissões da Spec.

## Modelos Excel v1

- [Modelo vazio para importação](templates/project-import-template-v1-empty.xlsx) — arquivo reutilizável, sem registros operacionais; a aplicação preencherá o código do projeto selecionado ao disponibilizar o download.
- [Exemplo preenchido](templates/project-import-template-v1-example.xlsx) — conjunto sintético completo do escopo v1; substitua o código e os dados de demonstração antes de importar.

Os dois arquivos seguem o contrato de abas e colunas documentado em [Project Import Workbook v1](project-import-template-v1.md).

Para instruções detalhadas em linguagem simples, consulte o [Guia de preenchimento para usuários](templates/guia-de-preenchimento.md).

**Import = staging → validate → preview → initial apply (empty scope) OR explicit append/replace confirm → apply.**

## Estrutura da Spec

Esta pasta segue o `SPEC-TEMPLATE` oficial:

``` text
README.md
requirements.md
domain-model.md
user-flows.md
business-rules.md
database.md
api.md
ui.md
permissions.md
events.md
acceptance-criteria.md
edge-cases.md
test-cases.md
```

## Fonte de verdade

O módulo mantém sua entidade operacional oficial; dashboards,
relatórios, Status e IA consomem projeções autorizadas.

## Segurança

Toda operação aplica
`Tenant + Role + Scope + Permission + Data Policy + Workflow Rule`, com
default `DENY`.

## Integrações internas

Quando aplicável: Project Control Center → Status Update → Snapshot →
Dashboard/Portfolio → Reports → PMO Copilot.

## Referências

-   `/docs/00-foundation/`
-   `/docs/02-architecture/`
-   `/docs/03-adrs/`
-   `/docs/04-specs/028-import-export/`


# PMO Control --- Documentação Oficial

**Status:** Draft — SDD semantic re-audit in progress\
**Escopo:** raiz de `/docs`

## 1. Objetivo

Esta pasta contém a documentação oficial do PMO Control, um Project
Governance Operating System voltado à governança, acompanhamento,
controle, decisão e inteligência sobre projetos e portfólios de TI.

A documentação segue abordagem **Spec-Driven Development (SDD)**: o
comportamento esperado é especificado antes ou junto da implementação, e
código, testes, UX, dados, segurança e APIs devem permanecer rastreáveis
às especificações.

## 2. Princípios de leitura

-   **PDD e Product** explicam por que o produto existe e o que precisa
    entregar.
-   **Architecture e ADRs** explicam como as decisões estruturais foram
    tomadas.
-   **Specs** são a principal fonte de verdade funcional dos módulos.
-   **UX** define experiência, navegação, composição e direção visual.
-   **Data** define persistência, relacionamentos, constraints e
    políticas de dados.
-   **Security** define controles obrigatórios e limites de acesso.
-   **API** define contratos de aplicação e integração.
-   **AI** define limites, arquitetura e governança da inteligência
    artificial.
-   **Integrations** define adapters, sincronização e autoridade de
    fontes externas.
-   **Testing** prova requisitos e invariantes.
-   **DevOps** define entrega e operação.
-   **Guides** explica como desenvolver, administrar e operar o sistema.

## 3. Estrutura

  -----------------------------------------------------------------------
  Área                                Responsabilidade
  ----------------------------------- -----------------------------------
  `00-foundation/`                    Glossário, domínio, regras
                                      transversais, permissões,
                                      classificação e convenções

  `01-product/`                       PDD, visão, personas, jornadas,
                                      módulos, MVP, métricas e roadmap

  `02-architecture/`                  Arquitetura de sistema, dados,
                                      segurança, IA, integrações e
                                      deployment

  `03-adrs/`                          Decisões arquiteturais oficiais

  `04-specs/`                         29 especificações funcionais +
                                      template

  `05-ux/`                            Foundations, IA de navegação,
                                      patterns, telas e referências
                                      visuais

  `06-data/`                          Modelo de dados, tabelas,
                                      constraints, RLS, snapshots, audit
                                      e migrations

  `07-security/`                      Threat model e controles de
                                      segurança

  `08-api/`                           Contratos e convenções de API

  `09-ai/`                            AI Gateway, BYOK, Copilot,
                                      grounding, safety e evaluation

  `10-integrations/`                  Estratégia e contratos de
                                      integrações

  `11-testing/`                       Estratégia de testes e quality
                                      gates

  `12-devops/`                        CI/CD, ambientes, observabilidade e
                                      operação

  `13-guides/`                        Guias de desenvolvimento,
                                      administração e uso
  -----------------------------------------------------------------------

## 4. Fluxo recomendado para implementar uma feature

``` text
PDD / Product
      ↓
Functional Map / Module Catalog
      ↓
SPEC do módulo
      ↓
UX correspondente
      ↓
Data + Security + API
      ↓
ADRs/Architecture aplicáveis
      ↓
Acceptance Criteria / Test Cases
      ↓
Implementation
      ↓
Automated Tests
      ↓
Release Gates
```

### Exemplo --- Risks

``` text
01-product
   ↓
04-specs/009-risks
   ↓
05-ux/.../risks.md
   ↓
06-data
   ↓
07-security
   ↓
08-api/governance-api.md
   ↓
11-testing
   ↓
Implementation
```

## 5. Regras de precedência

Em caso de dúvida ou aparente conflito:

1.  Segurança e isolamento de tenant são restrições obrigatórias.
2.  PDD define intenção e escopo do produto.
3.  Specs definem comportamento funcional detalhado.
4.  ADRs definem decisões arquiteturais aceitas.
5.  Architecture define estrutura técnica.
6.  UX define interação e direção visual, sem substituir regras
    funcionais.
7.  API/Data materializam contratos e persistência.
8.  Guides orientam execução, mas não substituem Specs/ADRs.

Conflitos reais devem ser resolvidos atualizando a documentação oficial,
não escolhendo silenciosamente uma fonte.

## 6. Invariantes essenciais

-   `Tenant + Role + Scope + Permission + Data Policy + Workflow Rule`
    determina o acesso efetivo.
-   O browser não é autoridade de segurança.
-   Baseline, Forecast e Actual são conceitos distintos.
-   Risk é diferente de Issue.
-   Delivered é diferente de Accepted.
-   Calculated RAG é diferente de Effective RAG.
-   Status publicado gera Snapshot imutável.
-   Dashboard não é source of truth.
-   Audit Log é append-oriented.
-   AI não amplia autorização.
-   `AI Context ≤ Authorized User Context`.
-   `AI assists. Domain governs. Human decides.`

## 7. Arquivos de controle na raiz

-   `README.md` --- entrada oficial.
-   `MANIFEST.md` --- inventário mestre.
-   `TRACEABILITY.md` --- rastreabilidade entre produto, Specs, UX,
    APIs, dados e testes.
-   `05-ux/SCREEN-TRACEABILITY.md` --- vínculo das 33 telas com Specs,
    permissões, APIs, critérios e testes.
-   `08-api/module-schema-register.md` --- índice de recursos, rotas e
    allowlists de entrada por módulo.
-   `DEPENDENCY-MAP.md` --- dependências de implementação.
-   `IMPLEMENTATION-PLAN.md` --- ordem recomendada de construção.
-   `MVP-CHECKLIST.md` --- controle executivo/técnico do MVP.
-   `CHANGELOG.md` --- mudanças documentais relevantes.

## 8. Regra de manutenção

Mudança de comportamento deve atualizar a Spec correspondente. Mudança
arquitetural relevante deve atualizar Architecture e, quando necessário,
gerar/alterar ADR. Mudança de schema exige Data + migration. Mudança de
contrato exige API. Mudança de autorização exige Security/Permissions e
testes negativos. Mudança de IA exige avaliação de grounding,
autorização e regressão.

O Git mantém o histórico de versões; os nomes oficiais dos documentos
não recebem sufixos `v1`, `v2` sem necessidade excepcional.

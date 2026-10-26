# PMO Control --- Foundation

## 1. Objetivo

A pasta `00-foundation` contém as definições fundamentais e transversais
do PMO Control. Seu objetivo é estabelecer uma linguagem comum para
Produto, UX, Arquitetura, Segurança, Dados, APIs, Inteligência
Artificial, Specifications e implementação, reduzindo ambiguidades
durante o Spec-Driven Development (SDD).

Os documentos desta pasta devem ser consultados antes da criação ou
alteração de qualquer Specification que dependa de conceitos globais do
produto.

## 2. Papel da Foundation no SDD

A Foundation define terminologia oficial, entidades centrais e
relacionamentos, regras de negócio transversais, modelo conceitual de
autorização, classificação de dados e convenções documentais e técnicas.

Ela não substitui o PDD, ADRs, Specifications ou documentação
especializada. Ela fornece os contratos conceituais que esses documentos
devem respeitar.

## 3. Relação com o PDD

A visão, objetivos, escopo e princípios do produto são definidos em
`/docs/01-product/PDD.md`.

O PDD responde: **o que é o PMO Control, por que ele existe e quais
capacidades deve possuir?**

A Foundation responde: **quais conceitos, regras e convenções
fundamentais devem ser compartilhados por todo o sistema?**

## 4. Documentos da Foundation

### `README.md`

Define finalidade, composição, responsabilidades, hierarquia documental
e regras de manutenção da Foundation.

### `glossary.md`

Vocabulário oficial do PMO Control, incluindo Tenant, Portfólio,
Projeto, Baseline, Forecast, Milestone, Deliverable, Risk, Issue,
Action, Decision, Dependency, Status Update, Snapshot, RAG, PMO Copilot,
Scope, Role, Permission e Data Policy.

### `domain-model.md`

Modelo conceitual das principais entidades e relacionamentos:

``` text
Tenant
├── Users
├── Portfolios
│   └── Projects
│       ├── Milestones
│       ├── Deliverables
│       ├── Risks
│       ├── Issues
│       ├── Actions
│       ├── Decisions
│       ├── Dependencies
│       ├── Financial Data
│       ├── Resources
│       ├── Documents
│       ├── Status Updates
│       │   └── Snapshots
│       └── Audit Events
└── Settings
```

Detalhes físicos de tabelas pertencem à documentação de dados e às
respectivas Specs.

### `business-rules.md`

Catálogo das regras globais, como atualização única com propagação,
imutabilidade de status publicado, versionamento de baseline, RAG
rastreável, auditoria de operações sensíveis e snapshots históricos.

### `permission-model.md`

Formaliza o modelo conceitual:

> **Tenant + Role + Scope + Permission + Data Policy + Workflow Rule**

Detalha papéis, escopos, permissões, políticas de dados, workflows,
menor privilégio e segregação de funções.

### `data-classification.md`

Classifica dados internos, confidenciais, financeiros, contratos,
documentos restritos, dados pessoais, credenciais/segredos e dados
utilizados por IA.

### `conventions.md`

Define nomenclatura, idioma, `kebab-case`, IDs, datas, estados, enums,
eventos, APIs, imagens de referência, referências documentais e regras
para agentes de desenvolvimento.

## 5. Hierarquia documental

``` text
PDD
 │ visão, objetivos e escopo
 ▼
Foundation
 │ conceitos e regras transversais
 ▼
ADRs
 │ decisões arquiteturais
 ▼
Specifications
 │ comportamento implementável
 ▼
UX / Data / Security / API / AI
 │ documentação especializada
 ▼
Implementation
 ▼
Tests
```

Nenhum documento deve duplicar desnecessariamente outro. Specs devem
referenciar regras globais da Foundation em vez de redefini-las.

## 6. Fonte de verdade e conflitos

-   O **PDD** governa visão e escopo.
-   A **Foundation** governa conceitos e regras transversais.
-   Uma **ADR aprovada** governa a decisão arquitetural correspondente.
-   Uma **Specification aprovada** governa o comportamento funcional
    implementável.
-   Documentação especializada detalha seu domínio sem contrariar os
    contratos superiores.

Conflitos devem ser resolvidos explicitamente. Uma nova decisão que
altere regra fundamental exige atualização do documento de origem e
revisão dos documentos dependentes.

## 7. Princípios fundamentais

### 7.1 Fonte única de dados

Dados operacionais devem possuir fonte primária. Dashboards, relatórios,
Status Updates, snapshots e Copilot consomem os mesmos dados governados.

### 7.2 Atualizar uma vez, propagar

> **Atualizar uma vez → propagar para todas as visões autorizadas.**

### 7.3 Governança por exceção

O PMO deve ser orientado a atrasos, riscos críticos, issues, ações
vencidas, decisões pendentes, conflitos e mudanças relevantes, sem
precisar inspecionar manualmente todos os projetos.

### 7.4 Histórico confiável

Estados publicados devem ser preservados por snapshots e trilha de
auditoria.

### 7.5 Segurança por padrão

Aplicar isolamento de tenant, menor privilégio, `deny by default` para
recursos sensíveis, autorização server-side e auditoria.

### 7.6 IA não amplia acesso

> Um usuário nunca poderá obter por IA, relatório, exportação ou API um
> dado que não possa acessar diretamente.

### 7.7 Decisão humana

IA pode analisar, resumir, classificar, recomendar e detectar padrões.
Ações relevantes de governança exigem confirmação ou aprovação humana
conforme a política aplicável.

## 8. Princípios de modelagem

Entidades devem possuir identidade própria quando tiverem ciclo de vida,
responsável, histórico, permissões, eventos, relacionamentos ou
necessidade de auditoria.

`Risk`, `Issue`, `Decision` e `StatusUpdate` são entidades de domínio,
não simples atributos de `Project`.

## 9. Princípios de autorização

A autorização não pode depender exclusivamente da interface:

``` text
User
 ↓
Tenant Membership
 ↓
Role
 ↓
Scope
 ↓
Permission
 ↓
Data Policy
 ↓
Workflow Rule
 ↓
ALLOW / DENY
```

Toda operação protegida deve ser validada no backend. A ausência de
autorização explícita para dados sensíveis resulta em `DENY`.

## 10. Princípios de Status Update

Status Update é um processo de governança, não duplicação das telas
operacionais. Deve recuperar dados existentes, identificar mudanças,
permitir revisão, validar qualidade, calcular indicadores e RAG,
publicar, criar snapshot, atualizar visões derivadas e registrar
auditoria.

## 11. Princípios de auditoria

Operações relevantes devem permitir identificar quem, quando, onde, o
que mudou, valor anterior, novo valor e motivo quando necessário.

Prioridades incluem baseline, forecast, financeiro, override de RAG,
publicação de status, decisão executiva, mudança de acesso, exclusão e
exportação sensível.

## 12. Princípios para agentes de desenvolvimento

Agentes de IA usados no desenvolvimento devem consultar a documentação
antes de implementar, não inventar regras ausentes, respeitar Specs e
ADRs, reutilizar conceitos da Foundation, sinalizar conflitos, não
alterar contratos transversais implicitamente e manter testes alinhados
aos Acceptance Criteria.

Uma imagem em `/docs/05-ux/screens/` é **referência visual**, não
definição funcional completa. A Specification correspondente governa
comportamento, permissões, estados e critérios de aceitação.

## 13. Processo de mudança

``` text
Proposta
  ↓
Análise de impacto
  ↓
Atualização do documento fundamental
  ↓
Revisão das Specs/ADRs afetadas
  ↓
Atualização de testes
  ↓
Implementação
```

Mudanças estruturais não devem existir apenas no código.

## 14. Estados documentais

-   `Draft`
-   `Under Review`
-   `Approved`
-   `Deprecated`
-   `Superseded`

Até aprovação explícita, novos documentos do SDD permanecem `Draft` ou
`Under Review`.

## 15. Regra para continuidade

Antes de iniciar uma nova Specification, verificar se os conceitos
existem no Glossary, as entidades estão coerentes com Domain Model,
regras globais com Business Rules, acesso com Permission Model,
informação com Data Classification e documentação com Conventions.

Se uma dessas bases precisar mudar, a alteração deve ocorrer primeiro na
Foundation.

## 16. Referências principais

-   `/docs/01-product/PDD.md`
-   `/docs/02-architecture/`
-   `/docs/03-adrs/`
-   `/docs/04-specs/`
-   `/docs/05-ux/`
-   `/docs/06-data/`
-   `/docs/07-security/`
-   `/docs/08-api/`
-   `/docs/09-ai/`
-   `/docs/11-testing/`

## 17. Status

**Documento:** Foundation README\
**Status:** Under Review\
**Responsabilidade:** definir propósito, limites e regras de utilização
da camada Foundation do PMO Control.

# PMO Control --- Conventions

**Documento:** `conventions.md`\
**Camada:** Foundation\
**Status:** Under Review\
**Tipo:** Convenções transversais de documentação e desenvolvimento

------------------------------------------------------------------------

## 1. Objetivo

Este documento define as convenções oficiais do PMO Control para
documentação, nomenclatura, código, dados, APIs, eventos, datas,
estados, arquivos, UX e Spec-Driven Development (SDD).

O objetivo é reduzir ambiguidade e impedir que diferentes Specs ou
agentes de desenvolvimento criem padrões incompatíveis.

Quando uma convenção específica de tecnologia for necessária, ela poderá
ser detalhada na camada correspondente sem contrariar este documento.

------------------------------------------------------------------------

# 2. Idioma

## Documentação funcional

O conteúdo textual da documentação será escrito preferencialmente em:

``` text
Português do Brasil (pt-BR)
```

## Identificadores técnicos

Código, nomes de arquivos técnicos, propriedades, APIs, eventos, tabelas
e identificadores devem utilizar inglês.

Exemplo:

``` text
Atualização de Status → status-update
Risco                → risk
Decisão              → decision
Marco                 → milestone
```

## Termos de domínio

O termo oficial deve seguir `/docs/00-foundation/glossary.md`.

------------------------------------------------------------------------

# 3. Estrutura de diretórios

A estrutura oficial de documentação é:

``` text
/docs
├── 00-foundation
├── 01-product
├── 02-architecture
├── 03-adrs
├── 04-specs
├── 05-ux
├── 06-data
├── 07-security
├── 08-api
├── 09-ai
├── 10-integrations
├── 11-testing
├── 12-devops
└── 13-guides
```

Os prefixos numéricos devem ser preservados.

------------------------------------------------------------------------

# 4. Nomes de arquivos

Arquivos técnicos devem utilizar:

``` text
lowercase
kebab-case
ASCII
sem espaços
sem acentos
```

Correto:

``` text
domain-model.md
business-rules.md
permission-model.md
data-classification.md
project-control-center.md
```

Evitar:

``` text
Domain Model.md
Regras-de-Negócio.md
permission_model.md
ProjectControlCenter.md
```

------------------------------------------------------------------------

# 5. Nomes de diretórios

Mesma regra:

``` text
kebab-case
```

Exemplo:

``` text
004-portfolios
006-project-control-center
014-status-update
025-pmo-copilot
```

------------------------------------------------------------------------

# 6. Specifications

Formato:

``` text
NNN-feature-name
```

Exemplos:

``` text
001-authentication
002-multi-tenancy
003-rbac
014-status-update
025-pmo-copilot
```

O número identifica a Spec e não deve ser reutilizado para outra
funcionalidade.

------------------------------------------------------------------------

# 7. Estrutura padrão de uma Spec

A estrutura poderá ser refinada pelo `SPEC-TEMPLATE`, mas deve
contemplar, quando aplicável:

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

Nem toda Spec precisa obrigatoriamente de todos os arquivos se o
template permitir composição diferente, mas omissões relevantes devem
ser justificadas.

------------------------------------------------------------------------

# 8. Status documental

Estados oficiais:

``` text
Draft
Under Review
Approved
Deprecated
Superseded
```

Significados:

-   `Draft`: em elaboração;
-   `Under Review`: aguardando validação;
-   `Approved`: aprovado para orientar implementação;
-   `Deprecated`: ainda existente, mas não recomendado;
-   `Superseded`: substituído por outro documento/decisão.

------------------------------------------------------------------------

# 9. Versionamento documental

O Git é a fonte primária de histórico documental.

Evitar nomes como:

``` text
PDD-v2-final-final.md
spec-new-v3.md
```

Preferir:

``` text
PDD.md
requirements.md
api.md
```

A evolução é registrada no versionamento do repositório.

Versões explícitas dentro do conteúdo podem ser utilizadas quando houver
necessidade de governança, contrato ou compatibilidade.

------------------------------------------------------------------------

# 10. Referências entre documentos

Utilizar caminhos absolutos relativos à raiz do repositório documental:

``` text
/docs/00-foundation/domain-model.md
/docs/04-specs/014-status-update/
/docs/07-security/authorization.md
```

Evitar referências vagas como:

> "consulte o documento de segurança".

------------------------------------------------------------------------

# 11. Identificadores de regras

Business Rules globais:

``` text
BR-<DOMAIN>-<NUMBER>
```

Exemplo:

``` text
BR-STS-006
BR-RAG-005
BR-AI-001
```

Regras locais de uma Spec poderão utilizar prefixo próprio definido no
template.

------------------------------------------------------------------------

# 12. ADRs

Formato recomendado:

``` text
ADR-NNN-short-title.md
```

Exemplo:

``` text
ADR-001-technology-stack.md
ADR-002-multi-tenancy.md
ADR-005-row-level-security.md
```

Uma ADR deve registrar:

-   contexto;
-   decisão;
-   alternativas consideradas;
-   consequências;
-   status.

------------------------------------------------------------------------

# 13. IDs de entidades

Entidades persistentes relevantes devem possuir identificador estável.

Diretriz:

``` text
id
```

como nome lógico padrão.

Foreign keys:

``` text
tenant_id
project_id
portfolio_id
risk_id
```

A tecnologia física do ID será definida em arquitetura/dados.

Evitar depender de IDs sequenciais expostos quando isso aumentar risco
de enumeração.

------------------------------------------------------------------------

# 14. Tenant ID

Dados de negócio devem possuir vínculo inequívoco ao Tenant.

Quando existir coluna física:

``` text
tenant_id
```

é o nome preferencial.

O `tenant_id` enviado pelo cliente nunca deve ser considerado autoridade
suficiente para autorização.

------------------------------------------------------------------------

# 15. Nomenclatura de propriedades

Preferir inglês e `snake_case` em banco/payloads quando definido pela
arquitetura de dados/API.

Exemplos:

``` text
created_at
updated_at
published_at
due_date
forecast_date
baseline_date
actual_date
effective_rag
calculated_rag
```

No código TypeScript, a convenção específica poderá usar `camelCase`
conforme padrão técnico.

A transformação entre camadas deve ser explícita e consistente.

------------------------------------------------------------------------

# 16. Datas

Datas sem horário devem usar semanticamente:

``` text
YYYY-MM-DD
```

Exemplo:

``` text
2026-10-25
```

Evitar formatos ambíguos em contratos técnicos:

``` text
10/11/2026
```

Na UI pt-BR, apresentação local pode utilizar:

``` text
25/10/2026
```

------------------------------------------------------------------------

# 17. DateTime

Timestamps técnicos devem utilizar ISO 8601.

Exemplo:

``` text
2026-10-25T13:45:30Z
```

Armazenamento deve preferir uma referência temporal inequívoca,
normalmente UTC.

A UI converte para timezone apropriado.

------------------------------------------------------------------------

# 18. Timezone

Não assumir timezone silenciosamente.

Eventos críticos devem preservar informação suficiente para reconstruir
o instante real.

Exemplos:

-   publicação;
-   auditoria;
-   aprovação;
-   decisão;
-   autenticação.

------------------------------------------------------------------------

# 19. Dinheiro

Valores monetários não devem depender apenas de `float`.

O modelo deve representar:

``` text
amount
currency
```

Exemplo:

``` text
amount: 150000.00
currency: BRL
```

A representação física será definida em `/docs/06-data/`.

------------------------------------------------------------------------

# 20. Percentuais

Percentuais devem possuir semântica explícita.

Exemplo:

``` text
progress_percent: 75
```

ou outra convenção única definida na camada de dados.

Não misturar silenciosamente:

``` text
0.75
75
75%
```

no mesmo contrato.

------------------------------------------------------------------------

# 21. Booleanos

Nomes devem expressar condição positiva quando possível:

``` text
is_active
is_critical
is_confidential
requires_approval
```

Evitar dupla negação:

``` text
is_not_disabled
```

------------------------------------------------------------------------

# 22. Enums

Estados e categorias governadas devem utilizar enums/documentação
explícita.

Exemplo:

``` text
draft
under_review
published
superseded
```

Evitar strings livres para estados críticos.

Enums técnicos:

``` text
lowercase_snake_case
```

salvo decisão arquitetural diferente.

------------------------------------------------------------------------

# 23. Estados

Cada entidade com lifecycle relevante deve declarar:

1.  estados válidos;
2.  estado inicial;
3.  transições válidas;
4.  transições proibidas;
5.  permissões por transição;
6.  eventos produzidos.

Exemplo:

``` text
draft
  ↓
under_review
  ↓
published
```

------------------------------------------------------------------------

# 24. RAG

Valores técnicos:

``` text
green
amber
red
```

Se futuramente existir estado adicional, ele deve ser formalmente
definido.

Na UI:

``` text
Verde
Amarelo
Vermelho
```

podem ser utilizados conforme idioma.

Não utilizar apenas cor para comunicar estado.

------------------------------------------------------------------------

# 25. Null, vazio e desconhecido

Devem possuir significados distintos quando necessário.

Exemplo:

``` text
actual_date = null
```

pode significar:

> ainda não realizado.

Não substituir automaticamente `null` por string vazia.

Valores como:

``` text
unknown
not_applicable
not_provided
```

devem ser modelados explicitamente quando semanticamente relevantes.

------------------------------------------------------------------------

# 26. Soft Delete e Archive

Não utilizar `deleted = true` como solução universal sem definição.

Estados possíveis:

``` text
active
archived
cancelled
deleted
```

possuem significados diferentes.

A estratégia física será definida posteriormente.

------------------------------------------------------------------------

# 27. Eventos de domínio

Eventos descrevem fatos ocorridos e devem usar passado semântico.

Formato recomendado:

``` text
PascalCase
```

Exemplos:

``` text
ProjectCreated
RiskEscalated
IssueResolved
DecisionMade
StatusPublished
SnapshotCreated
RAGOverridden
```

Evitar evento com nome de comando:

``` text
PublishStatus
CreateProject
```

------------------------------------------------------------------------

# 28. Commands

Quando o sistema utilizar Commands explicitamente, eles representam
intenção.

Exemplos:

``` text
CreateProject
PublishStatus
ApproveDecision
OverrideRAG
```

Distinção:

``` text
Command: PublishStatus
Event:   StatusPublished
```

------------------------------------------------------------------------

# 29. APIs

URLs REST, quando utilizadas, devem preferir substantivos no plural:

``` text
/projects
/projects/{project_id}
/projects/{project_id}/risks
/status-updates
```

Evitar:

``` text
/getProjects
/createRisk
```

Ações que não se encaixam naturalmente em CRUD devem ser modeladas
explicitamente pela Spec/API convention.

------------------------------------------------------------------------

# 30. HTTP

Utilizar semântica HTTP apropriada quando REST for adotado.

Exemplo conceitual:

``` text
GET    read
POST   create/action
PATCH  partial update
PUT    replacement when appropriate
DELETE delete/archive only when contract says so
```

Não assumir que `DELETE` significa hard delete.

------------------------------------------------------------------------

# 31. API errors

Erros devem possuir estrutura consistente.

Exemplo conceitual:

``` json
{
  "code": "STATUS_PUBLICATION_NOT_ALLOWED",
  "message": "Status cannot be published in the current state.",
  "correlation_id": "..."
}
```

Mensagens para usuário podem ser localizadas; `code` deve ser estável.

------------------------------------------------------------------------

# 32. Paginação

Listagens potencialmente grandes devem prever paginação.

O padrão final será definido em:

``` text
/docs/08-api/pagination.md
```

Não criar um padrão diferente por Spec sem justificativa.

------------------------------------------------------------------------

# 33. Idempotência

Operações críticas suscetíveis a retry devem declarar estratégia de
idempotência.

Exemplos:

-   publicação;
-   importação;
-   integração;
-   criação por webhook;
-   jobs.

------------------------------------------------------------------------

# 34. Correlation ID

Operações distribuídas devem possuir mecanismo de correlação quando
necessário para observabilidade.

Nome sugerido:

``` text
correlation_id
```

------------------------------------------------------------------------

# 35. Logs

Logs técnicos devem ser estruturados quando possível.

Campos conceituais:

``` text
timestamp
level
service
tenant_id
actor_id
correlation_id
event
resource_id
status
duration_ms
```

Nunca registrar segredos.

------------------------------------------------------------------------

# 36. Níveis de log

Convenção conceitual:

``` text
DEBUG
INFO
WARN
ERROR
```

`ERROR` deve representar falha real, não evento normal de negócio.

------------------------------------------------------------------------

# 37. Auditoria versus log técnico

Não confundir:

``` text
Application Log
```

com:

``` text
Audit Log
```

Log técnico auxilia operação/diagnóstico.

Audit Log preserva eventos relevantes de segurança e governança.

------------------------------------------------------------------------

# 38. Imagens de UX

Referências visuais ficam em:

``` text
/docs/05-ux/screens/
```

Formato:

``` text
<module>-<view>-reference.png
```

Exemplos:

``` text
portfolio-main-reference.png
project-control-center-main-reference.png
milestones-timeline-reference.png
```

------------------------------------------------------------------------

# 39. Status Update UX

Para etapas numeradas:

``` text
<number>-<step-name>-reference.png
```

Exemplo:

``` text
01-execution-indicators-reference.png
02-milestones-deliverables-reference.png
03-risks-issues-reference.png
04-actions-decisions-reference.png
05-summary-publication-reference.png
```

------------------------------------------------------------------------

# 40. Imagem não é Specification

Uma imagem de referência define principalmente intenção visual.

Ela não possui autoridade isolada para determinar:

-   autorização;
-   regra de negócio;
-   validação;
-   persistência;
-   transição de estado;
-   API;
-   auditoria.

Em conflito, o comportamento funcional deve ser resolvido na
Specification e nos documentos de autoridade correspondentes.

------------------------------------------------------------------------

# 41. UX --- textos e labels

Labels da interface podem utilizar pt-BR.

Exemplo:

``` text
Novo Risco
Publicar Status
Decisões Pendentes
```

Identificadores técnicos permanecem em inglês.

------------------------------------------------------------------------

# 42. UX --- estados

Estados devem ser comunicados por mais de uma pista visual quando
necessário.

Exemplo:

``` text
● Crítico
```

e não apenas um círculo vermelho sem label.

------------------------------------------------------------------------

# 43. UX --- confirmação

Ações de impacto relevante devem possuir confirmação adequada.

Exemplos:

-   Publish Status;
-   RAG Override;
-   Baseline Change;
-   Delete/Archive;
-   Executive Decision;
-   sensitive export.

------------------------------------------------------------------------

# 44. Nomenclatura de testes

Testes devem descrever comportamento.

Exemplo:

``` text
should deny project access when project belongs to another tenant
```

Evitar:

``` text
test1
testProject
```

------------------------------------------------------------------------

# 45. Acceptance Criteria

Preferir critérios verificáveis.

Formato Gherkin pode ser utilizado:

``` gherkin
Given a user can prepare a Status Update
And the user does not have status.update.publish
When the user attempts to publish it
Then publication must be denied
```

Acceptance Criteria não devem depender de interpretação subjetiva.

------------------------------------------------------------------------

# 46. Requirements

Requisitos devem ser identificáveis e rastreáveis.

Formato recomendado por Spec:

``` text
FR-001
FR-002
NFR-001
NFR-002
```

Onde:

-   `FR` = Functional Requirement;
-   `NFR` = Non-Functional Requirement.

Quando necessário, incluir prefixo da Spec.

------------------------------------------------------------------------

# 47. Prioridade de requisitos

Convenção recomendada:

``` text
MUST
SHOULD
MAY
```

Não utilizar simultaneamente vários modelos de prioridade sem mapeamento
explícito.

------------------------------------------------------------------------

# 48. Edge Cases

Cada Spec deve registrar casos limítrofes relevantes.

Exemplos:

-   recurso removido durante edição;
-   permissão revogada durante sessão;
-   publicação concorrente;
-   integração duplicada;
-   projeto arquivado;
-   usuário removido do Tenant.

------------------------------------------------------------------------

# 49. Security by design

Toda Spec deve considerar segurança durante o design, não após
implementação.

Perguntas mínimas:

``` text
Who can access?
What Scope?
What data classification?
What can change?
What is audited?
What happens cross-tenant?
What can AI see?
What can be exported?
```

------------------------------------------------------------------------

# 50. AI by design

Specs que utilizem IA devem declarar:

``` text
Use Case
Input Data
Classification
Provider
Model Strategy
Authorization Context
Prompt/Context Rules
Output Type
Human Confirmation
Audit/Telemetry
Fallback
```

------------------------------------------------------------------------

# 51. Nomes de modelos de IA

Não codificar modelo comercial diretamente na regra de negócio quando
não necessário.

Preferir abstrações:

``` text
fast-model
reasoning-model
embedding-model
```

ou routing configurável.

A configuração técnica decide o provider/model real.

------------------------------------------------------------------------

# 52. BYOK

Chaves devem ser referenciadas por identificadores/configuração segura.

Nunca:

``` text
api_key = "sk-..."
```

em código, documentação de exemplo real ou logs.

------------------------------------------------------------------------

# 53. Configuração

Configurações variáveis por ambiente não devem ser hardcoded.

Exemplos:

-   URLs;
-   secrets;
-   feature flags;
-   SMTP;
-   AI providers;
-   storage;
-   webhook secrets.

------------------------------------------------------------------------

# 54. Ambientes

Nomes conceituais:

``` text
local
development
preview
staging
production
```

A lista final será definida em DevOps.

Dados e credenciais não devem ser compartilhados indiscriminadamente
entre ambientes.

------------------------------------------------------------------------

# 55. Feature flags

Funcionalidades experimentais ou rollout gradual podem utilizar feature
flags.

Flags não substituem autorização.

------------------------------------------------------------------------

# 56. Comentários no código

Comentários devem explicar:

-   por que;
-   restrição;
-   trade-off;
-   regra não óbvia.

Evitar comentar literalmente o que o código já expressa.

------------------------------------------------------------------------

# 57. TODOs

TODO técnico deve ser rastreável quando representar trabalho real.

Evitar acumular:

``` text
TODO: fix later
```

sem contexto.

------------------------------------------------------------------------

# 58. Nomenclatura de branches

A estratégia definitiva será definida em `/docs/13-guides/`.

Convenção inicial sugerida:

``` text
feature/014-status-update
fix/status-publication-race
docs/permission-model
```

------------------------------------------------------------------------

# 59. Commits

Commits devem ser pequenos, coerentes e descrever a mudança.

A adoção de Conventional Commits poderá ser formalizada posteriormente.

Exemplos:

``` text
feat(status): add publication validation
fix(rbac): enforce project scope
docs(foundation): define permission model
```

------------------------------------------------------------------------

# 60. Pull Requests

PRs devem indicar, quando aplicável:

-   Spec relacionada;
-   requisito;
-   regra de negócio;
-   testes;
-   migrations;
-   impacto de segurança;
-   screenshots;
-   decisões arquiteturais.

------------------------------------------------------------------------

# 61. Database migrations

Mudanças de schema devem utilizar migrations versionadas.

Não alterar manualmente Production sem mecanismo rastreável.

Migrations devem considerar rollback/forward recovery conforme risco.

------------------------------------------------------------------------

# 62. Seeds

Seeds de desenvolvimento não devem conter segredos ou dados reais
sensíveis.

Preferir dados sintéticos.

------------------------------------------------------------------------

# 63. Fixtures

Fixtures de testes devem evitar dependência desnecessária de dados
reais.

Testes de Tenant isolation devem possuir explicitamente múltiplos
Tenants.

------------------------------------------------------------------------

# 64. Multi-tenancy tests

Toda funcionalidade que manipule dados tenant-scoped deve possuir testes
de isolamento adequados.

Exemplo mínimo:

``` text
Tenant A cannot read Tenant B
Tenant A cannot update Tenant B
Tenant A cannot delete Tenant B
Tenant A cannot infer Tenant B
```

------------------------------------------------------------------------

# 65. Naming de permissões

Formato:

``` text
<resource>.<action>
```

Exemplos:

``` text
project.read
risk.create
status.update.publish
financial.view
projects.{projectId}.rag-evaluations.override
decision.approve
```

Evitar permissões genéricas como:

``` text
can_manage_everything
admin_access
```

------------------------------------------------------------------------

# 66. Nomes de Data Policies

Devem expressar claramente a categoria.

Exemplos:

``` text
financial
confidential_documents
resource_capacity
personal_data
```

O formato técnico definitivo será definido na Spec de RBAC/Security.

------------------------------------------------------------------------

# 67. Segurança em exemplos

Documentação nunca deve utilizar credenciais reais.

Utilizar placeholders:

``` text
OPENAI_API_KEY=<secret>
DATABASE_URL=<secret>
```

------------------------------------------------------------------------

# 68. URLs e endpoints em documentação

Exemplos devem evitar domínios reais internos quando não necessários.

Preferir:

``` text
https://api.example.com
```

ou caminhos relativos.

------------------------------------------------------------------------

# 69. PII em documentação

Não utilizar dados pessoais reais em exemplos quando dados fictícios
forem suficientes.

Preferir:

``` text
Ana Silva
ana@example.com
```

------------------------------------------------------------------------

# 70. Source of Truth

Hierarquia conceitual:

``` text
PDD
 ↓
Foundation
 ↓
ADRs
 ↓
Specifications
 ↓
Specialized Documentation
 ↓
Implementation
 ↓
Tests
```

Cada camada governa sua responsabilidade.

Um documento inferior não deve alterar silenciosamente contrato
superior.

------------------------------------------------------------------------

# 71. Conflitos documentais

Quando houver conflito:

1.  identificar documentos envolvidos;
2.  determinar autoridade de cada um;
3.  registrar a decisão;
4.  atualizar o documento correto;
5.  revisar dependências;
6.  somente então implementar.

Não escolher silenciosamente a interpretação mais conveniente.

------------------------------------------------------------------------

# 72. Regras para agentes de IA de desenvolvimento

Antes de implementar uma Spec, o agente deve consultar:

``` text
PDD
Foundation
Relevant ADRs
Target Spec
Relevant UX
Security/Data/API docs
```

O agente deve:

-   respeitar contratos;
-   não inventar regra crítica;
-   sinalizar ambiguidade;
-   preservar Tenant isolation;
-   preservar autorização;
-   gerar testes;
-   manter rastreabilidade.

------------------------------------------------------------------------

# 73. Ordem recomendada de leitura para uma feature

Exemplo para `014-status-update`:

``` text
1. /docs/01-product/PDD.md
2. /docs/00-foundation/glossary.md
3. /docs/00-foundation/domain-model.md
4. /docs/00-foundation/business-rules.md
5. /docs/00-foundation/permission-model.md
6. /docs/00-foundation/data-classification.md
7. /docs/03-adrs/ relevantes
8. /docs/04-specs/014-status-update/
9. /docs/05-ux/screens/status-update/
10. documentação especializada relevante
```

------------------------------------------------------------------------

# 74. Definition of Ready documental

Uma Spec está pronta para implementação quando, no mínimo:

-   objetivo está claro;
-   atores estão definidos;
-   requirements estão definidos;
-   regras de negócio estão referenciadas;
-   estados/transições estão definidos;
-   permissões estão definidas;
-   dados/classificação estão definidos;
-   APIs/eventos necessários estão definidos;
-   UX relevante está referenciada;
-   Acceptance Criteria estão definidos;
-   Edge Cases relevantes estão definidos;
-   decisões arquiteturais necessárias foram tomadas.

------------------------------------------------------------------------

# 75. Definition of Done documental

Uma feature implementada deve possuir, conforme aplicável:

-   código;
-   migrations;
-   testes;
-   autorização;
-   auditoria;
-   observabilidade;
-   documentação atualizada;
-   Acceptance Criteria satisfeitos;
-   UX validada;
-   segurança validada;
-   ausência de conflito conhecido com Foundation/ADRs.

------------------------------------------------------------------------

# 76. Regra de não duplicação

Não copiar grandes blocos de regras globais para cada Spec.

Preferir:

``` text
Applies: BR-STS-006
Applies: BR-AUTHZ-002
```

e adicionar somente comportamento específico.

Isso reduz divergência futura.

------------------------------------------------------------------------

# 77. Regra de decisão explícita

Quando uma questão importante permanecer aberta, registrar:

``` text
Open Decision
```

ou criar ADR/issue apropriado.

Não deixar agentes de desenvolvimento resolverem implicitamente decisões
de produto ou arquitetura.

------------------------------------------------------------------------

# 78. Convenção para diagramas textuais

Diagramas simples podem utilizar ASCII:

``` text
Project
  ↓
Status Update
  ↓
Snapshot
```

Diagramas arquiteturais complexos poderão utilizar Mermaid se a
ferramenta/repositório suportar renderização confiável.

------------------------------------------------------------------------

# 79. Convenção para exemplos

Exemplos devem ser claramente distinguíveis de regras normativas.

Usar expressões como:

``` text
Example
Suggested
Initial
Conceptual
```

quando a definição ainda não for definitiva.

------------------------------------------------------------------------

# 80. Normatividade

Palavras-chave:

-   **MUST** --- obrigatório;
-   **MUST NOT** --- proibido;
-   **SHOULD** --- recomendado;
-   **SHOULD NOT** --- normalmente evitar;
-   **MAY** --- opcional.

Esses termos devem ser usados conscientemente.

------------------------------------------------------------------------

# 81. Mudanças nas convenções

Alterações neste documento podem impactar todo o repositório.

Antes de mudar uma convenção:

1.  identificar impacto;
2.  decidir se migração é necessária;
3.  atualizar este documento;
4.  atualizar templates;
5.  atualizar documentos afetados;
6.  atualizar automações/linters quando aplicável.

------------------------------------------------------------------------

# 82. Pontos para definição posterior

Documentos especializados ainda deverão fechar:

1.  formatter/linter;
2.  padrão TypeScript;
3.  convenção React/Next.js;
4.  padrão SQL;
5.  padrão OpenAPI;
6.  paginação definitiva;
7.  error envelope definitivo;
8.  branching strategy;
9.  release strategy;
10. Conventional Commits obrigatório ou não;
11. Mermaid;
12. semantic versioning;
13. migrations;
14. feature flags;
15. observability conventions detalhadas.

------------------------------------------------------------------------

# 83. Referências

-   `/docs/00-foundation/README.md`
-   `/docs/00-foundation/glossary.md`
-   `/docs/00-foundation/domain-model.md`
-   `/docs/00-foundation/business-rules.md`
-   `/docs/00-foundation/permission-model.md`
-   `/docs/00-foundation/data-classification.md`
-   `/docs/01-product/PDD.md`
-   `/docs/03-adrs/`
-   `/docs/04-specs/`
-   `/docs/05-ux/`
-   `/docs/06-data/`
-   `/docs/07-security/`
-   `/docs/08-api/`
-   `/docs/09-ai/`
-   `/docs/11-testing/`
-   `/docs/12-devops/`
-   `/docs/13-guides/`

------------------------------------------------------------------------

# 84. Status

**Documento:** Conventions\
**Status:** Under Review\
**Responsabilidade:** estabelecer convenções transversais de
documentação, nomenclatura, contratos técnicos e Spec-Driven Development
do PMO Control.

# PMO Control --- Data Classification

**Documento:** `data-classification.md`\
**Camada:** Foundation\
**Status:** Under Review\
**Tipo:** Classificação e tratamento conceitual de dados

------------------------------------------------------------------------

## 1. Objetivo

Este documento define o modelo conceitual de classificação de dados do
PMO Control.

A classificação orienta:

-   autorização;
-   Data Policies;
-   armazenamento;
-   logs;
-   exportações;
-   documentos;
-   integrações;
-   backups;
-   auditoria;
-   Inteligência Artificial;
-   retenção;
-   compartilhamento;
-   observabilidade.

A implementação detalhada será definida principalmente em
`/docs/06-data/`, `/docs/07-security/`, `/docs/09-ai/` e nas
Specifications correspondentes.

------------------------------------------------------------------------

# 2. Princípio central

Acesso ao recurso não implica acesso automático a todos os dados
contidos nele.

Exemplo:

``` text
project.read = ALLOW
financial.view = DENY
```

O usuário pode visualizar o Project, mas não seus dados financeiros
protegidos.

A classificação deve acompanhar o dado em todos os canais relevantes:

``` text
UI
API
Reports
Exports
Notifications
Integrations
Logs
AI / Copilot
Backups
```

------------------------------------------------------------------------

# 3. Níveis de classificação

O PMO Control adota inicialmente cinco níveis conceituais:

  -----------------------------------------------------------------------
  Nível                   Nome                    Descrição
  ----------------------- ----------------------- -----------------------
  `L1`                    Public                  Informação que pode ser
                                                  divulgada publicamente
                                                  quando explicitamente
                                                  aprovada

  `L2`                    Internal                Informação interna de
                                                  uso normal do Tenant

  `L3`                    Confidential            Informação com acesso
                                                  restrito por função,
                                                  escopo ou necessidade

  `L4`                    Restricted              Informação altamente
                                                  sensível, sujeita a
                                                  controles adicionais

  `L5`                    Secret                  Credenciais, tokens,
                                                  chaves e segredos que
                                                  não devem ser expostos
                                                  a usuários comuns
  -----------------------------------------------------------------------

A classificação padrão de dados de negócio do PMO Control deve ser, no
mínimo, `Internal`, salvo definição explícita diferente.

------------------------------------------------------------------------

# 4. L1 --- Public

## Definição

Informação aprovada para divulgação pública.

Exemplos possíveis:

-   conteúdo institucional;
-   material público de produto;
-   informações de projeto explicitamente publicadas externamente.

## Regras

-   informação não se torna pública apenas por não parecer sensível;
-   publicação deve ser intencional;
-   dados de projeto são `Internal` por padrão;
-   informações pessoais, financeiras, confidenciais ou segredos não
    podem ser classificadas como Public sem base legítima e processo
    apropriado.

------------------------------------------------------------------------

# 5. L2 --- Internal

## Definição

Informação de uso interno do Tenant que não requer, por padrão,
controles especiais além da autorização normal.

Exemplos:

-   nome de projeto;
-   descrição;
-   fase;
-   progresso;
-   milestones comuns;
-   deliverables comuns;
-   actions não sensíveis;
-   status operacional comum.

## Controles

-   Tenant isolation;
-   Scope;
-   Permission;
-   autenticação;
-   proteção em trânsito;
-   controles normais de aplicação.

------------------------------------------------------------------------

# 6. L3 --- Confidential

## Definição

Informação que pode causar impacto relevante ao Tenant, projeto ou
pessoas se divulgada indevidamente.

Exemplos:

-   riscos estratégicos;
-   issues sensíveis;
-   decisões executivas;
-   relatórios restritos;
-   contratos;
-   documentos confidenciais;
-   informações comerciais;
-   determinados dados de recursos;
-   determinadas evidências.

## Controles adicionais

Podem incluir:

-   Permission específica;
-   Data Policy;
-   restrição de exportação;
-   auditoria;
-   limitação no Copilot;
-   proteção contra exposição em notificações;
-   mascaramento.

------------------------------------------------------------------------

# 7. L4 --- Restricted

## Definição

Informação altamente sensível cuja exposição pode gerar impacto
financeiro, jurídico, regulatório, de segurança ou privacidade
significativo.

Exemplos:

-   dados financeiros sensíveis;
-   dados pessoais protegidos;
-   informações de segurança;
-   documentos altamente restritos;
-   informações contratuais críticas;
-   conteúdo sujeito a obrigação regulatória específica.

## Controles esperados

-   autorização explícita;
-   deny by default;
-   menor privilégio;
-   auditoria de operações relevantes;
-   restrição de exportação;
-   proteção em logs;
-   proteção no contexto de IA;
-   retenção definida;
-   criptografia conforme arquitetura;
-   revisão de integrações.

------------------------------------------------------------------------

# 8. L5 --- Secret

## Definição

Segredos técnicos e credenciais que permitem autenticação, acesso ou
execução privilegiada.

Exemplos:

``` text
API Keys
BYOK Keys
OAuth Secrets
SMTP Credentials
Signing Secrets
Database Credentials
Service Tokens
Webhook Secrets
Encryption Keys
```

## Regras

Segredos:

-   não devem ser exibidos novamente em texto puro quando não
    necessário;
-   não devem ser registrados em logs;
-   não devem ser enviados ao modelo de IA como contexto comum;
-   não devem ser armazenados em código-fonte;
-   não devem ser expostos ao frontend;
-   devem utilizar mecanismo apropriado de secrets management;
-   devem possuir processo de rotação/revogação.

------------------------------------------------------------------------

# 9. Categorias funcionais

Além do nível de sensibilidade, dados podem possuir categorias.

Categorias iniciais:

``` text
project-data
financial-data
personal-data
resource-data
confidential-document
security-data
audit-data
ai-data
credential-secret
integration-data
```

Um dado pode possuir:

``` text
Classification Level + Category
```

Exemplo:

``` text
Budget
Level: Restricted
Category: financial-data
```

------------------------------------------------------------------------

# 10. Project Data

Inclui:

-   Project;
-   Portfolio;
-   Milestones;
-   Deliverables;
-   Risks;
-   Issues;
-   Actions;
-   Decisions;
-   Dependencies;
-   Status Updates.

Classificação padrão sugerida:

``` text
Internal
```

mas entidades ou campos específicos podem ser elevados para
`Confidential` ou `Restricted`.

------------------------------------------------------------------------

# 11. Financial Data

Inclui:

-   Budget;
-   Actual Cost;
-   Forecast;
-   commitments;
-   invoices, se futuramente suportadas;
-   financial variance;
-   investimentos.

Classificação padrão sugerida:

``` text
Restricted
```

Data Policy inicial:

``` text
financial.view
financial.edit
```

Acesso a Project não concede automaticamente acesso financeiro.

------------------------------------------------------------------------

# 12. Personal Data

Informações relacionadas a pessoa natural identificada ou identificável
devem receber tratamento compatível com LGPD e políticas aplicáveis.

Exemplos possíveis:

-   nome;
-   e-mail;
-   identificadores;
-   informações profissionais associadas ao usuário;
-   dados de atividade;
-   dados de acesso.

Classificação depende do campo e contexto, mas dados pessoais devem
possuir controles explícitos.

Princípios:

-   finalidade;
-   necessidade;
-   minimização;
-   acesso controlado;
-   retenção;
-   segurança;
-   rastreabilidade quando necessária.

------------------------------------------------------------------------

# 13. Resource Data

Dados de capacidade e alocação podem conter informação sensível sobre
pessoas.

Exemplos:

-   allocation;
-   capacity;
-   disponibilidade;
-   função;
-   custo, caso futuramente suportado.

Classificação pode variar entre `Internal`, `Confidential` e
`Restricted`.

Permissões:

``` text
resources.view
resources.edit
```

Dados financeiros de recurso podem exigir política adicional.

------------------------------------------------------------------------

# 14. Documents

Todo Document deve poder possuir classificação.

Exemplo:

``` text
Document
├── classification
├── category
├── owner
├── tenant
├── context
└── retention policy
```

Classes possíveis:

``` text
Internal
Confidential
Restricted
```

Permissão adicional:

``` text
documents.confidential.view
```

pode ser utilizada conforme o modelo definitivo.

------------------------------------------------------------------------

# 15. Evidence

Evidence herda ou recebe classificação compatível com seu conteúdo e
fonte.

Uma evidência associada a uma Decision confidencial não deve ser exposta
apenas porque o usuário pode visualizar o título da Decision.

------------------------------------------------------------------------

# 16. Audit Data

Audit Logs podem conter informação sensível sobre:

-   atores;
-   recursos;
-   alterações;
-   IP/dispositivo, se coletados;
-   valores anteriores;
-   valores posteriores;
-   operações de segurança.

Classificação sugerida:

``` text
Confidential / Restricted
```

Acesso ao Audit Log deve ser restrito.

------------------------------------------------------------------------

# 17. Security Data

Inclui:

-   eventos de autenticação;
-   falhas de autorização;
-   configurações de segurança;
-   sessões;
-   informações técnicas de proteção.

Classificação típica:

``` text
Restricted
```

Alguns elementos podem ser `Secret`.

------------------------------------------------------------------------

# 18. AI Data

Dados enviados para provedores de IA devem ser classificados antes do
envio.

O fato de uma informação estar autorizada para o usuário não significa
automaticamente que pode ser enviada a qualquer provedor/modelo.

O pipeline deve considerar:

``` text
User Authorization
        +
Data Classification
        +
Tenant AI Policy
        +
Provider Policy
        ↓
Allowed AI Context
```

------------------------------------------------------------------------

# 19. BYOK

Chaves BYOK são:

``` text
Level: Secret
Category: credential-secret
```

Regras:

-   isolamento por Tenant;
-   armazenamento protegido;
-   nunca expor valor completo após armazenamento;
-   nunca inserir em prompt;
-   nunca registrar em logs;
-   acesso administrativo altamente restrito;
-   permitir revogação/substituição.

------------------------------------------------------------------------

# 20. Dados em prompts

Antes de enviar dados a um modelo:

1.  validar Tenant;
2.  validar Scope;
3.  validar Permission;
4.  aplicar Data Policy;
5.  aplicar classificação;
6.  minimizar contexto;
7.  aplicar política do provedor;
8.  registrar telemetria segura quando necessário.

Segredos `L5` não devem fazer parte de prompts comuns.

------------------------------------------------------------------------

# 21. Dados em respostas de IA

O PMO Copilot deve evitar revelar:

-   dados fora do Scope;
-   informação financeira sem `financial.view`;
-   documento confidencial sem permissão;
-   dados pessoais desnecessários;
-   segredos;
-   conteúdo de outro Tenant.

A resposta deve respeitar a mesma política aplicada ao retrieval.

------------------------------------------------------------------------

# 22. Logs

Logs não devem se tornar um repositório paralelo de dados sensíveis.

## Proibido registrar em texto puro

-   passwords;
-   access tokens;
-   refresh tokens;
-   BYOK keys;
-   database credentials;
-   secrets;
-   conteúdo confidencial desnecessário.

## Minimização

Preferir:

``` text
resource_id
event_type
tenant_id
actor_id
status
duration
correlation_id
```

em vez de payloads completos.

------------------------------------------------------------------------

# 23. Observabilidade

Traces, metrics e error reports devem respeitar a classificação.

Uma exceção não deve enviar automaticamente o payload completo para
ferramenta de observabilidade.

Dados sensíveis devem ser:

-   omitidos;
-   mascarados;
-   redigidos;
-   tokenizados;

conforme necessidade.

------------------------------------------------------------------------

# 24. Notificações

Notificações devem utilizar o mínimo de informação necessário.

Exemplo preferível:

> Existe uma decisão pendente que requer sua atenção.

em vez de incluir conteúdo confidencial completo em canal não
apropriado.

Abrir a notificação deve revalidar autorização.

------------------------------------------------------------------------

# 25. E-mail

E-mail pode ser considerado canal com menor controle após envio.

Dados `Restricted` não devem ser enviados integralmente por padrão.

Preferir:

``` text
Notification
  ↓
Secure Link
  ↓
Authentication
  ↓
Authorization
  ↓
Content
```

------------------------------------------------------------------------

# 26. Reports

A classificação deve ser aplicada antes da composição do Report.

``` text
Authorized Data
     ↓
Classification Filter
     ↓
Report
```

Relatórios contendo dados `Confidential` ou `Restricted` devem manter
classificação apropriada.

------------------------------------------------------------------------

# 27. Exports

Exportação cria uma cópia fora do controle direto da aplicação.

Por isso:

``` text
View Permission ≠ Export Permission
```

Exportações podem exigir:

-   `report.export`;
-   Data Policy específica;
-   Audit Event;
-   watermark ou metadados futuros;
-   aviso de classificação.

------------------------------------------------------------------------

# 28. APIs

A classificação não muda porque o dado é acessado por API.

Endpoints devem aplicar:

``` text
Authentication
Tenant
Scope
Permission
Data Policy
Classification
```

Respostas devem excluir campos não autorizados.

------------------------------------------------------------------------

# 29. Integrações

Antes de enviar informação para integração externa:

-   validar autorização técnica;
-   validar classificação;
-   validar finalidade;
-   limitar campos;
-   verificar Tenant;
-   proteger credenciais;
-   registrar falhas de forma segura.

A integração deve receber somente os dados necessários.

------------------------------------------------------------------------

# 30. Importações

Dados importados devem ser classificados após ingestão.

A origem externa não torna o dado confiável ou público.

Importações devem passar por:

-   validação;
-   normalização;
-   Tenant binding;
-   classificação;
-   autorização.

------------------------------------------------------------------------

# 31. Storage

O armazenamento físico deve considerar classificação.

Documentos e arquivos não devem ser públicos por padrão.

Acesso a objetos deve ser mediado por controles compatíveis com Tenant e
Permission.

URLs permanentes públicas para documentos privados devem ser evitadas.

------------------------------------------------------------------------

# 32. Backups

Backups herdam a sensibilidade dos dados armazenados.

Devem possuir controles apropriados de:

-   acesso;
-   retenção;
-   criptografia;
-   restauração;
-   descarte.

A restauração não pode romper Tenant isolation.

------------------------------------------------------------------------

# 33. Ambientes

Dados reais sensíveis não devem ser copiados indiscriminadamente para
ambientes de desenvolvimento ou teste.

Preferir:

-   dados sintéticos;
-   anonimização;
-   mascaramento;
-   subconjuntos autorizados.

------------------------------------------------------------------------

# 34. Screenshots e suporte

Capturas de tela podem conter informação sensível.

Processos de suporte devem orientar minimização e proteção de
screenshots, anexos e evidências.

Acesso de suporte a dados reais deve seguir `Support Access`.

------------------------------------------------------------------------

# 35. Retenção

A classificação influencia a política de retenção, mas não define
sozinha o período.

A retenção final deve considerar:

``` text
Business Need
Legal Requirement
Audit Requirement
Security
Privacy
Contract
```

A política será detalhada em `/docs/06-data/retention-policy.md`.

------------------------------------------------------------------------

# 36. Exclusão

Eliminar uma entidade operacional não implica automaticamente eliminar:

-   Audit Events;
-   Snapshots;
-   evidências obrigatórias;
-   registros sujeitos a retenção.

Exclusão deve respeitar requisitos legais, contratuais e de governança.

------------------------------------------------------------------------

# 37. Mascaramento

Campos sensíveis podem exigir apresentação parcial.

Exemplos:

``` text
API Key: sk-••••••••••••4F2A
Email: p••••@empresa.com
```

A necessidade de mascaramento será definida por campo e contexto.

------------------------------------------------------------------------

# 38. Criptografia

A estratégia técnica será definida na arquitetura de segurança.

Princípio:

-   proteger dados em trânsito;
-   proteger dados sensíveis em repouso conforme arquitetura;
-   aplicar proteção adicional a segredos.

Criptografia não substitui autorização.

------------------------------------------------------------------------

# 39. Data minimization

O sistema deve coletar, armazenar, processar e enviar somente os dados
necessários para a finalidade.

Esse princípio é especialmente importante para:

-   IA;
-   logs;
-   analytics;
-   integrações;
-   notificações;
-   suporte.

------------------------------------------------------------------------

# 40. Classificação por campo

Uma entidade pode conter campos de diferentes níveis.

Exemplo:

``` text
Project
├── name                 → Internal
├── description          → Internal
├── budget               → Restricted
├── executive_notes      → Confidential
└── confidential_file    → Restricted
```

Logo:

> **Entity access ≠ unrestricted field access**

------------------------------------------------------------------------

# 41. Herança de classificação

Princípio inicial:

Um artefato derivado não deve reduzir silenciosamente a classificação da
informação de origem.

Exemplo:

``` text
Restricted Financial Data
        ↓
Executive Report
```

O relatório deve continuar sujeito às restrições adequadas.

------------------------------------------------------------------------

# 42. Agregação e inferência

Mesmo dados individualmente pouco sensíveis podem se tornar sensíveis
quando agregados.

Exemplo:

``` text
Resource Allocation
        +
Project Budget
        +
Delivery Delays
        ↓
Strategic Portfolio Insight
```

Dashboards, Reports e Copilot devem considerar esse risco.

------------------------------------------------------------------------

# 43. Classificação e RAG

RAG normalmente pode ser `Internal`, mas sua justificativa pode conter
dados `Confidential` ou `Restricted`.

Exemplo:

``` text
RAG = RED                       → Internal
Reason = Contract dispute...    → Confidential
```

A UI/API pode precisar permitir acesso ao indicador sem expor toda a
justificativa.

------------------------------------------------------------------------

# 44. Classificação e Decisions

Uma Decision pode ter:

``` text
title        → Internal
status       → Internal
context      → Confidential
evidence     → Restricted
```

A autorização deve suportar esse tipo de separação quando necessário.

------------------------------------------------------------------------

# 45. Classificação e Snapshots

Snapshots preservam a classificação dos dados capturados.

Um Snapshot histórico não se torna menos sensível apenas por ser antigo.

Mudanças posteriores de política podem exigir reavaliação de acesso.

------------------------------------------------------------------------

# 46. Classificação e Time Machine

Time Machine deve aplicar autorização no momento da consulta.

Ter acesso atual ao Project não implica necessariamente acesso
irrestrito a qualquer informação histórica sensível se a política
determinar o contrário.

------------------------------------------------------------------------

# 47. Matriz inicial de classificação

  ---------------------------------------------------------------------------------
  Tipo de dado            Classificação padrão      Política adicional
  ----------------------- ------------------------- -------------------------------
  Project metadata        Internal                  Project Scope

  Portfolio metadata      Internal                  Portfolio Scope

  Milestones              Internal                  Project Scope

  Deliverables            Internal                  Project Scope

  Risks                   Internal/Confidential     Project Scope

  Issues                  Internal/Confidential     Project Scope

  Actions                 Internal                  Assignment/Scope

  Decisions               Confidential              Decision Scope

  Budget                  Restricted                `financial.view`

  Actual Cost             Restricted                `financial.view`

  Financial Forecast      Restricted                `financial.view`

  Resource Allocation     Confidential              `resources.view`

  Personal Data           Confidential/Restricted   Privacy Policy

  Common Documents        Internal                  Document Scope

  Confidential Documents  Confidential/Restricted   `documents.confidential.view`

  Audit Log               Confidential/Restricted   `audit.view`

  BYOK Key                Secret                    `ai.byok.manage`

  Integration Secret      Secret                    `integration.manage`

  Status Snapshot         Inherits content          Status Scope

  AI Prompt Context       Inherits sources          AI Policy
  ---------------------------------------------------------------------------------

A classificação definitiva pode ser refinada pelas Specs.

------------------------------------------------------------------------

# 48. Regras obrigatórias

## DC-001 --- Tenant isolation

Classificação nunca substitui isolamento de Tenant.

## DC-002 --- Default internal

Dados de negócio não explicitamente classificados devem ser tratados, no
mínimo, como `Internal`.

## DC-003 --- Secrets never logged

Segredos não podem aparecer em logs em texto puro.

## DC-004 --- Secrets never prompted

Segredos não devem ser enviados como contexto normal a modelos de IA.

## DC-005 --- Sensitive export control

Dados Confidential/Restricted devem respeitar autorização de exportação.

## DC-006 --- AI authorization

IA só recebe dados autorizados e permitidos pela política de IA.

## DC-007 --- Derived data inheritance

Artefatos derivados devem preservar restrições relevantes das fontes.

## DC-008 --- Field sensitivity

Acesso à entidade não implica acesso automático a todos os campos.

## DC-009 --- Secure storage

Dados não públicos devem utilizar armazenamento não público por padrão.

## DC-010 --- Audit protection

Audit Data deve ser protegido contra alteração indevida.

## DC-011 --- Backup inheritance

Backups herdam a classificação dos dados.

## DC-012 --- Non-production minimization

Dados reais sensíveis não devem ser replicados para ambientes não
produtivos sem controles explícitos.

------------------------------------------------------------------------

# 49. Responsabilidade das Specifications

Cada Spec que introduzir dados relevantes deve declarar:

``` text
Data Created
Data Read
Data Updated
Data Deleted/Archived
Classification
Sensitive Fields
Required Permissions
Retention Considerations
Audit Requirements
AI Usage
Export Rules
```

------------------------------------------------------------------------

# 50. Exemplo de declaração em uma Spec

``` yaml
resource: project_financial_summary
classification: restricted
category: financial-data

permissions:
  read: financial.view
  edit: financial.edit
  export: report.export

ai:
  allowed: conditional
  requires:
    - financial.view
    - tenant_ai_policy_allow_financial

audit:
  edit: true
  export: true
```

O formato final será definido pelo `SPEC-TEMPLATE`.

------------------------------------------------------------------------

# 51. Pontos em aberto

Serão definidos posteriormente:

1.  períodos de retenção;
2.  requisitos específicos de LGPD por fluxo;
3.  política de anonimização;
4.  política de pseudonimização;
5.  classificação por custom field;
6.  provedores de IA permitidos por classe;
7.  política de data residency;
8.  política de export watermark;
9.  regras de download de documentos;
10. política de DLP;
11. classificação automática;
12. revisão periódica de classificação;
13. tratamento de dados apagados em backups;
14. política de analytics;
15. política de suporte com dados reais.

------------------------------------------------------------------------

# 52. Relação com Permission Model

O fluxo conceitual é:

``` text
Resource
   ↓
Permission
   ↓
Scope
   ↓
Data Classification
   ↓
Data Policy
   ↓
Allowed Fields / Operations
```

Exemplo:

``` text
Project access
      ↓
Budget field
      ↓
Restricted / financial-data
      ↓
financial.view?
      ↓
ALLOW / DENY
```

------------------------------------------------------------------------

# 53. Relação com PMO Copilot

``` text
User Question
      ↓
Authorization Context
      ↓
Candidate Data
      ↓
Classification Filter
      ↓
Tenant AI Policy
      ↓
Minimum Necessary Context
      ↓
Model
      ↓
Output Validation
      ↓
Response
```

O modelo de IA não deve ser utilizado como mecanismo de autorização.

------------------------------------------------------------------------

# 54. Referências

-   `/docs/00-foundation/README.md`
-   `/docs/00-foundation/glossary.md`
-   `/docs/00-foundation/domain-model.md`
-   `/docs/00-foundation/business-rules.md`
-   `/docs/00-foundation/permission-model.md`
-   `/docs/01-product/PDD.md`
-   `/docs/06-data/`
-   `/docs/07-security/`
-   `/docs/09-ai/`

------------------------------------------------------------------------

# 55. Status

**Documento:** Data Classification\
**Status:** Under Review\
**Responsabilidade:** estabelecer os níveis, categorias e princípios de
proteção e tratamento dos dados do PMO Control.

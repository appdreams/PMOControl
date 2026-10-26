# ADR-001 --- Modular Monolith

**Status:** Accepted\
**Date:** 2026-10-25\
**Decision:** Adotar monólito modular como arquitetura inicial do PMO
Control.

------------------------------------------------------------------------

## 1. Context

O PMO Control é um sistema SaaS multi-tenant de governança de projetos
de TI, com domínio composto por módulos como:

-   Portfolios;
-   Projects;
-   Milestones;
-   Deliverables;
-   Risks;
-   Issues;
-   Actions;
-   Decisions;
-   Dependencies;
-   Status Update;
-   RAG Engine;
-   Snapshots;
-   Dashboards;
-   Financial;
-   Resources;
-   Documents;
-   Reports;
-   PMO Copilot;
-   Notifications;
-   Audit;
-   Integrations.

O sistema possui regras transacionais importantes, especialmente no
fluxo:

``` text
Operational State
      ↓
Status Publication
      ↓
RAG
      ↓
Snapshot
      ↓
Audit
      ↓
Dashboard / Portfolio / Time Machine
```

Durante o MVP, o domínio continuará evoluindo e seus boundaries serão
refinados conforme as Specs e a implementação.

A arquitetura precisa favorecer velocidade de desenvolvimento,
consistência transacional, segurança multi-tenant e baixo custo
operacional sem impedir evolução futura.

------------------------------------------------------------------------

## 2. Problem

É necessário decidir como organizar e implantar os módulos do backend da
aplicação.

As principais alternativas são:

1.  monólito tradicional sem boundaries fortes;
2.  monólito modular;
3.  microservices desde o início;
4.  arquitetura híbrida com múltiplos serviços independentes desde o
    MVP.

------------------------------------------------------------------------

## 3. Decision Drivers

Os principais drivers são:

-   velocidade para construir o MVP;
-   equipe inicialmente pequena;
-   domínio ainda em consolidação;
-   necessidade de transações fortes;
-   isolamento multi-tenant;
-   baixa complexidade operacional;
-   facilidade de testes;
-   deploy simples;
-   observabilidade centralizada;
-   possibilidade de evolução futura;
-   redução de distributed systems failure modes.

------------------------------------------------------------------------

## 4. Decision

O PMO Control será implementado inicialmente como um:

``` text
MODULAR MONOLITH
```

com módulos internos explicitamente separados por responsabilidade de
domínio.

Conceitualmente:

``` text
PMO Control Application
│
├── Authentication
├── Tenants
├── Authorization
├── Portfolios
├── Projects
├── Milestones
├── Deliverables
├── Risks
├── Issues
├── Actions
├── Decisions
├── Dependencies
├── Status
├── RAG
├── Snapshots
├── Financial
├── Resources
├── Documents
├── Reports
├── Notifications
├── Audit
├── AI
└── Integrations
```

Esses módulos compartilham inicialmente o mesmo deployment unit, mas
devem preservar boundaries lógicos.

------------------------------------------------------------------------

## 5. O que "modular" significa

Monólito modular não significa colocar todo o código em uma única camada
sem separação.

Cada módulo deve possuir responsabilidade clara.

Estrutura conceitual:

``` text
Module
├── application
├── domain
├── infrastructure
└── interfaces/contracts
```

A organização física exata poderá ser refinada durante implementação.

------------------------------------------------------------------------

## 6. Dependency Direction

Regra geral:

``` text
Presentation
      ↓
Application
      ↓
Domain
```

Infrastructure implementa contratos necessários pelas camadas internas.

O domínio não deve depender diretamente de SDKs externos.

------------------------------------------------------------------------

## 7. Module Ownership

Cada entidade principal deve possuir módulo owner.

Exemplo:

``` text
Risk
→ Risks module

Action
→ Actions module

Snapshot
→ Snapshots module
```

Módulos de composição, como Project Control Center e My Day,
consultam/orquestram dados sem assumir ownership das entidades.

------------------------------------------------------------------------

## 8. Cross-module Communication

Comunicação entre módulos deve preferir:

-   application services;
-   explicit contracts;
-   domain/application events quando úteis;
-   orchestrated use cases.

Evitar acesso arbitrário aos detalhes internos de outro módulo.

------------------------------------------------------------------------

## 9. Shared Database

No MVP, os módulos utilizarão o mesmo PostgreSQL.

``` text
Application Modules
       ↓
Shared PostgreSQL
```

Isso não significa ausência de ownership lógico dos dados.

------------------------------------------------------------------------

## 10. Transaction Boundary

Uma vantagem importante é permitir transações locais consistentes.

Exemplo:

``` text
Publish Status
     ↓
Validate
     ↓
Calculate RAG
     ↓
Create Publication
     ↓
Create Snapshot
     ↓
Create Audit Event
     ↓
COMMIT
```

Sem necessidade de transação distribuída entre serviços.

------------------------------------------------------------------------

## 11. Asynchronous Work

Monólito modular não significa processamento exclusivamente síncrono.

Inngest será utilizado para atividades como:

-   notifications;
-   integrations;
-   scheduled workflows;
-   reports;
-   AI processing;
-   retries.

``` text
Local Transaction
      ↓
Commit
      ↓
Async Workflow
```

------------------------------------------------------------------------

## 12. Deployment

O sistema terá inicialmente um deployment principal:

``` text
GitHub
   ↓
CI
   ↓
Vercel
   ↓
PMO Control Application
```

Os módulos não possuem deploy independente no MVP.

------------------------------------------------------------------------

## 13. Option A --- Traditional Monolith

### Descrição

Uma aplicação única sem boundaries internos fortes.

### Vantagens

-   extremamente simples inicialmente;
-   baixo overhead estrutural.

### Desvantagens

-   alto acoplamento;
-   domínio se degrada rapidamente;
-   ownership indefinido;
-   difícil extração futura;
-   risco de "big ball of mud".

### Resultado

**Rejected.**

------------------------------------------------------------------------

## 14. Option B --- Modular Monolith

### Vantagens

-   simplicidade operacional;
-   boundaries explícitos;
-   transações locais;
-   deploy único;
-   testes mais simples;
-   menor latência interna;
-   evolução rápida;
-   futura extração seletiva possível.

### Desvantagens

-   boundaries dependem de disciplina;
-   um deploy pode afetar toda aplicação;
-   escala independente por módulo é limitada;
-   banco compartilhado exige regras claras de ownership.

### Resultado

**Accepted.**

------------------------------------------------------------------------

## 15. Option C --- Microservices

### Vantagens

-   deployment independente;
-   escala independente;
-   ownership por serviço;
-   isolamento de falhas potencial.

### Desvantagens

-   network calls;
-   distributed tracing;
-   service discovery;
-   versionamento de contratos;
-   eventual consistency;
-   retries;
-   duplicate delivery;
-   distributed transactions;
-   observabilidade mais complexa;
-   maior custo operacional.

### Resultado

**Rejected for MVP.**

------------------------------------------------------------------------

## 16. Option D --- Hybrid Services from Day One

Criar alguns módulos como serviços independentes desde o início.

### Problema

Ainda não existem evidências suficientes para identificar quais módulos
realmente precisam de:

-   escala independente;
-   tecnologia própria;
-   lifecycle próprio;
-   ownership de equipe separado.

### Resultado

**Rejected for MVP.**

------------------------------------------------------------------------

## 17. Rationale

A decisão maximiza:

``` text
Development Speed
+
Transactional Simplicity
+
Operational Simplicity
+
Domain Modularity
```

sem introduzir prematuramente:

``` text
Distributed Systems Complexity
```

------------------------------------------------------------------------

## 18. Consequences --- Positive

### 18.1 Deploy simples

Uma aplicação principal.

### 18.2 Transações fortes

Casos críticos podem usar PostgreSQL transactions.

### 18.3 Debugging

Fluxos atravessando módulos permanecem rastreáveis no mesmo runtime.

### 18.4 Desenvolvimento local

Menos infraestrutura necessária.

### 18.5 Testes

Integration tests podem validar múltiplos módulos sem orquestrar
diversos serviços.

### 18.6 Menor custo

Menos serviços e infraestrutura.

### 18.7 Refactoring

Boundaries ainda podem evoluir enquanto o domínio amadurece.

------------------------------------------------------------------------

## 19. Consequences --- Negative

### 19.1 Deployment coupling

Mudança em um módulo exige deploy da aplicação.

### 19.2 Scaling coupling

Não é possível escalar cada módulo de forma completamente independente.

### 19.3 Discipline required

Sem enforcement arquitetural, módulos podem se acoplar.

### 19.4 Shared database risk

Developers podem criar joins/dependências inadequadas entre módulos.

------------------------------------------------------------------------

## 20. Mitigations

Para evitar degradação:

-   module ownership explícito;
-   dependency rules;
-   code review;
-   architecture tests quando úteis;
-   interfaces/contracts;
-   documentação;
-   Specs;
-   ADRs;
-   evitar acesso arbitrário entre módulos.

------------------------------------------------------------------------

## 21. Security Implications

Monólito modular não reduz requisitos de segurança.

Toda operação continua sujeita a:

``` text
Authentication
+
Tenant
+
Role
+
Scope
+
Permission
+
Data Policy
+
Workflow Rule
```

------------------------------------------------------------------------

## 22. Tenant Isolation

Mesmo com banco compartilhado:

``` text
Tenant A
≠
Tenant B
```

O isolamento será implementado por aplicação + banco +
RLS/constraints/testes conforme ADRs específicos.

------------------------------------------------------------------------

## 23. Failure Isolation

Uma falha severa no runtime pode afetar múltiplos módulos.

Mitigações:

-   error boundaries apropriados;
-   async jobs;
-   timeouts;
-   circuit breakers onde necessários;
-   observabilidade;
-   graceful degradation.

------------------------------------------------------------------------

## 24. AI Isolation

PMO Copilot permanece módulo/capability separada.

Falha do provider de IA não deve indisponibilizar o core.

``` text
AI Failure
≠
PMO Control Failure
```

------------------------------------------------------------------------

## 25. Integration Isolation

Integrações externas serão isoladas por adapters e workflows
assíncronos.

Falha em Jira, Azure DevOps ou outro provider não deve quebrar
transações centrais.

------------------------------------------------------------------------

## 26. Operational Implications

A operação inicial exige principalmente:

-   aplicação Vercel;
-   Supabase;
-   Inngest;
-   SMTP;
-   providers externos.

Não exige cluster de microservices.

------------------------------------------------------------------------

## 27. Observability

Logs e tracing devem preservar:

``` text
module
operation
tenant_id
user_id
request_id
correlation_id
```

permitindo identificar o módulo responsável mesmo em runtime único.

------------------------------------------------------------------------

## 28. Testing Implications

A estratégia deve incluir:

-   unit tests por módulo;
-   domain tests;
-   integration tests;
-   authorization tests;
-   tenant isolation tests;
-   end-to-end tests.

------------------------------------------------------------------------

## 29. Architecture Fitness

A arquitetura continua saudável se:

-   módulos mantêm ownership;
-   dependências são direcionais;
-   domínio não depende de SDK externo;
-   mudanças locais não exigem conhecimento de todo sistema;
-   transações críticas permanecem compreensíveis;
-   boundaries continuam extraíveis.

------------------------------------------------------------------------

## 30. Extraction Readiness

Um módulo só deve ser considerado candidato a serviço independente
quando possuir:

-   boundary estável;
-   responsabilidade clara;
-   API/contract definido;
-   carga diferenciada;
-   necessidade operacional real.

------------------------------------------------------------------------

## 31. Revisit Triggers

Reavaliar esta decisão se ocorrer um ou mais:

1.  módulo exige escala muito diferente;
2.  workloads causam interferência significativa;
3.  equipes independentes precisam de deployment independente;
4.  compliance exige isolamento de runtime;
5.  tecnologia específica é necessária para determinado workload;
6.  release coupling torna-se gargalo mensurável;
7.  disponibilidade exige failure isolation superior;
8.  custos demonstram benefício concreto da separação.

------------------------------------------------------------------------

## 32. O que não é trigger

Não migrar para microservices apenas porque:

-   a empresa cresceu;
-   existem muitos módulos;
-   microservices parecem mais "enterprise";
-   concorrentes usam;
-   Kubernetes está disponível.

É necessária evidência.

------------------------------------------------------------------------

## 33. Migration Path

Se um módulo precisar ser extraído:

``` text
Identify Stable Boundary
      ↓
Define Explicit Contract
      ↓
Remove Direct Internal Dependencies
      ↓
Separate Data Ownership
      ↓
Introduce Remote Boundary
      ↓
Migrate Traffic
      ↓
Observe
```

------------------------------------------------------------------------

## 34. Data Extraction

A parte mais difícil tende a ser ownership de dados.

Não extrair serviço mantendo acoplamento irrestrito ao mesmo schema como
solução permanente.

------------------------------------------------------------------------

## 35. Relationship with ADR-012

Este ADR é complementado por:

``` text
ADR-012
No Premature Distributed Infrastructure
```

ADR-001 escolhe monólito modular.

ADR-012 formaliza que infraestrutura distribuída só entra mediante
necessidade comprovada.

------------------------------------------------------------------------

## 36. References

-   `/docs/02-architecture/README.md`
-   `/docs/02-architecture/system-architecture.md`
-   `/docs/02-architecture/data-architecture.md`
-   `/docs/02-architecture/deployment-architecture.md`
-   `/docs/03-adrs/README.md`

------------------------------------------------------------------------

## 37. Decision Summary

``` text
Decision:
Use a modular monolith for the PMO Control MVP.

Why:
It provides the best balance between domain modularity,
transactional consistency, development speed,
operational simplicity and future evolution.

Revisit:
Only when measurable technical or organizational evidence
justifies independent services.
```

------------------------------------------------------------------------

**ADR:** ADR-001\
**Status:** Accepted

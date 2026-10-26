# ADR-002 --- Next.js + TypeScript

**Status:** Accepted\
**Date:** 2026-10-25\
**Decision:** Adotar Next.js + TypeScript como stack principal da
aplicação PMO Control no MVP.

------------------------------------------------------------------------

## 1. Context

O PMO Control será inicialmente implementado como um monólito modular,
conforme ADR-001.

A aplicação precisa oferecer:

-   interface web desktop-first;
-   dashboards operacionais e executivos;
-   autenticação;
-   APIs e operações server-side;
-   autorização contextual;
-   integração com PostgreSQL/Supabase;
-   workflows assíncronos;
-   integrações externas;
-   PMO Copilot;
-   geração de relatórios;
-   upload/download de documentos;
-   boa experiência de desenvolvimento;
-   deployment simplificado.

É necessário definir a stack principal da aplicação.

------------------------------------------------------------------------

## 2. Problem

A solução precisa equilibrar:

``` text
Frontend Productivity
+
Server-side Capabilities
+
Type Safety
+
Security
+
Deployment Simplicity
+
Ecosystem
+
Maintainability
```

sem exigir múltiplos runtimes e repositórios no início.

------------------------------------------------------------------------

## 3. Decision Drivers

Principais drivers:

-   produtividade;
-   TypeScript end-to-end;
-   React ecosystem;
-   suporte a server-side execution;
-   integração natural com Vercel;
-   maturidade do ecossistema;
-   disponibilidade de bibliotecas;
-   suporte a SSR/server components quando úteis;
-   API/server actions quando apropriadas;
-   facilidade de testes;
-   modularização;
-   contratação/manutenção futura.

------------------------------------------------------------------------

## 4. Decision

Adotar:

``` text
Next.js
+
TypeScript
```

como stack principal da aplicação web do PMO Control.

------------------------------------------------------------------------

## 5. Runtime Role

Next.js será responsável por:

``` text
Presentation
+
Server-side Application Entry Points
+
API / Request Handling
+
Authentication Orchestration
+
Application Use Cases
+
Integration Entry Points
```

respeitando os boundaries definidos na System Architecture.

------------------------------------------------------------------------

## 6. TypeScript

TypeScript será utilizado nas camadas aplicáveis para:

-   contracts;
-   DTOs;
-   domain types;
-   validation integration;
-   application services;
-   API contracts;
-   UI;
-   tests;
-   provider adapters.

------------------------------------------------------------------------

## 7. Type Safety Is Not Runtime Validation

TypeScript não substitui validação de runtime.

``` text
TypeScript Type
≠
Trusted External Input
```

Dados vindos de:

-   browser;
-   API;
-   webhook;
-   import;
-   provider;
-   AI;

devem ser validados em runtime.

------------------------------------------------------------------------

## 8. Application Boundary

O framework não deve se tornar o domínio.

Preferência:

``` text
Next.js Route / Action
        ↓
Application Use Case
        ↓
Domain
        ↓
Infrastructure
```

e não:

``` text
Route
→ SQL + business rules + provider SDK
```

------------------------------------------------------------------------

## 9. Server Components

Server Components podem ser utilizados quando trouxerem benefício real
para:

-   data fetching server-side;
-   redução de JavaScript cliente;
-   composição de páginas;
-   proteção de dados server-side.

Não devem substituir boundaries de aplicação/autorização.

------------------------------------------------------------------------

## 10. Client Components

Client Components serão usados quando necessários para:

-   interatividade;
-   forms;
-   charts;
-   drag-and-drop;
-   rich dashboards;
-   local UI state.

Não devem receber secrets nem assumir autorização.

------------------------------------------------------------------------

## 11. Server Actions

Podem ser usadas quando adequadas.

Toda Server Action sensível deve executar:

``` text
Authenticate
   ↓
Resolve Tenant
   ↓
Authorize
   ↓
Validate
   ↓
Execute Use Case
```

A existência de uma Server Action não torna a operação segura
automaticamente.

------------------------------------------------------------------------

## 12. API Routes

Serão usadas quando fizerem sentido para:

-   webhooks;
-   integrations;
-   external/public API futura;
-   callbacks;
-   endpoints que exigem contrato HTTP explícito.

------------------------------------------------------------------------

## 13. UI Architecture

A interface deve manter separação entre:

-   design system;
-   shared components;
-   feature components;
-   pages/routes;
-   application/domain contracts.

Evitar componentes gigantes contendo regras de negócio.

------------------------------------------------------------------------

## 14. React Ecosystem

React oferece ecossistema adequado para:

-   dashboards;
-   tables;
-   charts;
-   forms;
-   accessible components;
-   rich interactions.

Bibliotecas devem ser selecionadas por necessidade, não adicionadas
indiscriminadamente.

------------------------------------------------------------------------

## 15. Option A --- Next.js + TypeScript

### Vantagens

-   frontend e server capabilities no mesmo ecossistema;
-   TypeScript end-to-end;
-   React;
-   excelente integração com Vercel;
-   produtividade;
-   ampla comunidade;
-   SSR/server rendering;
-   routing integrado;
-   boa experiência de desenvolvimento.

### Desvantagens

-   evolução rápida do framework;
-   risco de acoplamento excessivo a APIs específicas;
-   diferenças entre runtimes;
-   complexidade se Server/Client boundaries forem mal definidos.

### Resultado

**Accepted.**

------------------------------------------------------------------------

## 16. Option B --- React SPA + Separate Backend

Exemplo:

``` text
React SPA
+
Node/NestJS API
```

### Vantagens

-   separação frontend/backend explícita;
-   backend independente;
-   deploy separado.

### Desvantagens

-   dois deployment units;
-   contratos duplicados;
-   mais configuração;
-   maior complexidade operacional;
-   benefício insuficiente para o MVP.

### Resultado

**Rejected for MVP.**

------------------------------------------------------------------------

## 17. Option C --- NestJS Backend + Next.js Frontend

Arquitetura robusta, mas adicionaria:

-   outro runtime/deployment;
-   comunicação HTTP interna;
-   autenticação entre componentes;
-   observabilidade distribuída;
-   maior custo operacional.

Pode ser reavaliada se backend independente se tornar necessário.

### Resultado

**Rejected for MVP.**

------------------------------------------------------------------------

## 18. Option D --- Other Full-stack Framework

Outras opções são tecnicamente viáveis, mas não apresentam vantagem
suficiente frente a Next.js para os requisitos e stack escolhidos.

### Resultado

**Rejected.**

------------------------------------------------------------------------

## 19. Consequences --- Positive

### 19.1 Unified Language

``` text
TypeScript
```

em grande parte da aplicação.

### 19.2 Shared Contracts

Possibilidade de compartilhar tipos/contratos onde arquiteturalmente
apropriado.

### 19.3 Development Speed

Menor necessidade de coordenar stacks separadas.

### 19.4 Deployment

Integração direta com Vercel.

### 19.5 Ecosystem

Amplo conjunto de bibliotecas e ferramentas.

------------------------------------------------------------------------

## 20. Consequences --- Negative

### 20.1 Framework Coupling

Código pode ficar excessivamente dependente do Next.js.

### 20.2 Server/Client Confusion

Boundaries incorretos podem:

-   vazar dados;
-   aumentar bundle;
-   criar problemas de segurança.

### 20.3 Rapid Framework Evolution

Upgrades precisam ser controlados e testados.

### 20.4 Runtime Constraints

Nem toda workload longa é adequada ao request lifecycle.

------------------------------------------------------------------------

## 21. Mitigations

-   manter domain/application independentes do framework quando
    razoável;
-   isolar adapters;
-   usar Inngest para workloads assíncronos;
-   evitar business rules dentro de UI/routes;
-   runtime validation;
-   automated tests;
-   dependency/version management.

------------------------------------------------------------------------

## 22. Security Implications

Código server-side deve ser o boundary para:

-   authorization;
-   privileged database operations;
-   BYOK;
-   integration credentials;
-   confidential data;
-   exports;
-   consequential AI actions.

------------------------------------------------------------------------

## 23. Client Security

O browser nunca recebe:

-   service-role keys;
-   BYOK;
-   SMTP credentials;
-   integration secrets;
-   unrestricted database credentials.

------------------------------------------------------------------------

## 24. Authorization

Toda operação sensível segue:

``` text
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

independentemente de ter sido chamada por UI, Server Action ou API.

------------------------------------------------------------------------

## 25. Error Handling

Erros externos devem ser seguros.

Não retornar ao cliente:

-   stack traces;
-   SQL;
-   secrets;
-   provider credentials;
-   internal implementation details desnecessários.

------------------------------------------------------------------------

## 26. Performance Implications

Next.js permite estratégias server/client diferentes.

A otimização deve ser baseada em medição.

Evitar premature caching ou rendering complexity.

------------------------------------------------------------------------

## 27. Background Work

Workloads como:

-   long reports;
-   integration sync;
-   notifications;
-   scheduled jobs;
-   long AI tasks;

devem ser encaminhadas ao mecanismo assíncrono quando apropriado.

------------------------------------------------------------------------

## 28. Testing Implications

A stack deve suportar:

-   unit tests;
-   domain tests;
-   integration tests;
-   API tests;
-   component tests;
-   E2E tests;
-   authorization tests.

------------------------------------------------------------------------

## 29. Deployment Implications

Fluxo:

``` text
GitHub
  ↓
CI
  ↓
Vercel Preview
  ↓
Validation
  ↓
Production
```

conforme Deployment Architecture.

------------------------------------------------------------------------

## 30. Dependency Management

Usar lockfile e versões controladas.

Atualizações relevantes de:

-   Next.js;
-   React;
-   TypeScript;

devem passar por CI e regressão.

------------------------------------------------------------------------

## 31. Framework Upgrade Strategy

Evitar upgrades automáticos de major version em Production.

Fluxo:

``` text
Review
 ↓
Upgrade Branch
 ↓
Tests
 ↓
Preview
 ↓
Validation
 ↓
Merge
```

------------------------------------------------------------------------

## 32. Architecture Boundary

Next.js é um delivery/runtime framework.

Não é o domínio do PMO Control.

Regra:

``` text
Business Rule
should survive
Framework Replacement
```

na medida razoável.

------------------------------------------------------------------------

## 33. Data Access

Evitar queries arbitrárias diretamente em componentes de UI quando isso
contornar:

-   application services;
-   authorization;
-   domain rules.

Read models simples podem ser otimizados, mas continuam tenant-safe.

------------------------------------------------------------------------

## 34. Validation

Recomenda-se schema validation consistente para entradas externas.

A biblioteca concreta poderá ser definida na implementação/Spec técnica.

------------------------------------------------------------------------

## 35. API Contract

APIs externas futuras devem possuir contratos explícitos e versionamento
apropriado.

Não expor automaticamente Server Actions como API pública.

------------------------------------------------------------------------

## 36. Observability

Requests devem permitir correlação com:

``` text
request_id
correlation_id
tenant_id
user_id
module
operation
release
```

quando aplicável e seguro.

------------------------------------------------------------------------

## 37. Revisit Triggers

Reavaliar se:

1.  backend precisar de lifecycle independente;
2.  workloads principais forem incompatíveis com runtime;
3.  múltiplos clientes além da web exigirem backend independente;
4.  escala exigir separação;
5.  compliance exigir runtime diferente;
6.  limitações de plataforma se tornarem bloqueadoras;
7.  custo demonstrar alternativa superior.

------------------------------------------------------------------------

## 38. Non-Triggers

Não trocar a stack apenas porque:

-   surgiu framework novo;
-   benchmark sintético é melhor;
-   outra tecnologia está em tendência;
-   microservices foram adotados por outra empresa.

------------------------------------------------------------------------

## 39. Migration Path

Se backend independente se tornar necessário:

``` text
Stabilize Application Contracts
       ↓
Extract Use Cases / APIs
       ↓
Introduce Dedicated Backend
       ↓
Move Selected Workloads
       ↓
Keep Web Frontend on Next.js if beneficial
```

------------------------------------------------------------------------

## 40. Relationship with ADR-001

``` text
ADR-001
Modular Monolith

ADR-002
Next.js + TypeScript implementation stack
```

ADR-001 define forma arquitetural.

ADR-002 define a principal stack de aplicação.

------------------------------------------------------------------------

## 41. Relationship with ADR-011

``` text
ADR-002
Next.js + TypeScript

        ↓

ADR-011
Vercel Deployment
```

A escolha de Vercel complementa, mas não é condição lógica obrigatória
para usar Next.js.

------------------------------------------------------------------------

## 42. References

-   `/docs/02-architecture/README.md`
-   `/docs/02-architecture/system-architecture.md`
-   `/docs/02-architecture/security-architecture.md`
-   `/docs/02-architecture/deployment-architecture.md`
-   `/docs/03-adrs/001-modular-monolith.md`
-   `/docs/03-adrs/README.md`

------------------------------------------------------------------------

## 43. Decision Summary

``` text
Decision:
Use Next.js + TypeScript as the main application stack.

Why:
It provides a strong balance of web productivity,
server-side capabilities, type safety,
ecosystem maturity and deployment simplicity.

Constraint:
Business rules and security boundaries must not
become unnecessarily coupled to the framework.

Revisit:
Only when measurable runtime, organizational,
compliance or scaling requirements justify change.
```

------------------------------------------------------------------------

**ADR:** ADR-002\
**Status:** Accepted

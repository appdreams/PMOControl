# PMO Control --- Security Architecture

**Documento:** `security-architecture.md`\
**Camada:** Architecture\
**Status:** Approved\
**Tipo:** Arquitetura de segurança, identidade, autorização, isolamento
e proteção de dados

------------------------------------------------------------------------

## 1. Objetivo

Este documento define a arquitetura de segurança do PMO Control.

O objetivo é estabelecer controles e invariantes para proteger:

-   identidade;
-   sessões;
-   Tenants;
-   autorização;
-   dados de projetos;
-   informações financeiras;
-   documentos confidenciais;
-   histórico publicado;
-   Audit Log;
-   integrações;
-   credenciais BYOK;
-   recursos de IA;
-   exports;
-   operações administrativas.

A segurança deve existir desde o MVP e não como camada adicionada
posteriormente.

------------------------------------------------------------------------

# 2. Princípio central

``` text
Security by Default
+
Least Privilege
+
Deny by Default
+
Defense in Depth
+
Auditability
```

Nenhuma funcionalidade é considerada concluída apenas porque a UI
esconde uma ação não autorizada.

------------------------------------------------------------------------

# 3. Modelo de confiança

O PMO Control opera assumindo que:

-   dados recebidos do browser não são confiáveis;
-   IDs fornecidos pelo cliente não comprovam acesso;
-   Role informada pelo frontend não é confiável;
-   integrações externas podem falhar ou enviar payload inválido;
-   outputs de LLM não são fatos automaticamente;
-   jobs internos também precisam de contexto e limites;
-   administradores não devem possuir acesso implícito irrestrito.

------------------------------------------------------------------------

# 4. Trust boundaries

Principais fronteiras:

``` text
User / Browser
      │
      ▼
Application Boundary
      │
      ├── Database Boundary
      ├── Storage Boundary
      ├── Background Job Boundary
      ├── AI Provider Boundary
      ├── SMTP Boundary
      └── External Integration Boundary
```

Toda travessia exige controles adequados ao risco.

------------------------------------------------------------------------

# 5. Security domains

A arquitetura de segurança é dividida em:

1.  Authentication;
2.  Session Security;
3.  Multi-tenancy;
4.  Authorization;
5.  Data Security;
6.  Storage Security;
7.  Audit;
8.  API Security;
9.  AI Security;
10. Integration Security;
11. Administrative Security;
12. Application Security;
13. Operational Security.

------------------------------------------------------------------------

# 6. Authentication

Autenticação responde:

> **Quem é o usuário?**

No MVP, Supabase Auth é a solução inicialmente prevista.

A decisão final deve considerar:

-   login;
-   invitation;
-   recovery;
-   session management;
-   revocation;
-   provider capabilities;
-   future MFA/SSO evolution.

------------------------------------------------------------------------

# 7. Authentication ≠ Authorization

Um usuário autenticado não possui automaticamente acesso a dados.

``` text
Authenticated
      ↓
Membership
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
```

------------------------------------------------------------------------

# 8. Session security

Sessões devem possuir:

-   expiração;
-   renovação segura quando aplicável;
-   revogação;
-   proteção contra uso indevido;
-   secure cookie/token handling conforme arquitetura;
-   invalidação após eventos relevantes quando necessário.

------------------------------------------------------------------------

# 9. Credential handling

Passwords não são armazenadas pela aplicação em plaintext.

A aplicação não deve:

-   registrar password em log;
-   enviar password para analytics;
-   incluir password em Audit;
-   retornar credential secrets.

------------------------------------------------------------------------

# 10. Future MFA

MFA não precisa bloquear o primeiro slice do MVP se o mecanismo inicial
não exigir, mas a arquitetura não deve impedir sua adoção.

Pode se tornar requisito para:

-   Tenant Admin;
-   Platform Admin;
-   privileged operations;
-   enterprise plans.

------------------------------------------------------------------------

# 11. Future SSO

SSO/SAML/OIDC enterprise pode entrar posteriormente.

Deve integrar identidade sem eliminar o modelo interno de
Membership/Role/Scope.

------------------------------------------------------------------------

# 12. Multi-tenancy security

Tenant é boundary de segurança.

Regra:

``` text
User authenticated
≠
Access to every Tenant
```

É necessária Membership válida ou mecanismo administrativo
explicitamente autorizado.

------------------------------------------------------------------------

# 13. Tenant context

O servidor deve resolver Tenant context de forma segura.

Não confiar apenas em:

``` text
tenant_id
```

enviado pelo cliente.

O contexto deve ser validado contra Membership/autorização.

------------------------------------------------------------------------

# 14. Tenant isolation

Defesa em profundidade:

``` text
Server-side Authorization
       +
Tenant-scoped Queries
       +
Database Constraints
       +
RLS where appropriate
       +
Storage Policies
       +
Automated Cross-tenant Tests
```

------------------------------------------------------------------------

# 15. Cross-tenant access

Tentativas de acesso cross-tenant devem resultar em:

``` text
Denied
```

sem revelar desnecessariamente se o recurso existe.

Isso reduz risco de enumeração.

------------------------------------------------------------------------

# 16. BOLA / IDOR

O sistema deve tratar explicitamente Broken Object Level Authorization /
IDOR.

Exemplo inseguro:

``` text
GET /projects/{id}
```

seguido apenas de busca pelo ID.

Exemplo esperado conceitualmente:

``` text
Resolve Auth Context
      ↓
Resolve Tenant
      ↓
Authorize Scope
      ↓
Fetch Authorized Project
```

------------------------------------------------------------------------

# 17. Authorization model

Modelo efetivo:

``` text
Effective Access =
Tenant
+ Role
+ Scope
+ Permission
+ Data Policy
+ Workflow Rule
```

------------------------------------------------------------------------

# 18. Roles padrão

``` text
Platform Admin
Tenant Admin
PMO Admin
PMO
Project Manager
Contributor
Executive
Viewer
```

Role é apenas uma dimensão do acesso.

------------------------------------------------------------------------

# 19. Scope

Hierarquia:

``` text
Tenant
  ↓
Portfolio
  ↓
Project
  ↓
Resource / Assigned Item
```

O mesmo usuário pode possuir permissões distintas em scopes diferentes.

------------------------------------------------------------------------

# 20. Permissions sensíveis

Incluem:

``` text
financial.view
financial.edit
resources.view
resources.edit
documents.confidential.view
status.update.publish
baseline.change
projects.{projectId}.rag-evaluations.override
decision.approve
report.export
```

Essas permissões devem ser verificadas explicitamente.

------------------------------------------------------------------------

# 21. Data Policy

Data Policy restringe dados dentro de uma capability autorizada.

Exemplo:

um usuário pode acessar Project, mas não:

``` text
Confidential Financial Data
```

ou:

``` text
Confidential Documents
```

sem permissão adicional.

------------------------------------------------------------------------

# 22. Workflow Rule

Autorização também depende do estado.

Exemplo:

um usuário pode editar Status em Draft, mas não após Published.

``` text
Permission
+
Current State
=
Allowed Operation
```

------------------------------------------------------------------------

# 23. Segregation of Duties

Configurações podem exigir:

``` text
Status preparer may equal publisher in MVP; Project Manager needs explicit status.update.publish
Baseline requester != approver
Decision requester != decision maker
Contributor != own executive approver
```

O nível exato pode variar por Tenant.

------------------------------------------------------------------------

# 24. Server-side enforcement

Toda autorização relevante ocorre no servidor.

Frontend pode ocultar controles para UX, mas isso não é controle de
segurança.

------------------------------------------------------------------------

# 25. Authorization service

Recomenda-se boundary central para avaliação de acesso.

Conceitualmente:

``` text
authorize(
  actor,
  tenant,
  action,
  resource,
  context
)
```

Isso reduz regras inconsistentes espalhadas.

------------------------------------------------------------------------

# 26. Deny by default

Se uma autorização não puder ser determinada com segurança:

``` text
DENY
```

Não assumir permissão por ausência de regra.

------------------------------------------------------------------------

# 27. Platform Admin

Platform Admin administra o SaaS.

Não possui automaticamente acesso a dados de negócio de Tenants.

Acesso excepcional de suporte deve ser:

-   explícito;
-   temporário quando possível;
-   justificado;
-   autorizado;
-   auditado.

------------------------------------------------------------------------

# 28. Tenant Admin

Pode administrar:

-   Membership;
-   roles/scopes;
-   configurações;
-   integrações;
-   AI/BYOK;
-   políticas permitidas.

Não deve automaticamente contornar toda regra de negócio se isso não for
necessário.

------------------------------------------------------------------------

# 29. PMO Admin

Pode possuir operações sensíveis de governança, conforme Tenant.

Exemplos:

-   publish;
-   RAG override;
-   baseline governance;
-   portfolio administration.

------------------------------------------------------------------------

# 30. Executive

Predominantemente read-oriented.

Pode possuir:

``` text
decision.approve
```

para Decisions atribuídas/autorizadas.

Não recebe edição ampla de Project apenas por ser Executive.

------------------------------------------------------------------------

# 31. Contributor

Acesso mínimo necessário aos itens atribuídos.

Não pode automaticamente:

-   publicar Status;
-   alterar Baseline;
-   alterar RAG;
-   ver Financial;
-   acessar outros Projects.

------------------------------------------------------------------------

# 32. Resource ownership

Ser owner de uma Action não significa acesso irrestrito ao Project.

A Spec deve definir qual contexto mínimo é necessário para execução
segura.

------------------------------------------------------------------------

# 33. Data classification

Aplicar:

``` text
/docs/00-foundation/data-classification.md
```

A classificação influencia:

-   authorization;
-   logging;
-   export;
-   AI;
-   storage;
-   retention.

------------------------------------------------------------------------

# 34. Sensitive data

Exemplos:

-   financial data;
-   confidential documents;
-   personal data;
-   credentials;
-   AI provider secrets;
-   integration secrets;
-   privileged audit context.

------------------------------------------------------------------------

# 35. Secrets

Secrets incluem:

-   AI API keys;
-   integration tokens;
-   SMTP credentials;
-   service credentials.

Nunca:

-   armazenar em Git;
-   expor em client bundle;
-   registrar em log;
-   incluir em analytics;
-   retornar integralmente após cadastro.

------------------------------------------------------------------------

# 36. BYOK security

Fluxo conceitual:

``` text
Tenant Admin
    ↓
Authorized Configuration Endpoint
    ↓
Validate Provider Credential
    ↓
Secure Secret Storage
    ↓
Return Masked Metadata Only
```

------------------------------------------------------------------------

# 37. BYOK retrieval

A chave deve ser recuperada apenas no servidor e somente no momento
necessário.

O browser recebe, no máximo:

``` text
configured = true
provider = OpenAI
masked_hint = ...
```

quando seguro e necessário.

------------------------------------------------------------------------

# 38. BYOK rotation

A arquitetura deve permitir:

-   replace;
-   revoke;
-   disable;
-   audit change.

Não é necessário revelar a chave antiga para rotacioná-la.

------------------------------------------------------------------------

# 39. Encryption

Usar TLS para dados em trânsito.

Dados em repouso devem usar mecanismos da plataforma.

Secrets exigem proteção adequada além da simples exposição em tabela
comum.

------------------------------------------------------------------------

# 40. Database security

Controles:

-   least-privilege credentials;
-   tenant-aware queries;
-   constraints;
-   RLS onde apropriado;
-   migrations controladas;
-   restricted administrative access;
-   backups protegidos.

------------------------------------------------------------------------

# 41. RLS

Row Level Security é candidata a defesa importante no Supabase.

Ela deve complementar, não substituir:

``` text
Application Authorization
```

A estratégia final deve ser registrada em ADR.

------------------------------------------------------------------------

# 42. Service-role credentials

Credenciais com bypass de RLS ou privilégios elevados são altamente
sensíveis.

Devem:

-   existir apenas no servidor;
-   ter uso restrito;
-   não ser usadas como atalho para toda query;
-   nunca chegar ao browser.

------------------------------------------------------------------------

# 43. Storage security

Documentos/anexos devem utilizar:

-   tenant-aware paths ou metadata;
-   authorization;
-   controlled upload;
-   controlled download;
-   file type/size validation;
-   safe object naming;
-   access policies.

------------------------------------------------------------------------

# 44. Public buckets

Documentos de negócio não devem ser colocados em bucket público por
conveniência.

Downloads devem respeitar autorização.

------------------------------------------------------------------------

# 45. Signed URLs

Quando usadas:

-   curta validade adequada;
-   geração server-side autorizada;
-   escopo específico;
-   não armazenar como URL permanente de negócio.

------------------------------------------------------------------------

# 46. Upload security

Validar:

-   size;
-   content type;
-   extension;
-   authorization;
-   target entity;
-   classification.

Scanning de malware pode ser introduzido conforme risco/requisitos.

------------------------------------------------------------------------

# 47. Documents confidential

Acesso exige:

``` text
Project/Scope Access
+
documents.confidential.view
```

quando classificado como confidencial.

------------------------------------------------------------------------

# 48. API security

Toda API deve considerar:

-   authentication;
-   authorization;
-   validation;
-   tenant context;
-   rate/abuse considerations;
-   safe errors;
-   observability;
-   CSRF conforme mecanismo;
-   secure headers;
-   CORS quando aplicável.

------------------------------------------------------------------------

# 49. Input validation

Todo input externo é não confiável.

Validar:

-   type;
-   format;
-   length;
-   enum;
-   range;
-   relationships;
-   business rules.

------------------------------------------------------------------------

# 50. Output encoding

Dados exibidos devem ser tratados para prevenir injeções e XSS.

Não confiar em texto armazenado apenas porque veio de usuário
autenticado.

------------------------------------------------------------------------

# 51. SQL injection

Usar APIs parametrizadas/ORM/query builders seguros.

Nunca concatenar input não confiável em SQL.

------------------------------------------------------------------------

# 52. Mass assignment

Evitar padrões como:

``` text
update(resource, request.body)
```

sem allowlist.

Cada comando deve declarar campos alteráveis.

------------------------------------------------------------------------

# 53. CSRF

A estratégia depende do mecanismo de sessão e endpoints.

Operações mutáveis devem utilizar proteções apropriadas.

------------------------------------------------------------------------

# 54. CORS

Não liberar:

``` text
*
```

para APIs autenticadas sem justificativa.

Configurar origens conforme arquitetura.

------------------------------------------------------------------------

# 55. Security headers

Aplicar headers adequados, por exemplo:

-   CSP;
-   HSTS;
-   frame protections;
-   content type protections;
-   referrer policy.

Configuração exata será definida no deployment/security implementation.

------------------------------------------------------------------------

# 56. XSS

Fontes de risco:

-   Project descriptions;
-   comments;
-   AI output;
-   imported content;
-   external integration data.

Escapar/sanitizar conforme contexto.

------------------------------------------------------------------------

# 57. AI output security

Output de LLM deve ser tratado como conteúdo não confiável.

Não executar automaticamente:

-   HTML;
-   JavaScript;
-   SQL;
-   shell commands;
-   tool calls;

apenas porque o modelo produziu.

------------------------------------------------------------------------

# 58. Prompt injection

Conteúdo de:

-   Documents;
-   external integrations;
-   imported text;
-   user-entered descriptions;

pode conter instruções maliciosas.

O sistema deve distinguir:

``` text
Data
```

de:

``` text
Trusted System Instructions
```

------------------------------------------------------------------------

# 59. AI authorization boundary

Copilot herda exatamente o contexto autorizado.

Regra:

``` text
AI Accessible Data
≤
User Accessible Data
```

------------------------------------------------------------------------

# 60. AI context retrieval

Retrieval deve aplicar autorização antes de incluir dados no contexto.

Não recuperar tudo e pedir ao modelo para "ignorar" o que não deveria
ver.

------------------------------------------------------------------------

# 61. AI action security

Para ações consequenciais:

``` text
Suggestion
  ↓
Explicit User Confirmation
  ↓
Fresh Authorization Check
  ↓
Domain Command
  ↓
Audit
```

------------------------------------------------------------------------

# 62. AI provider privacy

Antes de enviar dados para provider:

-   verificar Tenant configuration;
-   classificação;
-   finalidade;
-   minimização;
-   provider policy;
-   eventual consentimento/configuração necessária.

------------------------------------------------------------------------

# 63. AI logging

Evitar logar prompts/respostas completos por padrão.

Quando necessário para diagnóstico:

-   redaction;
-   access restriction;
-   retention;
-   Tenant isolation.

------------------------------------------------------------------------

# 64. Integration security

Cada integração precisa:

-   credential protection;
-   least privilege;
-   endpoint validation;
-   source authority;
-   safe retry;
-   audit/config history;
-   Tenant binding.

------------------------------------------------------------------------

# 65. OAuth integrations

Quando aplicável:

-   state validation;
-   PKCE quando apropriado;
-   secure redirect URI;
-   token protection;
-   refresh token protection;
-   revocation.

------------------------------------------------------------------------

# 66. Webhook security

Webhooks devem utilizar, quando provider suportar:

-   signature verification;
-   timestamp/replay protection;
-   secret rotation;
-   idempotency;
-   schema validation.

------------------------------------------------------------------------

# 67. SSRF

Integrações configuráveis e URLs externas devem ser tratadas contra
Server-Side Request Forgery.

Não permitir que usuário faça o servidor acessar arbitrary internal
endpoints.

------------------------------------------------------------------------

# 68. Import security

Arquivos importados são não confiáveis.

Validar:

-   format;
-   size;
-   content;
-   schema;
-   row values;
-   formula injection em exports/imports quando relevante.

------------------------------------------------------------------------

# 69. CSV injection

Ao exportar dados para CSV/XLSX, campos iniciados por caracteres
interpretáveis como fórmula precisam de tratamento adequado.

------------------------------------------------------------------------

# 70. Export security

Fluxo:

``` text
Request
 ↓
Authorize report.export
 ↓
Resolve Scope
 ↓
Apply Data Policy
 ↓
Generate
 ↓
Audit if sensitive
 ↓
Secure Delivery
```

------------------------------------------------------------------------

# 71. Report security

Report não pode incluir dados que o solicitante não poderia consultar
nas telas/APIs equivalentes.

------------------------------------------------------------------------

# 72. Audit architecture

Eventos sensíveis incluem:

-   login/security;
-   access grants/revocations;
-   Role/Scope changes;
-   Baseline changes;
-   Financial changes;
-   RAG override;
-   Status publication;
-   Decisions;
-   sensitive export;
-   exceptional admin access;
-   BYOK/config changes.

------------------------------------------------------------------------

# 73. Audit integrity

Audit Events devem ser append-oriented e protegidos contra edição comum.

Acesso de leitura também pode ser restrito.

------------------------------------------------------------------------

# 74. Audit reason

Operações como:

``` text
RAG Override
Baseline Change
Exceptional Admin Access
```

podem exigir justificativa obrigatória.

------------------------------------------------------------------------

# 75. Audit correlation

Quando uma operação gera múltiplos eventos, usar correlation ID para
rastreabilidade.

------------------------------------------------------------------------

# 76. Logging security

Logs não devem conter:

-   passwords;
-   API keys;
-   access tokens;
-   refresh tokens;
-   raw secrets;
-   confidential document bodies por padrão.

------------------------------------------------------------------------

# 77. PII em logs

Minimizar PII.

Preferir IDs internos quando suficientes para troubleshooting.

------------------------------------------------------------------------

# 78. Error security

Erro externo deve ser seguro.

Evitar retornar:

-   stack trace;
-   SQL;
-   secrets;
-   filesystem paths;
-   provider credentials;
-   internal topology desnecessária.

------------------------------------------------------------------------

# 79. Enumeration

Endpoints de login/recovery/invitation devem evitar revelar
desnecessariamente existência de usuários quando isso aumentar risco.

------------------------------------------------------------------------

# 80. Rate limiting / abuse protection

Avaliar especialmente:

-   authentication;
-   password recovery;
-   invitations;
-   exports;
-   AI;
-   public endpoints;
-   webhooks.

A implementação pode variar conforme infraestrutura.

------------------------------------------------------------------------

# 81. Brute-force protection

Usar mecanismos disponíveis do provider/auth platform e controles
adicionais quando necessário.

------------------------------------------------------------------------

# 82. Administrative operations

Operações administrativas sensíveis devem possuir:

-   explicit permission;
-   audit;
-   reason quando aplicável;
-   re-authentication futura para operações críticas, se necessário.

------------------------------------------------------------------------

# 83. Support access

Modelo recomendado:

``` text
Support Request
      ↓
Authorized Exceptional Access
      ↓
Limited Scope / Time
      ↓
Audit
      ↓
Revocation
```

Não criar "master user" invisível com acesso universal permanente.

------------------------------------------------------------------------

# 84. Impersonation

Se futura funcionalidade de impersonation for criada:

-   banner visual explícito;
-   motivo;
-   autorização forte;
-   Audit;
-   início/fim registrados;
-   limites de operação.

Não faz parte do MVP inicial.

------------------------------------------------------------------------

# 85. Status publication security

Antes de publicar:

1.  autenticar;
2.  validar Tenant;
3.  verificar `status.update.publish`;
4.  verificar Scope;
5.  verificar workflow;
6.  validar dados;
7.  calcular RAG;
8.  validar override;
9.  persistir transacionalmente;
10. auditar.

------------------------------------------------------------------------

# 86. RAG override security

Exige:

-   `projects.{projectId}.rag-evaluations.override`;
-   Scope válido;
-   justification;
-   calculated RAG preservado;
-   effective RAG;
-   actor;
-   timestamp;
-   Audit.

------------------------------------------------------------------------

# 87. Baseline change security

Baseline não deve ser alterada por edição genérica.

Exige operação própria e, conforme configuração:

-   request;
-   reason;
-   Evidence;
-   approval;
-   Audit.

------------------------------------------------------------------------

# 88. Decision security

Somente ator autorizado pode:

-   approve;
-   reject;
-   defer.

A atribuição da Decision e o Scope devem ser considerados.

------------------------------------------------------------------------

# 89. Financial security

Financial possui autorização específica.

Um PM pode possuir acesso operacional ao Project e não ter:

``` text
financial.view
```

------------------------------------------------------------------------

# 90. Resource security

Dados de capacidade também podem exigir permissões específicas.

Não expor informações pessoais além do necessário.

------------------------------------------------------------------------

# 91. Snapshot security

Snapshot herda as políticas de acesso ao contexto publicado.

Histórico não se torna público por ser antigo.

------------------------------------------------------------------------

# 92. Time Machine security

A consulta histórica deve avaliar autorização atual e regras de
retenção/policy.

Não assumir que acesso passado continua válido para sempre.

------------------------------------------------------------------------

# 93. Notification security

Notificações devem evitar vazamento.

Exemplo:

um e-mail pode informar:

> "Você possui uma Decision pendente."

sem necessariamente incluir conteúdo confidencial completo.

------------------------------------------------------------------------

# 94. Deep links

Links em notifications não substituem autenticação/autorização.

Ao abrir:

``` text
Re-auth / Session
      ↓
Authorization
      ↓
Resource
```

------------------------------------------------------------------------

# 95. Background job security

Jobs internos devem possuir:

-   Tenant context;
-   job identity;
-   service authorization;
-   restricted credentials;
-   safe payloads.

------------------------------------------------------------------------

# 96. Job payload

Evitar colocar secrets ou grandes volumes de dados sensíveis no payload
se IDs seguros forem suficientes.

------------------------------------------------------------------------

# 97. Dependency security

Dependências de software devem ser:

-   versionadas;
-   revisadas;
-   atualizadas;
-   analisadas por ferramentas de vulnerabilidade quando possível.

------------------------------------------------------------------------

# 98. Supply chain

Controles recomendados:

-   lockfiles;
-   trusted registries;
-   dependency scanning;
-   secret scanning;
-   branch protection;
-   CI controls.

------------------------------------------------------------------------

# 99. Repository security

GitHub deve aplicar, conforme maturidade:

-   protected branches;
-   pull request review;
-   least privilege;
-   secret scanning;
-   dependency alerts;
-   restricted production deployment.

------------------------------------------------------------------------

# 100. CI/CD security

Pipeline não deve expor secrets em logs.

Production credentials devem ter acesso mínimo.

------------------------------------------------------------------------

# 101. Environment separation

``` text
Development
Preview/Test
Production
```

devem possuir credenciais e dados separados.

------------------------------------------------------------------------

# 102. Production data

Não copiar Production data para Development indiscriminadamente.

Quando necessário para troubleshooting/test:

-   anonymize;
-   minimize;
-   authorize.

------------------------------------------------------------------------

# 103. Backup security

Backups contêm dados sensíveis e precisam de proteção equivalente.

Acesso deve ser restrito.

------------------------------------------------------------------------

# 104. Restore security

Procedimentos de restore devem impedir restauração acidental em ambiente
incorreto ou exposição indevida.

------------------------------------------------------------------------

# 105. Security monitoring

Monitorar sinais como:

-   repeated authorization failures;
-   unusual export volume;
-   cross-tenant attempts;
-   privileged operations;
-   unusual AI usage;
-   integration authentication failures.

------------------------------------------------------------------------

# 106. Incident readiness

Mesmo no MVP, deve existir caminho para:

``` text
Detect
Contain
Investigate
Recover
Learn
```

O processo operacional será detalhado em Security/DevOps.

------------------------------------------------------------------------

# 107. Vulnerability management

Fluxo:

``` text
Identify
 ↓
Assess Severity
 ↓
Prioritize
 ↓
Remediate
 ↓
Verify
```

------------------------------------------------------------------------

# 108. Security testing

Categorias obrigatórias:

-   authentication;
-   authorization;
-   Tenant isolation;
-   IDOR/BOLA;
-   sensitive data;
-   input validation;
-   Status publication;
-   RAG override;
-   export;
-   AI boundaries;
-   storage access.

------------------------------------------------------------------------

# 109. Cross-tenant tests

Cenário obrigatório:

``` text
Tenant A user
      ↓
Attempts Tenant B Project
      ↓
DENIED
```

Repetir para:

-   read;
-   update;
-   delete;
-   documents;
-   exports;
-   AI;
-   jobs/integrations quando aplicável.

------------------------------------------------------------------------

# 110. Authorization matrix tests

Testar:

``` text
Role × Scope × Permission × State
```

Não apenas Role.

------------------------------------------------------------------------

# 111. Negative testing

Testes devem provar operações proibidas.

Exemplo:

``` text
Contributor cannot publish Status.
Executive cannot edit arbitrary Project.
PM without financial.view cannot read Budget.
```

------------------------------------------------------------------------

# 112. AI security tests

Testar:

-   prompt injection;
-   cross-project leakage;
-   cross-tenant leakage;
-   confidential data restrictions;
-   unauthorized action attempts;
-   malicious document instructions;
-   hallucinated resource IDs.

------------------------------------------------------------------------

# 113. Security acceptance gate

Feature sensível não está pronta sem:

-   authorization rules;
-   negative tests;
-   Audit requirements;
-   data classification;
-   safe errors.

------------------------------------------------------------------------

# 114. Threat modeling

Realizar threat modeling principalmente para:

-   authentication;
-   multi-tenancy;
-   RBAC;
-   documents;
-   exports;
-   AI;
-   integrations;
-   Platform Admin;
-   BYOK.

------------------------------------------------------------------------

# 115. STRIDE

STRIDE pode ser usado como ferramenta de apoio:

``` text
Spoofing
Tampering
Repudiation
Information Disclosure
Denial of Service
Elevation of Privilege
```

Não precisa ser o único método.

------------------------------------------------------------------------

# 116. OWASP

Desenvolvimento deve considerar riscos relevantes das referências OWASP
para aplicações web, APIs e LLM/GenAI quando aplicável.

Os controles concretos devem ser traduzidos para Specs/tests.

------------------------------------------------------------------------

# 117. Security architecture decisions candidatas a ADR

1.  Authentication provider strategy;
2.  Tenant isolation;
3.  RLS strategy;
4.  service-role usage;
5.  BYOK secret storage;
6.  confidential Storage strategy;
7.  support access;
8.  external integration credential storage.

------------------------------------------------------------------------

# 118. Segurança e UX

Segurança não deve criar ambiguidade.

Quando usuário não puder executar uma ação:

-   esconder quando irrelevante;
-   desabilitar com explicação quando útil;
-   retornar erro claro quando operação for negada.

Sem revelar informação sensível.

------------------------------------------------------------------------

# 119. Security vs usability

Evitar tanto:

``` text
security theater
```

quanto:

``` text
convenience-based bypass
```

Controles devem corresponder a riscos reais.

------------------------------------------------------------------------

# 120. Privacy by design

Aplicar:

-   minimização;
-   purpose limitation;
-   retention;
-   controlled access;
-   secure handling;
-   traceability.

------------------------------------------------------------------------

# 121. LGPD readiness

Arquitetura deve permitir evolução para processos relacionados a:

-   personal data inventory;
-   data subject requests;
-   retention;
-   anonymization/deletion quando aplicável;
-   incident response;
-   processing records.

Detalhamento será tratado na documentação de segurança/compliance.

------------------------------------------------------------------------

# 122. Security invariants

1.  Autenticação não implica autorização.
2.  Tenant é boundary de segurança.
3.  Todo acesso tenant-scoped valida Tenant.
4.  UI não é security boundary.
5.  Deny by default.
6.  Sensitive permissions são explícitas.
7.  Data Policies podem restringir dados dentro de um Project.
8.  Workflow state participa da autorização.
9.  Platform Admin não possui acesso automático aos dados do Tenant.
10. Secrets nunca chegam ao cliente.
11. BYOK é protegido e mascarado.
12. Service credentials permanecem server-side.
13. Audit não armazena secrets.
14. AI não amplia acesso.
15. AI output é não confiável.
16. Prompt content não é instrução confiável.
17. Export respeita a mesma autorização dos dados.
18. Snapshot histórico continua protegido.
19. Jobs possuem contexto e limites.
20. Cross-tenant isolation é testada automaticamente.
21. Operações sensíveis são auditáveis.
22. Segurança começa no MVP.

------------------------------------------------------------------------

# 123. Relação com Specs

Toda Spec funcional deve declarar:

``` text
Actors
Permissions
Scope
Data Policies
Workflow Rules
Audit Events
View
Create
Edit
Delete
Approve
Publish
Export
```

quando aplicável.

------------------------------------------------------------------------

# 124. Relação com `/docs/07-security/`

Este documento define a arquitetura.

A pasta:

``` text
/docs/07-security/
```

deverá detalhar:

-   threat model;
-   security controls;
-   secure coding;
-   secrets;
-   incident response;
-   vulnerability management;
-   compliance/privacy;
-   security testing.

------------------------------------------------------------------------

# 125. Referências

-   `/docs/02-architecture/README.md`
-   `/docs/02-architecture/system-architecture.md`
-   `/docs/02-architecture/data-architecture.md`
-   `/docs/00-foundation/permission-model.md`
-   `/docs/00-foundation/data-classification.md`
-   `/docs/00-foundation/business-rules.md`
-   `/docs/01-product/PDD.md`
-   `/docs/01-product/mvp-scope.md`
-   `/docs/07-security/`

------------------------------------------------------------------------

# 126. Status

**Documento:** Security Architecture\
**Status:** Approved\
**Responsabilidade:** definir os trust boundaries, controles de
identidade, autorização, isolamento multi-tenant, proteção de dados,
segurança de IA, integrações, operações administrativas e invariantes de
segurança do PMO Control.

# SPEC-001 — Authentication — Requirements

**Status:** MVP implemented in DEV — provider policy and production session guarantees remain separately scoped
**Spec:** 001  
**Módulo:** Authentication

## Objetivo e fronteira

Supabase Auth é a fonte de identidade e valida credenciais. O PMO Control
mantém membership, tenant context, papéis, escopos e autorização de
negócio. Uma sessão autenticada, isoladamente, não concede acesso a
nenhum Tenant, Portfolio ou Project.

## Requisitos funcionais

- **FR-001-01:** permitir login por e-mail e senha para conta ativa; login
  Google/Microsoft não faz parte do escopo atual do PDD.
- **FR-001-02:** iniciar recuperação de senha por resposta neutra que não
  revele se o e-mail está cadastrado; o link deve ser de uso único e
  expirar conforme configuração do provedor.
- **FR-001-03:** validar identidade/e-mail em convite emitido pelo fluxo de Multi-Tenancy (Spec 002); autenticação não cria Tenant, Invitation ou grants.
- **FR-001-04:** após autenticar, resolver membership ativa e tenant
  selecionado no servidor; negar acesso a tenant sem membership ativa.
- **FR-001-05:** vincular toda requisição autenticada a `actor_id`,
  `tenant_id` e correlation ID; ignorar tenant/actor enviados pelo
  cliente como prova de autorização.
- **FR-001-06:** permitir logout e revogação de sessão; credencial
  revogada deve ser recusada em requisições subsequentes.
- **FR-001-07:** suportar troca de tenant somente entre memberships
  ativas, limpando estado tenant-scoped e resolvendo novamente as
  permissões no servidor.
- **FR-001-08:** suspender ou remover membership deve impedir novas
  operações autorizadas sem depender de novo login; o comportamento de
  sessões já abertas deve ser validado em cada requisição.
- **FR-001-09:** distinguir falha de autenticação (401) de falta de
  autorização (403 ou resposta não reveladora para recurso inexistente
  ou proibido, conforme política da API).
- **FR-001-10:** registrar eventos de autenticação e mudanças de acesso
  sem registrar senha, token, recovery link ou secret.
- **FR-001-11:** criar um perfil não secreto para cada identidade Auth e
  permitir que o próprio usuário informe/atualize o nome exibido na
  organização; rótulos temporários não podem ser usados como autoridade.

## Requisitos não funcionais

- Validar tokens e sessão no servidor em cada limite de confiança.
- Usar os controles de rate limit gerenciados pelo Supabase Auth nos
  endpoints de credencial e recovery e manter resposta neutra contra
  enumeração. Não alegar limite adicional da aplicação; revisar quotas
  configuráveis antes do tráfego de produção.
- Cookies de sessão devem usar atributos seguros definidos pela
  arquitetura de deployment; tokens não devem ser persistidos em
  `localStorage`.
- Erros e logs nunca incluem credenciais ou tokens completos.

Eventos de login/logout, cadastro, recuperação e ciclo de tokens são mantidos nos Auth Audit Logs do Supabase; não são copiados para `public.audit_events`, evitando duplicação e preservando a divisão entre auditoria de identidade do provedor e eventos de domínio da aplicação. O schema Auth não expõe acesso direto ao cliente. A aplicação trata erros de login com mensagem genérica e, após sessão inválida/expirada no workspace, redireciona para login com aviso neutro.

## Fora de escopo / decisões pendentes

Decisões confirmadas: login MVP por e-mail e senha; MFA fica para fase posterior; SSO Google/Microsoft está fora do MVP. Auto cadastro e SCIM seguem fora de escopo. Duração exata de sessão, cookies e rate limits ficam para a revisão técnica de segurança, sem alterar o escopo de autenticação confirmado.

## Rastreabilidade

PDD: seções 34, 36, 42 e 44. Critérios e testes correspondentes:
`acceptance-criteria.md` e `test-cases.md` desta Spec.


## Acceptance/test traceability

- `FR-001-01` → `AC-001-01`, `AC-001-03` → `TC-001-01`, `TC-001-03`.
- `FR-001-02` → `AC-001-02`, `AC-001-06` → `TC-001-02`, `TC-001-04`.
- `FR-001-03` → `AC-001-04` → membership/invitation tests in Spec 002; authentication verifies identity only.
- `FR-001-04`, `FR-001-07` → `AC-001-04` → `TC-001-05`, `TC-001-06`.
- `FR-001-05`, `FR-001-08` → `AC-001-05` → `TC-001-07`, `TC-001-08`.
- `FR-001-06`, `FR-001-09`, `FR-001-10` → `AC-001-02/06` → `TC-001-09/10` and security regression suite.

# SPEC-001 — Authentication — API

**Status:** Draft — contrato MVP; alinhamento de implementação pendente

## Provider e limites

Login/logout/recuperação de senha usam Supabase Auth com e-mail e senha. MFA e SSO Google/Microsoft não fazem parte do MVP. Segredos e tokens são tratados pelo provider e nunca enviados a APIs de negócio como prova isolada de tenant permission.

## Operações lógicas

- `POST /api/auth/login`: delega credencial ao provider; resposta neutra para credenciais inválidas.
- `POST /api/auth/logout`: revoga sessão conforme mecanismo suportado pelo provider.
- `POST /api/auth/password-recovery`: sempre retorna resposta que não enumera se o e-mail existe.
- `POST /api/auth/password-reset`: valida token único/expirável no provider e atualiza senha.
- `GET /api/session`: retorna ator mínimo e memberships ativas autorizadas.
- `POST /api/session/tenant`: seleciona membership ativa; servidor invalida contexto/caches anteriores e resolve permissions novamente.
- Convites e criação/administração de memberships são definidos na Spec 002; não criar membership via endpoint genérico de auth.

## Segurança e erros

Aplicar rate limit a login/recovery; validar e-mail e payload server-side; não registrar credenciais/tokens; usar cookies/headers seguros definidos pela arquitetura. `401` para credencial/sessão inválida; `403` para membership sem acesso; recovery usa resposta indistinguível para endereço existente/inexistente. Toda operação de negócio revalida sessão e membership; client-supplied `actor_id`, role ou `tenant_id` não autorizam.

## Pendências técnicas

Definir duração/refresh/revogação de sessão, configuração exata dos cookies e rate limits na revisão de segurança e contrato global de API; não alterar o escopo MVP confirmado (email/senha apenas).

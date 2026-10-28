# SPEC-001 — Authentication — Test Cases

**Status:** MVP regression matrix; production rate quotas and absolute session limits remain deployment checks

- **TC-001-01:** Login válido com e-mail/senha cria sessão e resolve memberships.
- **TC-001-02:** Credencial inválida, conta desativada e e-mail inexistente não permitem sessão e não expõem informação enumerável.
- **TC-001-03:** MFA/SSO não são requisitos nem caminhos habilitados no MVP.
- **TC-001-04:** Recuperação usa resposta neutra; token válido funciona uma vez; expirado/reutilizado é recusado.
- **TC-001-05:** Usuário sem membership ativa autentica identidade, mas não acessa tenant/dados.
- **TC-001-06:** Usuário com uma membership ativa recebe seleção/contexto compatível; com várias escolhe uma; com nenhuma não entra em workspace.
- **TC-001-07:** Tentativa de forjar `actor_id`, role, scope ou tenant no body/header é ignorada e não amplia acesso.
- **TC-001-08:** Revogação/suspensão de membership entre requisições bloqueia a seguinte.
- **TC-001-09:** Logout/revogação invalida sessão conforme contrato provider; cookies seguem flags seguras.
- **TC-001-10:** Nenhuma credencial, password, token de sessão/recovery aparece em logs, traces ou respostas.
- **TC-001-11:** JWT de 3.600 s e refresh rotation estão configurados; logout local não encerra sessões independentes. Operação que exigir revogação imediata verifica estado atual no provider.
- **TC-001-12:** Cookies SSR são host-only, `Path=/`, `SameSite=Lax`, `Secure` em HTTPS, sem `HttpOnly`/expiração curta customizada; refresh não é servido por cache compartilhado.
- **TC-001-13:** Método inseguro com cookie e Origin divergente/ausente é rejeitado; falha pré-auth não cria evento de aplicação nem persiste email/IP não verificados.
- **TC-001-14:** Auth identities sem metadado de nome recebem rótulo provisório e `profile_complete=false`; `GET/PATCH /api/v1/me/profile` retorna/atualiza apenas o perfil do ator; nome inválido, payload extra e Origin divergente são rejeitados.
- **TC-001-15:** Sessão inválida/expirada ao abrir o workspace retorna à tela de login com mensagem neutra pedindo nova autenticação; query params não reconhecidos não alteram o aviso.

Gates: sessão inválida, escalada de privilégio, enumeração e acesso sem membership bloqueiam release.

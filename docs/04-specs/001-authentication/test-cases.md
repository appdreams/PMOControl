# SPEC-001 — Authentication — Test Cases

**Status:** Draft — matriz MVP; thresholds/security review pendentes

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

Gates: sessão inválida, escalada de privilégio, enumeração e acesso sem membership bloqueiam release.

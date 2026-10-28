# Critérios fechados de conclusão — Fase 1

**Escopo:** Identity, autenticação, Tenant, RBAC e trilha de auditoria.
**Regra:** a Fase 1 só é concluída quando todos os cinco gates abaixo estiverem marcados como concluídos com evidência. Esta página é a fonte única para o que conta como “100% da Fase 1”. Mudanças de escopo exigem decisão explícita e atualização desta página.

## Escopo incluído

1. **Identidade, Tenant e RBAC (F1-01 a F1-06):** schema, constraints e índices necessários; isolamento entre Tenants; sessão e contexto confiáveis; catálogo e delegação de permissões; membership e lifecycle; provisionamento e convites suportados no MVP.
2. **Auditoria (F1-07):** eventos append-only para operações sensíveis de identidade/Tenant/RBAC, com ator, motivo e correlação; ausência de tokens/segredos nos registros; cobertura para alterações de credenciais que o sistema controla.
3. **Autenticação e onboarding (F1-08 a F1-10, F1-12):** login, recovery/reset, callback, logout e renovação; erros de sessão expirada/negada; onboarding e convite por link manual; formulário self-service de nome de exibição.
4. **Encerramento de Tenant (F1-11):** export allowlisted privado e verificável; download somente pelo contato ativo; entrega/notificação; contestação e legal hold; purge retomável, auditado e impedido antes do fim da retenção ou enquanto houver hold.
5. **Qualidade e documentação (F1-13/F1-14):** matriz de testes negativos para rotas e operações deste escopo; smokes transacionais no CI; rastreabilidade e revisão semântica das Specs 001, 002, 003 e 027; plano e checklist coerentes com o código.

## Critérios de fechamento

| Gate | Condição objetiva | Situação |
|---|---|---|
| C1 — Identity/Tenant/RBAC | Schema, isolamento, grants, convites e lifecycle cobertos por migrations e smokes DEV; sem finding de FK sem índice neste schema. | Em andamento |
| C2 — Auth/onboarding | Fluxos descritos no escopo implementados; estados de sessão e abuso cobertos; perfil self-service funcional. | Em andamento |
| C3 — Audit | Operações sensíveis e alterações de credenciais auditáveis, com scrub verificado por testes. | Em andamento |
| C4 — Tenant export/retention | Entrega, disputa, hold e purge implementados e testados com fixtures; nenhum dado real precisa ser apagado para validar. | Em andamento |
| C5 — Verificação/docs | Matriz negativa, CI verde e Specs 001/002/003/027 revisadas; este arquivo, `IMPLEMENTATION-PLAN.md` e `MVP-CHECKLIST.md` concordam. | Em andamento |

## Fora do bloqueio da Fase 1

- **Exceção aceita:** proteção contra senhas vazadas do Supabase Auth indisponível no plano Free escolhido pelo usuário. Manter registrada; não reabrir decisão de upgrade.
- Gates de produção: MFA/SSO, limite absoluto de duração/inatividade da sessão, SMTP customizado, ambientes Vercel, backups/restore, incidentes, deploy e rollback de produção.
- Fase 2 e posteriores: CRUD e UX de Portfolio/Project e módulos de negócio. Os smokes existentes desses fluxos podem continuar no CI, mas seu desenvolvimento não altera o critério de conclusão da Fase 1.
- Testes com uma terceira conta real ou mudanças em dados reais de usuário. Os fluxos devem passar por smokes com fixtures; nenhuma pessoa precisa aceitar convite nem ter seus dados alterados para concluir a fase.

## Próxima sequência fixa

1. C1: resolver a única FK sem índice remanescente no schema privado de RBAC.
2. C4: completar o ciclo de export, disputa/hold e purge seguro.
3. C2/C3: concluir estados e limites de autenticação, perfil e auditoria/scrub.
4. C5: fechar a matriz negativa, revisar as quatro Specs e validar CI/documentos.

Não adicionar novo item de fechamento sem registrar primeiro a mudança de escopo aqui.

# Tenant Isolation Security

**Status:** Draft — aligned with trusted RLS context; implementation review pending

## Tenant como boundary

Dados de negócio pertencem explicitamente a um `tenant_id`.

## Camadas

1.  resolução server-side do tenant;
2.  autorização por membership/scope;
3.  filtros obrigatórios nas queries;
4.  RLS como defense-in-depth;
5.  validação de relacionamentos same-tenant;
6.  testes negativos automatizados.

## Platform Admin

Não possui acesso automático aos dados de negócio de tenants.

Acesso de suporte deve ser explícito, temporário, autorizado, limitado e
auditado.

## Release gate

Qualquer falha de isolamento cross-tenant bloqueia release.

Exceção administrativa de lifecycle: `platform.projects.purge` invoca procedimento segregado e auditado, limitado a um Project resolvido server-side. Não concede leitura cross-tenant. Procedimento preserva retenções/holds, impede cascade fora do alvo e mantém tombstone mínimo. A capability não permite acesso via consultas RLS normais nem contorna os grants de conteúdo.

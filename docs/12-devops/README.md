# PMO Control --- DevOps

**Status:** Approved\
**Official path:** `/docs/12-devops/README.md`

## Objetivo

Definir práticas de entrega, ambientes, CI/CD, configuração,
observabilidade, migrations, backups, rollback e operação do PMO
Control.

## Stack MVP

-   GitHub
-   Vercel
-   Supabase/PostgreSQL/Auth/Storage
-   Inngest
-   SMTP existente/configurável
-   AI BYOK por Tenant

## Princípios

-   Git é a fonte de verdade do código e infraestrutura versionável.
-   Deploy automatizado e reproduzível.
-   Ambientes isolados.
-   Secrets nunca no repositório.
-   Migrations versionadas.
-   Security/quality gates antes de produção.
-   Observability desde o MVP.
-   Managed services first.

## Ambiente de desenvolvimento

O bootstrap, os comandos locais, o uso do Supabase local, o workflow de qualidade e os pré-requisitos para conectar serviços externos estão em [`development-setup.md`](development-setup.md). Credenciais hospedadas não são necessárias para iniciar UI e domínio local; autenticação/persistência aguardam a migration inicial de Identity & Access, suas policies RLS e testes de isolamento.

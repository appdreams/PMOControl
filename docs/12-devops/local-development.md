# Local Development

**Status:** Approved

## Requisitos

Node.js compatível, package manager definido pelo repositório, Supabase
tooling quando necessário e Git.

## Configuração

Usar `.env.local`/mecanismo equivalente não versionado.

## Fluxo

Clone → Install → Configure env → Start local dependencies → Migrate →
Seed reference data → Run app → Run tests.

## Regra

Documentar comandos reais no README do repositório assim que package
scripts forem estabilizados.

## Procedimento atual

O passo a passo específico do bootstrap Next.js/Supabase local está em [`development-setup.md`](development-setup.md); esse guia substitui os comandos genéricos acima para esta aplicação.

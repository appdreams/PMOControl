# PMO Control --- Testing

**Status:** Draft — requirements/test traceability review in progress\
**Official path:** `/docs/11-testing/README.md`

## Objetivo

Definir a estratégia de qualidade do PMO Control, cobrindo domínio,
APIs, banco de dados, segurança, multi-tenancy, workflows, integrações,
IA, UI e operação.

## Princípio

Qualidade não é apenas validar telas. Os maiores riscos do PMO Control
estão em autorização, isolamento entre tenants, regras de governança,
publicação de status, snapshots, RAG, decisões e integridade histórica.

## Pirâmide

Unit → Domain → Integration → API/Contract → Component → E2E.

Security, tenant isolation, AI evaluation e resilience são trilhas
transversais.

## Release Gate

Falhas críticas de tenant isolation, autorização, integridade de
publicação/snapshot ou exposição de secrets bloqueiam produção.

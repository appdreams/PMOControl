# PMO Control --- Dependency Map

**Status:** Approved

## 1. Objetivo

Definir dependências lógicas para orientar implementação, testes e
rollout. Dependência aqui não significa necessariamente import técnico
direto; significa pré-condição funcional/arquitetural.

## 2. Cadeia central

``` text
Authentication
      ↓
Multi-Tenancy
      ↓
RBAC
      ↓
Audit Foundation
      ↓
Portfolios
      ↓
Projects
      ↓
Project Control Center
      ↓
┌─────────────────────────────────────────────┐
│ Milestones · Deliverables · Dependencies    │
│ Risks · Issues · Actions · Decisions        │
└──────────────────────┬──────────────────────┘
                       ↓
                 Status Update
                       ↓
                   RAG Engine
                       ↓
                   Snapshots
                       ↓
          ┌────────────┴────────────┐
          ↓                         ↓
 Project Dashboard          Portfolio Dashboard
          ↓                         ↓
          └────────────┬────────────┘
                       ↓
                  Time Machine
                       ↓
             Reporting / Copilot
```

## 3. Dependências por módulo

  -------------------------------------------------------------------------------
  Spec                                Depende principalmente de
  ----------------------------------- -------------------------------------------
  001 Authentication                  Foundation/Auth infrastructure

  002 Multi-Tenancy                   Authentication

  003 RBAC                            Authentication + Multi-Tenancy

  004 Portfolios                      Multi-Tenancy + RBAC

  005 Projects                        Portfolios + RBAC

  006 Project Control Center          Projects + governance/execution projections

  007 Milestones                      Projects

  008 Deliverables                    Projects

  009 Risks                           Projects

  010 Issues                          Projects; opcionalmente Risks

  011 Actions                         Projects + sources de governance

  012 Decisions                       Projects + RBAC + Audit

  013 Dependencies                    Projects + Milestones/Deliverables conforme
                                      endpoint

  014 Status Update                   Projects + execution + governance

  015 RAG Engine                      Project indicators +
                                      Risks/Issues/Milestones + Settings

  016 Snapshots                       Status Update + RAG

  017 My Day                          Projects +
                                      Actions/Risks/Issues/Decisions/Milestones

  018 Project Dashboard               Projects + operational/published
                                      projections

  019 Portfolio Dashboard             Portfolios + Projects + RAG/Snapshots

  020 Financial                       Projects + sensitive permissions

  021 Resources                       Projects + sensitive permissions

  022 Documents                       Projects + Storage + permissions

  023 Time Machine                    Snapshots

  024 Report Builder                  Authorized project/portfolio data +
                                      snapshots

  025 PMO Copilot                     AI Gateway + authorized domain data

  026 Notifications                   Users + domain events + async jobs

  027 Audit Log                       Authentication/actor + tenant context;
                                      transversal

  028 Import & Export                 Authz + target domain + async jobs

  029 Settings                        Tenant + RBAC; alimenta RAG/AI/integrations
  -------------------------------------------------------------------------------

## 4. Dependências transversais

### Audit

Deve nascer cedo, pois publicação, override, acesso administrativo,
decisões e mudanças sensíveis dependem dele.

### Notifications

Pode ser implementado depois do core; falha de notificação não deve
bloquear estado oficial.

### AI

Depende do domínio e autorização estarem maduros. Não deve ser usado
para compensar ausência de regras determinísticas.

### Integrations

Entram após contratos internos estáveis, salvo SMTP necessário para
fluxo inicial.

## 5. Regra de implementação

Não iniciar módulo downstream como fonte oficial antes de suas
dependências de segurança e domínio estarem estáveis. UI mockada pode
avançar em paralelo, mas não altera essa regra.

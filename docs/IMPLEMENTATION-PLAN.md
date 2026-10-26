# PMO Control --- Implementation Plan

**Status:** Approved

## 1. Objetivo

Transformar a documentação SDD em uma sequência executável de construção
do MVP.

## 2. Estratégia

Cada fase deve produzir uma fatia testável. A ordem privilegia
segurança, modelo de domínio e cadeia de valor central antes de IA e
integrações avançadas.

## Fase 0 --- Engineering Foundation

### Entregas

-   repository/bootstrap Next.js + TypeScript;
-   environments;
-   Supabase/PostgreSQL/Auth/Storage;
-   migration framework;
-   CI;
-   logging/correlation;
-   error model;
-   base UI/design system;
-   testing harness.

### Gate

Build, migrations e testes básicos reproduzíveis.

## Fase 1 --- Identity, Tenant & Authorization

Specs: - 001 Authentication - 002 Multi-Tenancy - 003 RBAC - fundação de
027 Audit Log

### Gate

Cross-tenant negative tests e backend authorization obrigatórios.

## Fase 2 --- Portfolio & Project Core

Specs: - 004 Portfolios - 005 Projects - 006 Project Control Center

### Gate

Usuário autorizado navega tenant → portfolio → project sem vazamento de
escopo.

## Fase 3 --- Execution Management

Specs: - 007 Milestones - 008 Deliverables - 013 Dependencies

### Gate

Baseline/Forecast/Actual e relações de execução consistentes.

## Fase 4 --- Governance Core

Specs: - 009 Risks - 010 Issues - 011 Actions - 012 Decisions

### Gate

Risk ≠ Issue, Actions rastreáveis, Decisions governadas e auditadas.

## Fase 5 --- Status Governance Engine

Specs: - 014 Status Update - 015 RAG Engine - 016 Snapshots

### Gate crítico

`Publish → RAG → Snapshot → Audit` consistente, transacional e
idempotente.

## Fase 6 --- PMO Visibility

Specs: - 017 My Day - 018 Project Dashboard - 019 Portfolio Dashboard

### Gate

Current vs Published explícito; agregações respeitam autorização.

## Fase 7 --- Control & Evidence

Specs: - 020 Financial - 021 Resources - 022 Documents

### Gate

Permissões sensíveis, private storage e export policy validadas.

## Fase 8 --- History & Reporting

Specs: - 023 Time Machine - 024 Report Builder

### Gate

Histórico reproduzido por snapshots e reports respeitando
temporalidade/autorização.

## Fase 9 --- Intelligence

Spec: - 025 PMO Copilot

### Entregas

AI Gateway, BYOK OpenAI, grounding autorizado, structured output,
Fact/Inference/Recommendation e Human-in-the-Loop.

### Gate

AI Context ≤ Authorized User Context; evaluation e prompt-injection
tests.

## Fase 10 --- Platform Services

Specs: - 026 Notifications - completar 027 Audit Log UI/query - 028
Import & Export - 029 Settings

### Gate

Jobs idempotentes, import preview/confirm, settings auditáveis.

## Fase 11 --- Integrations

### MVP/necessárias

-   SMTP configurável.
-   AI provider via BYOK.

### Pós-core/faseada

Jira, Azure DevOps, GitHub, Microsoft Project, SharePoint/OneDrive,
Google Drive, Teams/Slack e financial systems conforme prioridade real.

## Fase 12 --- Production Readiness

-   security suite;
-   E2E golden paths;
-   load/performance baseline;
-   backup/restore validation;
-   observability/alerts;
-   release/rollback;
-   incident readiness;
-   production access;
-   documentation sync.

## 3. Definition of Done por módulo

Um módulo só é Done quando: - Spec/acceptance criteria satisfeitos; -
authorization/tenant scope implementados; - database/API/UI coerentes; -
audit implementado quando necessário; - testes relevantes verdes; -
observability suficiente; - documentação atualizada; - sem blocker de
security/release.

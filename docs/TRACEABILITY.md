# PMO Control --- Master Traceability

**Status:** Em remediação — tabela de capabilities complementada com workflows críticos; requisito→contratos→teste ainda em revisão integral

## 1. Objetivo

Garantir que cada capacidade relevante possa ser rastreada da intenção
de produto até implementação e testes.

``` text
PDD
 ↓
Module
 ↓
Spec
 ↓
UX
 ↓
Data / API / Security
 ↓
Acceptance Criteria
 ↓
Tests
 ↓
Implementation / Release
```

## 2. Matriz principal

  -------------------------------------------------------------------------------------------------------------
  Spec           Capability       UX / Surface        API / Boundary                 Test focus
                                  principal                                          
  -------------- ---------------- ------------------- ------------------------------ --------------------------
  001            Authentication   Login               Authentication/Authorization   Auth/session/security

  002            Multi-Tenancy    Administration      Tenant context                 Tenant isolation

  003            RBAC             Settings/Admin      Authorization                  RBAC/RLS/negative tests

  004            Portfolios       Portfolio           Portfolio API                  Portfolio scope

  005            Projects         Project Control     Projects API                   Project lifecycle
                                  Center                                             

  006            Project Control  Project Control     Execution/Projects             Projection/current state
                 Center           Center                                             

  007            Milestones       Milestones          Execution API                  Dates/baseline/forecast

  008            Deliverables     Deliverables        Execution API                  Delivery/acceptance

  009            Risks            Risks               Governance API                 Assessment/response

  010            Issues           Issues              Governance API                 Resolution/blocking

  011            Actions          Actions             Governance API                 Owner/due/source

  012            Decisions        Decisions           Governance API                 Approve/reject/defer

  013            Dependencies     Dependencies        Execution/Governance           Cross-project consistency

  014            Status Update    Status Update 1--5  Status Update API              Atomic publication

  015            RAG Engine       Status/Dashboards   RAG API                        Deterministic
                                                                                     rules/override

  016            Snapshots        Time Machine        Snapshots API                  Immutability/history

  017            My Day           My Day              Query/projections              Exceptions/authorization

  018            Project          Project             Project query                  Current vs Published
                 Dashboard        dashboard/PCC                                      

  019            Portfolio        Executive Portfolio Portfolio API                  Authorized aggregation
                 Dashboard                                                           

  020            Financial        Financial           Financial/Resources API        Restricted data

  021            Resources        Resources/Team      Financial/Resources API        Capacity/sensitive data

  022            Documents        Documents           Documents API                  Storage/confidential

  023            Time Machine     Time Machine        Snapshots API                  Historical reconstruction

  024            Report Builder   Report Builder      Reports/Export API             Temporal/auth export

  025            PMO Copilot      PMO Copilot         Copilot API/AI Gateway         Grounding/safety/actions

  026            Notifications    Notifications       Notifications API              Delivery/retries

  027            Audit Log        Audit Log           Audit API                      Append-only/security

  028            Import & Export  Import/Export       Project XLSX/Data Jobs API     Tenant isolation/templates/add/replace

  029            Settings         Settings            Settings/Admin API             Tenant config/audit
  -------------------------------------------------------------------------------------------------------------

## 3. Rastreabilidade de workflows críticos

### Multi-Tenancy, lifecycle e exportação

`PDD tenant decisions → SPEC-002 FR-002-01–12 → Tenant/Membership/Invitation/TenantExport/ExportDispute → tenant.lifecycle.*, tenant.admin.transfer.*, tenant.export.* → tenant lifecycle API → AC-002-01–10 → TC-002-01–14`.

Provisionamento e encerramento são exclusivos da equipe da plataforma. Transferência de administrador exige solicitante atual e novo administrador verificado; recuperação usa suporte JIT independente e auditado. Export deve estar íntegra e disponível antes de iniciar 90 dias; contestação fundamentada em até 30 dias pausa somente o escopo contestado.

### Publicação de Status

`PDD → Spec 014 → Status UX Steps 1–5 → Status API → RAG 015 → Snapshot 016 → Audit 027 → Dashboard 018/019 → Time Machine 023 → status-publication-testing`

Invariante: publicação oficial e snapshot consistente fazem parte da
mesma operação governada.

### RAG

`Spec 015 FR-015-04/09 → rag-evaluations API → rag_rule_versions/rag_evaluations/rag_overrides → evaluate/override grants + RLS → AC-015-02/06 → TC-015-01/10/11 → Dashboards`

Calculated RAG deve permanecer preservado mesmo quando houver Effective
RAG por override.

Contrato canônico MVP: `rag-v1` em `docs/04-specs/015-rag-engine/business-rules.md`; rule versions e avaliações append-only em `database.md`; operação `evaluateRag` persiste versão/hash; valores ausentes obrigatórios geram `incomplete`.

### Snapshot e Status

`PDD §14/15/40 → Spec 014 publish/correct + kpi-v1 → Spec 015 rag-v1 → Spec 016 snapshot-v1 → tables/status-snapshot-model → status-update/snapshots API → permissions status.update.publish/correct + snapshots.view/verify → AC-014/015/016 → status-publication/rag/snapshot-time-machine tests`.

Payload e hash canônicos estão definidos em Spec 016 `database.md`; criação é interna à transação de publicação/correção. Hash divergente retorna `invalid`, abre alerta auditado e não reescreve o histórico.

Cadência e KPI seguem os defaults MVP em PDD §14/40 e Spec 014 BR-SU-011–014: período mensal, fechamento no fuso do Tenant, publicação até o quinto dia de semana, fórmulas `kpi-v1`, razões N/A explícitas e validação de source version antes do commit. Os cinco passos UX apontam para FR/permission/AC/TC correspondentes.

## 5. Authorization implementation trace

`SPEC-003 FR-003-01–09 → grant/role APIs + trusted actor/tenant transaction context → tenant-owned RLS predicates + same-tenant composite FKs → field-level data policies → revocation/cache and job re-check → TC-003-02–11 + RLS table matrix`.

Role presets and explicit denied capabilities are defined in SPEC-003 `permissions.md`; RLS context/policy shape is defined in `docs/06-data/rls-data-policies.md` and `docs/07-security/rls-security.md`. Production release still requires executable policy verification against every physical tenant-owned table.

### Baseline

`Project/Execution Specs → Data Model → baseline.change → Approval Workflow → Audit → Domain/Workflow Tests`

### Executive Decision

`Spec 012 → Decisions UX → Governance API → decision.approve → Audit → Workflow Tests`

### PMO Copilot

`Spec 025 → Copilot UX → Copilot API → AI Gateway → Authorized Grounding → Human-in-the-Loop → AI Evaluation/Security Tests`

`PDD §35 → SPEC-025 FR-025-10–15 → TenantAIProviderConfig/AIUsageRecord + encrypted secret manager → ai.config.* / ai.cost.* → Tenant AI config + cost dashboard → AC-025-07–10 → TC-025-11–19`; o Gateway classifica automaticamente `low|medium|high` com regra determinística versionada, associa um dos três modelos do Tenant e grava uso/custo por tentativa. BYOK nunca retorna; métricas separam custo informado pelo provider, estimativa local e indisponibilidade, sem representar fatura oficial.

### Importação de projeto por Excel

`PDD §39 → SPEC-028 FR-028-10–16 → project-import-template-v1 + DataJob(target_project_id, mode, version, checksum) + project-scoped external_mappings → project.data.import / project.data.import.replace → import/export screen + blank/sample XLSX → AC-028-07–12 → TC-028-11–22`. Escopo v1 vazio não pede modo; projeto preenchido exige acréscimo insert-only ou substituição atômica com confirmação separada. Audit, publicações, snapshots e holds permanecem.

## 4. Regras de rastreabilidade

Toda nova feature deve possuir: - origem de requisito; - Spec
responsável; - atores e permissões; - entidades/dados; -
API/command/query; - UX quando aplicável; - acceptance criteria; - test
cases; - audit events quando aplicável.

Rastreamento requisito a requisito para publicação: `FR-014-05/06/08 → AC-014-01/02/08 → TC-014-01/02/12/15/17`; snapshot: `FR-016-02/03/09 → AC-016-03/06 → TC-016-01/04/06`; RAG: `FR-015-04/09 → AC-015-02/06 → TC-015-01/06`. Os demais módulos ainda exigem conferência equivalente.

Nenhuma referência visual isolada deve ser considerada especificação
funcional.

Inventário comportamental completo das 33 telas: `docs/05-ux/SCREEN-TRACEABILITY.md`. Índice canônico de recursos, rotas e campos API: `docs/08-api/module-schema-register.md`. Ambos são Draft enquanto os contratos de comando e a verificação executável estiverem pendentes.


## 5. Estado da rastreabilidade por requisito

A matriz acima relaciona capacidades às áreas documentais, mas ainda não é rastreabilidade verificável requisito a requisito. As Specs permanecem Draft até que cada requisito possua IDs ligados a entidade/campo e ownership, operação API, permission/scope, UX quando aplicável, acceptance criterion e caso de teste. A publicação de Status segue o contrato provisório da Spec 014; decisões MVP confirmadas constam em `docs/01-product/PDD.md`, Specs 001/002/014 e nas políticas de retenção/suporte; decisões técnicas ainda abertas permanecem nas Specs e no SDD-AUDIT-REPORT.

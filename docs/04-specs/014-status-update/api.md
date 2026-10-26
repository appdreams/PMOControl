# SPEC-014 — Status Update — API

**Status:** Draft — workflow alinhado; payload status/snapshot definido nas Specs 014/016  
**Spec:** 014  
**Módulo:** Status Update

## Comandos

- `POST /api/v1/projects/{projectId}/status-updates`: cria rascunho mensal; requer `status.update.create` no Project scope.
- `PATCH /api/v1/status-updates/{statusUpdateId}`: salva alterações no rascunho usando `expected_version`; status publicado/superseded é imutável.
- `POST /api/v1/status-updates/{statusUpdateId}/validate`: executa checklist e KPI/RAG preview; retorna blockers/warnings sem publicar.
- `POST /api/v1/status-updates/{statusUpdateId}/publish`: publica mediante `status.update.publish`, `expected_version` e header `Idempotency-Key`.
- `GET /api/v1/projects/{projectId}/status-updates`: lista versões permitidas, separando rascunhos do histórico publicado.
- `GET /api/v1/status-updates/{statusUpdateId}`: retorna dados conforme scope e data policy.

`POST /api/v1/status-updates/{statusUpdateId}/corrections` cria publicação sucessora; exige `status.update.correct`, motivo e header `Idempotency-Key`. Payload do snapshot é `snapshot-v1` conforme Spec 016; o cliente não o envia.

## Request/response schemas

- Draft create body: `{ reporting_period: "YYYY-MM-01", executive_summary: string }`; server resolves Tenant timezone and derives `status_date` as month end. `tenant_id`, `actor_id`, `status`, KPI/RAG values and snapshot payload are rejected if supplied.
- Draft section save body: `{ expected_version: integer, section_key: enum, content_json: object, source_versions: object }`; mutable keys are only sections in the Spec 014 UI contract.
- Validate body: `{ expected_version: integer }`; response returns `{ valid, blockers[], warnings[], source_versions, kpi_preview, rag_preview }` and creates no publication/snapshot.
- Publish body: `{ expected_version: integer }`; header `Idempotency-Key` required. Response: `{ status_update_id, publication_id, snapshot_id, snapshot_version, schema_version, payload_hash, kpi_rule_set_version, rag_rule_version_id, published_at, post_commit_jobs[] }`.
- Correction body: `{ expected_version: integer, reason: string }` with reason >= 10 characters; response adds `supersedes_publication_id` and successor IDs.
- List query: `cursor, limit (1..100), reporting_period, state`; all filters are allowlisted and tenant/project scope is server-derived.

Error details are stable: `409` stale draft/source version or reused idempotency key with different request; `422` checklist blocker; `403` missing action grant; `404` hidden/out-of-scope resource; `503` pre-commit dependency failure. A post-commit job issue is returned as pending effect, not as failed publication.

## Publicação e atomicidade

Dentro de uma única transação autoritativa: revalidar sessão, Tenant, permission, versão, source versions e regras; consolidar os dados de origem; calcular KPI-v1 e rag-v1; gravar Publication com rule versions, Snapshot-v1 imutável, estado `published` e evento/audit outbox. Qualquer falha antes do commit aborta todas essas gravações. Não enviar notificações, atualizar projeções distribuídas ou chamar integrações dentro da transação.

Após commit, consumidores idempotentes processam outbox para atualizar projeções/dashboards e enviar notificações. Falha pós-commit não reverte Publication/Snapshot; o job é repetido e observável. Repetição da mesma idempotency key retorna o resultado já criado; chave reutilizada com payload diferente é conflito.

## Respostas e conflitos

Retornar identificadores da publicação e snapshot, versão, data de publicação e estado dos efeitos pós-commit. `409` para versão concorrente ou rascunho já publicado com conteúdo divergente; `422` para checklist/regra inválida. Nunca reportar sucesso se o commit autoritativo falhar.

## Revisão de implementação

Defaults e schemas estão definidos nas Specs 014–016. Permanecem como trabalho de implementação: materializar os contratos OpenAPI, executar fixtures kpi-v1/rag-v1 e verificar atomicidade/RLS no banco. O fluxo padrão não exige aprovação separada; correções autorizadas usam permission, motivo e publicação sucessora.

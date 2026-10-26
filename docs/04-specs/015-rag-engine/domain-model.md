# SPEC-015 — RAG Engine — Domain Model

**Status:** Draft — entidades e ownership definidos em nível lógico

## Entidade principal

`RagEvaluation`

Campos de domínio: `tenant_id, project_id, calculated_rag, effective_rag, rule_set_version, inputs_hash, evaluated_at, override_reason, overridden_by`. Campos de auditoria comuns (`created_at`, `updated_at`, `created_by`, `updated_by`) são mantidos separadamente de valores de negócio.

## Ownership e relações

Tenant-owned; scope primário: `Project`. Recursos relacionados devem compartilhar `tenant_id`; Project/Portfolio/Actor IDs são referências, nunca prova de autorização.

## Invariantes

1. Calculated RAG é determinístico e preservado; override muda Effective RAG, exige justificativa e audit.
2. Ownership e assignment não substituem permission.
3. Current operational state é distinto de published/historical state quando módulo consome snapshot.
4. Fechamento/arquivamento preserva referência de origem e trilha de auditoria.

## Lifecycle

Operações de domínio: evaluateRag, getRagHistory, overrideRag, revokeOverride. Rule version, evaluation status, normalized inputs and hash follow the canonical fields in `database.md`. Evaluations and override history are append-only; only an active override can be revoked.

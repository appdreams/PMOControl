# SPEC-017 — My Day — Domain Model

**Status:** Draft — read model

## Projection

`MyDayItem` é view/read model derivado de entidades oficiais. Campos visíveis: `actor_id, project_id, source_type, source_id, exception_type, due_at, severity, action_url`. Chave primária de navegação é o ID da fonte ou combinação de IDs de snapshot; nunca uma nova identidade de domínio.

## Invariantes

1. Consolida fontes oficiais sem criar nova fonte de verdade.
2. Tenant, membership, Project/Portfolio scope e field-level data policy são reaplicados na leitura.
3. Link de ação navega para fonte de verdade e reautoriza a operação.

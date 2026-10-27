# Observability

**Status:** Approved

## Pilares

Logs, Metrics, Traces/Correlation e Business/Domain signals.

## Contexto

requestId, correlationId, tenant context seguro, user/actor ID quando
apropriado, resource/job ID.

## Domínio

Monitorar status publications, failed jobs, integration health, AI
failures e authorization anomalies.

## Regra

Observability não pode vazar secrets ou conteúdo sensível desnecessário.

As rotas API versionadas retornam `requestId` no envelope de erro e no header `X-Request-Id`. Falhas inesperadas são registradas como JSON com operação estática e tipo de erro sanitizado; mensagem, stack e payload da exceção não são serializados. O código da dependência pode ser incluído quando disponível.

Mutações de Portfolio e Project também registram falhas RPC não classificadas com operação estática e SQLSTATE validado, e respostas de dependência inválidas ou fora do escopo são correlacionadas sem incluir IDs nem payload.

Toda resposta HTTP 5xx emitida pelo helper comum de API é registrada, inclusive as falhas sem classificação específica. Um limite de deduplicação mantém no máximo 1.024 IDs recentes por processo e evita duplicar o log específico do handler.

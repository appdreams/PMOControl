# Security Release Checklist

**Status:** Approved

## Tenant & Authorization

-   [ ] Tenant context resolvido server-side.
-   [ ] Deny by default.
-   [ ] Scope/Permission/Data Policy testados.
-   [ ] Cross-tenant negative tests passando.
-   [ ] IDOR/BOLA testado.

## Data

-   [ ] Sensitive fields classificados.
-   [ ] RLS revisada.
-   [ ] Exports autorizados.
-   [ ] Storage privado.

## Secrets

-   [ ] Nenhum secret no Git/log/browser.
-   [ ] BYOK/integration credentials protegidos.
-   [ ] Ambientes separados.

## Workflows

-   [ ] Publish/RAG override/baseline/decision auditáveis.
-   [ ] SoD validada.
-   [ ] AI consequential writes exigem confirmação.

## Integrations

-   [ ] Webhook signature/replay/idempotency.
-   [ ] External payload validation.

## Operations

-   [ ] Logging/redaction.
-   [ ] Monitoring/alerts.
-   [ ] Recovery/incident procedures.

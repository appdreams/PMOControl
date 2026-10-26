# Security Logging & Monitoring

**Status:** Approved

## Monitorar

-   auth failures/anomalies;
-   permission denials;
-   cross-tenant attempts;
-   privileged access;
-   unusual exports;
-   webhook failures;
-   integration auth failures;
-   AI policy violations;
-   rate-limit events.

## Logs

Estruturados, com correlation ID e tenant context quando seguro.

## Redaction

Secrets, tokens, credentials e campos sensíveis devem ser
removidos/redigidos.

## Alertas

Severidade e thresholds serão calibrados com dados reais para evitar
alert fatigue.

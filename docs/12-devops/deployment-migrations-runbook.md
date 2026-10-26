# Deployment & Migration Runbook

**Status:** Approved

## Antes

-   checks verdes;
-   backup/recovery posture verificado;
-   migration review;
-   compatibility review;
-   rollback plan.

## Durante

-   aplicar migration compatível;
-   verificar;
-   deploy app;
-   smoke tests;
-   monitorar errors/latency/jobs.

## Depois

-   confirmar health;
-   confirmar critical workflows;
-   registrar release.

## Falha

Parar rollout, avaliar rollback/forward-fix e proteger integridade dos
dados.

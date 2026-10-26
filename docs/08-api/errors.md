# API Error Model

**Status:** Approved

## Envelope

``` json
{
  "error": {
    "code": "PROJECT_NOT_FOUND",
    "message": "Project not found or unavailable.",
    "requestId": "..."
  }
}
```

## Classes

-   `400` invalid request;
-   `401` unauthenticated;
-   `403` authenticated but forbidden;
-   `404` resource unavailable/not found;
-   `409` conflict/concurrency/workflow conflict;
-   `422` domain validation;
-   `429` rate limit;
-   `500` unexpected internal failure;
-   `503` dependency temporarily unavailable.

## Segurança

Mensagens não devem confirmar existência de recursos protegidos quando
isso causar information disclosure.

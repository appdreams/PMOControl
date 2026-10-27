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

Toda resposta de erro da API versionada inclui também o header `X-Request-Id`, igual ao `requestId` do envelope. O identificador é gerado no servidor e pode ser informado ao suporte para localizar um diagnóstico.

Falhas inesperadas geram log JSON com evento, `requestId`, nome estático da operação, tipo de erro sanitizado e, quando disponível, código de dependência. Não registrar mensagem ou stack da exceção, corpo da requisição, credenciais, tokens, e-mails ou outros dados pessoais.

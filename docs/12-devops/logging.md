# Logging

**Status:** Approved

## Formato

Estruturado.

## Níveis

Debug/Info/Warn/Error conforme ambiente/política.

## Redaction

Passwords, tokens, cookies, BYOK, SMTP credentials e integration secrets
nunca são logados.

## Correlação

HTTP request → domain operation → async job → provider call deve ser
correlacionável quando possível.

## Audit

Operational logs não substituem Audit Log.

# Threat Model

**Status:** Approved

## Ativos críticos

Dados de tenants, projetos, orçamento, recursos, documentos, snapshots,
decisões, credenciais de integração, BYOK, sessões e audit trail.

## Fronteiras de confiança

Browser → Next.js → Supabase/PostgreSQL/Storage → Inngest → integrações
→ provedores de IA.

## Ameaças prioritárias

-   cross-tenant data leakage;
-   IDOR/BOLA;
-   privilege escalation;
-   session theft;
-   insecure direct database access;
-   broken RLS;
-   forged tenant/project context;
-   secret exposure;
-   malicious uploads;
-   webhook spoofing/replay;
-   CSV/formula injection;
-   prompt injection;
-   unauthorized AI grounding/action;
-   audit tampering;
-   mass export/exfiltration;
-   insecure admin/support access.

## Mitigação

Autorização server-side, tenant context validado, RLS defense-in-depth,
validation, encryption, secure sessions, signed webhooks, idempotency,
rate limits, audit, least privilege e testes negativos cross-tenant.

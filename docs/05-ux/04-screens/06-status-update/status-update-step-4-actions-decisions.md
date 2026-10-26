# Screen --- Status Update --- Step 4 --- Ações e Decisões

**Status:** Draft — behavioral trace to Spec 014\
**Path:**
`/docs/05-ux/screens/status-update-step-4-actions-decisions.md`

## Objetivo

Ações, decisões, reuniões, pendências, overdue e itens aguardando
decisão.

## Usuários

A tela é exibida conforme Tenant, Role, Scope, Permission, Data Policy e
Workflow Rule.

## Behavioral contract trace

`SPEC-014 FR-014-02/04/10 → action/decision view grants → source ID/version/as-of → AC-014-04/10 → TC-014-21/22/25`. Show owner, due/status, pending decision and source; status preparation is read-only for source items.

## Layout

``` text
App Shell
├── Left Navigation
├── Context / Breadcrumb
├── Page Header
├── Primary Actions
├── Summary / KPIs
├── Main Content
└── Contextual / AI / Detail Area
```

## Hierarquia

1.  contexto e estado;
2.  exceções/itens que exigem atenção;
3.  indicadores;
4.  conteúdo detalhado;
5.  ações secundárias.

## Estados

Loading, Empty, Ready, Partial Error, Forbidden e Archived/Closed quando
aplicável.

## Padrões

-   desktop-first;
-   dark navy/graphite;
-   blue/cyan para informação/ação;
-   purple para IA;
-   green/amber/red para saúde;
-   rounded cards e bordas sutis;
-   tooltips para conceitos;
-   drill-down até a fonte oficial.

## Segurança

Frontend não é security boundary. Ações e dados são revalidados
server-side.

## Current vs Published

Quando aplicável, a tela deve identificar explicitamente qual contexto
temporal está sendo exibido.

## Responsividade

Desktop preserva densidade; tablet reorganiza grids; mobile prioriza
leitura, exceções e ações principais.

## Acessibilidade

Keyboard, focus visible, semantic labels, contraste AA e estados não
dependentes apenas de cor.

## Audit

Ações sensíveis executadas pela tela devem produzir os eventos de
auditoria definidos pela Spec correspondente.

## Copilot

Quando presente, recebe apenas o contexto autorizado e não executa
mudanças consequenciais silenciosamente.

## Acceptance UX

-   usuário entende onde está;
-   estado principal é compreendido rapidamente;
-   exceções aparecem antes de informação saudável;
-   ações não autorizadas não são executáveis;
-   fonte dos dados é navegável;
-   erro/empty/loading possuem tratamento explícito.

Behavioral contract trace: [SCREEN-TRACEABILITY.md](../../SCREEN-TRACEABILITY.md).

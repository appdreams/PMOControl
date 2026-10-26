# PMO Control --- Master Documentation Manifest

**Status:** Estrutura completa / remediação semântica em andamento\
**Escopo:** `/docs`\
**Baseline estrutural verificada:** 2026-10-25

## 1. Estado geral

A estrutura documental principal do PMO Control está completa de
`00-foundation/` a `13-guides/`, acrescida dos documentos mestres na
raiz de `/docs`.

  Área                 Responsabilidade                        Status
  -------------------- --------------------------------------- ----------
  `00-foundation/`     Fundamentos transversais                Complete
  `01-product/`        PDD, visão, escopo, módulos e roadmap   Complete
  `02-architecture/`   Arquitetura de sistema                  Inventário completo; reauditoria pendente
  `03-adrs/`           Decisões arquiteturais                  Inventário completo; reauditoria pendente
  `04-specs/`          29 Specs + SPEC-TEMPLATE                Estrutura completa; conteúdo em remediação
  `05-ux/`             UX, telas e referências visuais         33 telas rastreadas; revisão final pendente
  `06-data/`           Modelo e governança de dados            Contratos em revisão; validação física pendente
  `07-security/`       Segurança e autorização                 Política documentada; execução pendente
  `08-api/`            Contratos de API                        Registro de módulos; schemas finais pendentes
  `09-ai/`             Arquitetura e governança de IA          Draft; revisão semântica pendente
  `10-integrations/`   Integrações                             Draft; revisão semântica pendente
  `11-testing/`        Estratégia e gates de testes            Planos documentados; execução pendente
  `12-devops/`         Delivery e operações                    Inventário presente; revisão final pendente
  `13-guides/`         Guias de desenvolvimento/operação       Inventário presente; revisão final pendente

## 2. Specs oficiais

001 Authentication\
002 Multi-Tenancy\
003 RBAC\
004 Portfolios\
005 Projects\
006 Project Control Center\
007 Milestones\
008 Deliverables\
009 Risks\
010 Issues\
011 Actions\
012 Decisions\
013 Dependencies\
014 Status Update\
015 RAG Engine\
016 Snapshots\
017 My Day\
018 Project Dashboard\
019 Portfolio Dashboard\
020 Financial\
021 Resources\
022 Documents\
023 Time Machine\
024 Report Builder\
025 PMO Copilot\
026 Notifications\
027 Audit Log\
028 Import & Export\
029 Settings

## 3. Documentos mestres na raiz

-   `README.md`
-   `MANIFEST.md`
-   `TRACEABILITY.md`
-   `DEPENDENCY-MAP.md`
-   `IMPLEMENTATION-PLAN.md`
-   `MVP-CHECKLIST.md`
-   `CHANGELOG.md`

## 4. Correção de consistência --- Schedule

A pendência anteriormente registrada para a tela Schedule foi resolvida.

Existem agora:

-   `/docs/05-ux/04-screens/04-project/schedule.md`
-   `/docs/05-ux/05-visual-references/schedule/schedule-main-reference.png`

Portanto, **Schedule não é mais uma pendência documental**.

## 5. Observação não bloqueante --- Team visual reference

A referência `team-main-reference.png` permanece sob:

`/docs/05-ux/05-visual-references/resources/`

A organização semântica poderia futuramente separá-la em
`05-visual-references/team/`, mas isso não representa lacuna funcional,
de segurança, de API, de dados ou de implementação.

## 6. Estado de fechamento

A árvore documental está completa, mas o conteúdo ainda não é baseline de implementação aprovada. Contratos v1 de publicação/RAG/snapshot, cadência mensal e KPI-v1 foram detalhados e alinhados nos documentos mestres; todas as Specs continuam Draft até reauditoria F-004–F-009, schemas API completos e verificação executável de RLS/testes. Varreduras estáticas de links e IDs de rastreabilidade passaram nesta revisão, sem equivaler a validação semântica/runtime. Não declarar SDD Baseline 1.0 antes de fechar rastreabilidade requisito→dados/API/permissão/AC/teste nos demais domínios e resolver findings High/Critical.

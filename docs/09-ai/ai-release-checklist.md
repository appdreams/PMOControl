# AI Release Checklist

**Status:** Approved

-   [ ] Use case e valor definidos.
-   [ ] Authorized context explicitamente limitado.
-   [ ] Provider/model permitido.
-   [ ] Prompt versionado.
-   [ ] Structured output validado quando aplicável.
-   [ ] Fact/Inference/Recommendation tratados.
-   [ ] Prompt injection considerado.
-   [ ] Secrets excluídos.
-   [ ] Consequential actions usam HITL.
-   [ ] Fresh authorization antes de write.
-   [ ] Evaluation set executado.
-   [ ] Cross-tenant/permission tests passando.
-   [ ] Observability habilitada.
-   [ ] Cost controls definidos.
-   [ ] Tenant BYOK config/rotation/secret redaction verified.
-   [ ] Three complexity mappings verified; deterministic router version/reason is auditable.
-   [ ] Usage ledger, cost measurement status, Tenant cost permissions and budget concurrency verified.
-   [ ] Fallback/degradation definidos.
-   [ ] Audit definido quando necessário.

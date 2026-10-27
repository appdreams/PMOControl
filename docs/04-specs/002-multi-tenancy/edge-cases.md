# SPEC-002 — Multi-Tenancy — Edge Cases

**Status:** Draft — domain-specific

1. Duplicate normalized slug during concurrent platform provisioning.
2. Tenant creation fails after tenant row but before first admin membership; transaction/compensation prevents orphan.
3. Non-platform client guesses create/suspend/terminate route.
4. Invitation is accepted with mismatched verified email, expired at boundary, revoked, or replayed concurrently.
5. Multi-tenant user switches context while an old-tab request/job is still running.
6. Membership revoked or Tenant suspended between authorization check and commit.
7. Tenant suspension while webhook, scheduled job, notification or integration is pending.
8. Export contains paginated data/storage files and one partition fails; no false export-ready state.
9. Customer disputes export completeness; purge countdown must not start before ready/available state.
10. Legal hold arrives during 90-day window or covers only a subset of records.
11. Purge retry after partial storage/database deletion; operation resumes idempotently.
12. Backup still contains deleted tenant data until maximum 35-day expiry.
13. Missing quota vs explicit zero quota; no silent default cap.
14. Transferência de administrador com solicitação revogada, novo e-mail não verificado, alteração concorrente ou tentativa de autopromoção.
15. Tenant sem administrador ativo: recuperação por JIT exige ticket, aprovação independente, scope mínimo, expiração e trilha de auditoria.
16. Contestação de export fora da janela de 30 dias, com escopo parcial, duplicada ou protocolada durante purge; somente o escopo válido deve ser pausado.
17. Different organization names normalize to the same slug, a name exceeds the slug length, or a Unicode-only name produces no valid ASCII identifier.

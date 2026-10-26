# SPEC-014 — Status Update — Edge Cases

**Status:** Draft — domain-specific

1. Tenant/Project suspended or publish permission revoked after draft load.
2. Two editors save/publish same draft with stale `expected_version`.
3. Duplicate publish request after client timeout; same idempotency key/request returns original publication.
4. Same key reused with a different payload; reject conflict.
5. Failure during KPI/RAG calculation, snapshot insert, audit/outbox insert or commit; no partial authoritative publication.
6. Projection, notification or integration fails after commit; publication remains official and job retries.
7. A source entity changes while status snapshot is being consolidated; validate source versions or define consistent transaction snapshot.
8. Required checklist warning vs blocking error; user cannot override hard blockers.
9. RAG override exists; snapshot preserves calculated and effective values plus reason/actor.
10. Correction is attempted without `status.update.correct`, without reason, on wrong tenant or against stale publication.
11. Successor creation fails; previous publication and snapshot remain unchanged.
12. No prior snapshot exists for delta; display explicit first-publication state rather than fabricated change.

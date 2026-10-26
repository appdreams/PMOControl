# Snapshot & Time Machine Testing

**Status:** Draft — executable fixtures required for implementation

## Snapshot

Atomic creation with publication; exact `snapshot-v1` schema; deterministic RFC 8785 canonical JSON SHA-256; stable array ordering; round-trip serialization; reject update/delete; correction creates successor only; version/schema compatibility; tenant/policy field filtering.

## Time Machine

Deve reproduzir estado histórico a partir do snapshot correto.

## Comparação

Test deltas between snapshots and Current State, verify valid and tampered hashes, and prove historical rendering reads snapshot payload rather than current tables.

## Correção

Correção histórica ocorre por nova publicação, não UPDATE silencioso.

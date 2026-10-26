# Snapshots API

**Status:** Draft — aligned with Spec 016 `snapshot-v1`; OpenAPI review pending

## Resource

`/projects/{projectId}/snapshots`

## Operations

Read/list authorized immutable snapshots, compare historical states, and verify payload integrity. Header and payload contract is canonical in `docs/04-specs/016-snapshots/database.md`.

## Prohibition

No ordinary update/delete endpoint.

Snapshot creation is internal to the atomic Status publish/correct command. No client endpoint accepts arbitrary snapshot payloads. Hash verification returns `valid|invalid`; mismatch is audited and surfaced as an integrity alert.

## Time Machine

Historical queries resolve snapshots, not reconstructed mutable current
tables.

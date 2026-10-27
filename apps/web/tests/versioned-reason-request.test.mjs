import test from "node:test";
import assert from "node:assert/strict";
import { isUuid, parseVersionedReasonRequest } from "../src/modules/identity/application/versioned-reason-request.ts";

test("versioned operation accepts a complete request and normalizes reason/key", () => {
  assert.deepEqual(parseVersionedReasonRequest({
    expectedVersion: 3,
    reason: "  Encerramento solicitado  ",
    idempotencyKey: "A1234567-89AB-4CDE-8FAB-0123456789AB",
  }), {
    expectedVersion: 3,
    reason: "Encerramento solicitado",
    idempotencyKey: "a1234567-89ab-4cde-8fab-0123456789ab",
  });
});

test("versioned operation rejects missing, forged, unsafe, and extra fields", () => {
  const base = { expectedVersion: 1, reason: "Motivo", idempotencyKey: "a1234567-89ab-4cde-8fab-0123456789ab" };
  assert.equal(parseVersionedReasonRequest(null), null);
  assert.equal(parseVersionedReasonRequest([]), null);
  assert.equal(parseVersionedReasonRequest({ ...base, actorId: "d1234567-89ab-4cde-8fab-0123456789ab" }), null);
  assert.equal(parseVersionedReasonRequest({ ...base, expectedVersion: Number.MAX_SAFE_INTEGER + 1 }), null);
  assert.equal(parseVersionedReasonRequest({ ...base, expectedVersion: 0 }), null);
  assert.equal(parseVersionedReasonRequest({ ...base, idempotencyKey: "forged" }), null);
  assert.equal(parseVersionedReasonRequest({ ...base, reason: "   " }), null);
});

test("UUID path identifiers accept canonical UUIDs and reject malformed or forged identifiers", () => {
  assert.equal(isUuid("a1234567-89ab-4cde-8fab-0123456789ab"), true);
  assert.equal(isUuid("not-a-uuid"), false);
  assert.equal(isUuid("a1234567-89ab-4cde-8fab-0123456789ab/../other"), false);
  assert.equal(isUuid(42), false);
});

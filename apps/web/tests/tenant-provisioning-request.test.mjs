import assert from "node:assert/strict";
import test from "node:test";
import { parseTenantProvisioningRequest } from "../src/modules/identity/application/tenant-provisioning-request.ts";

const validRequest = {
  displayName: "Fundação Ágil",
  reason: "Provisionamento sintético de DEV",
  idempotencyKey: "f9a1a3bb-4688-4e33-9b72-81ed953e72b1",
};

test("accepts only name, reason, and an idempotency key", () => {
  assert.deepEqual(parseTenantProvisioningRequest(validRequest), validRequest);
});

test("rejects a client-supplied slug instead of treating it as authority", () => {
  assert.equal(parseTenantProvisioningRequest({ ...validRequest, slug: "caller-chosen" }), null);
});

test("rejects malformed or untrimmed required fields", () => {
  assert.equal(parseTenantProvisioningRequest({ ...validRequest, displayName: "   " }), null);
  assert.equal(parseTenantProvisioningRequest({ ...validRequest, reason: " reason " }), null);
  assert.equal(parseTenantProvisioningRequest({ ...validRequest, idempotencyKey: "bad-key" }), null);
});

test("rejects additional fields and non-object payloads", () => {
  assert.equal(parseTenantProvisioningRequest({ ...validRequest, actorId: "forged" }), null);
  assert.equal(parseTenantProvisioningRequest(null), null);
  assert.equal(parseTenantProvisioningRequest([]), null);
});

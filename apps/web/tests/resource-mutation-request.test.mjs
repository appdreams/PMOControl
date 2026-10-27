import test from "node:test";
import assert from "node:assert/strict";
import { parseResourceMutationRequest } from "../src/modules/identity/application/resource-mutation-request.ts";

const idempotencyKey = "123e4567-e89b-42d3-a456-426614174000";

test("Portfolio mutation normalizes editable fields and requires a current version", () => {
  assert.deepEqual(parseResourceMutationRequest({
    name: "  Novo nome  ", code: "  novo-01 ", expectedVersion: "3", reason: " Ajuste ", idempotencyKey,
  }, "portfolio", "update"), {
    patch: { name: "Novo nome", code: "NOVO-01" }, expectedVersion: "3", reason: "Ajuste", idempotencyKey,
  });
  assert.equal(parseResourceMutationRequest({ name: "x", expectedVersion: "0", reason: "x", idempotencyKey }, "portfolio", "update"), null);
});

test("Project mutation rejects lifecycle fields and malformed dates", () => {
  assert.equal(parseResourceMutationRequest({ status: "completed", expectedVersion: "1", reason: "x", idempotencyKey }, "project", "update"), null);
  assert.equal(parseResourceMutationRequest({ startDate: "2026-19-90", expectedVersion: "1", reason: "x", idempotencyKey }, "project", "update"), null);
  assert.equal(parseResourceMutationRequest({ expectedVersion: "1", reason: "archive", idempotencyKey, name: "no" }, "project", "archive"), null);
});

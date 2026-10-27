import test from "node:test";
import assert from "node:assert/strict";
import { isValidInvitationToken, parseFirstAdminInvitationRequest } from "../src/modules/identity/application/first-admin-invitation-request.ts";

test("normalizes invited email and trims the audit reason", () => {
  assert.deepEqual(parseFirstAdminInvitationRequest({
    email: "  Admin@Example.com ",
    reason: "  Ativação inicial  ",
  }), { email: "admin@example.com", reason: "Ativação inicial" });
});

test("rejects malformed email, empty reason, and unexpected fields", () => {
  assert.equal(parseFirstAdminInvitationRequest({ email: "admin", reason: "reason" }), null);
  assert.equal(parseFirstAdminInvitationRequest({ email: "admin@example.com", reason: "  " }), null);
  assert.equal(parseFirstAdminInvitationRequest({ email: "admin@example.com", reason: "reason", role: "platform_admin" }), null);
  assert.equal(parseFirstAdminInvitationRequest(null), null);
});

test("accepts only URL-safe 256-bit invitation tokens", () => {
  assert.equal(isValidInvitationToken("A".repeat(43)), true);
  assert.equal(isValidInvitationToken("A".repeat(42)), false);
  assert.equal(isValidInvitationToken("A".repeat(42) + "/"), false);
  assert.equal(isValidInvitationToken(undefined), false);
});

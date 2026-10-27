import assert from "node:assert/strict";
import test from "node:test";
import { parseTenantMemberInvitationRequest } from "../src/modules/identity/application/tenant-member-invitation-request.ts";

const tenantId = "3943c9e9-1fbe-4eb8-8bb0-67d84e2e90b6";
const projectId = "40a5bc3e-cc01-4ff8-9f16-fdb2f67cb24c";

test("legacy invitation body defaults to the route Tenant", () => {
  assert.deepEqual(parseTenantMemberInvitationRequest({
    email: " New.User@example.com ", roleKey: "viewer", reason: " Project access ",
  }, tenantId), {
    email: "new.user@example.com", roleKey: "viewer", reason: "Project access",
    scopeType: "tenant", scopeId: tenantId,
  });
});

test("accepts a valid resource scope while preserving the selected ID", () => {
  assert.deepEqual(parseTenantMemberInvitationRequest({
    email: "new.user@example.com", roleKey: "project_manager", reason: "Assigned project",
    scopeType: "project", scopeId: projectId,
  }, tenantId), {
    email: "new.user@example.com", roleKey: "project_manager", reason: "Assigned project",
    scopeType: "project", scopeId: projectId,
  });
});

test("rejects a mismatched Tenant scope and malformed or partial resource scope", () => {
  const base = { email: "new.user@example.com", roleKey: "viewer", reason: "Access" };
  assert.equal(parseTenantMemberInvitationRequest({ ...base, scopeType: "tenant", scopeId: projectId }, tenantId), null);
  assert.equal(parseTenantMemberInvitationRequest({ ...base, scopeType: "project", scopeId: "not-a-uuid" }, tenantId), null);
  assert.equal(parseTenantMemberInvitationRequest({ ...base, scopeType: "project" }, tenantId), null);
  assert.equal(parseTenantMemberInvitationRequest({ ...base, extra: true }, tenantId), null);
});

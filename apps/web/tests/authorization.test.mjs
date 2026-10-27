import assert from "node:assert/strict";
import test from "node:test";
import { authorize } from "../src/modules/identity/domain/authorization.ts";

function fixture() {
  return {
    actor: { id: "alice", active: true, sessionValid: true },
    tenant: { id: "tenant-a", status: "active" },
    membership: { userId: "alice", tenantId: "tenant-a", status: "active" },
    resource: { tenantId: "tenant-a", scope: { type: "project", id: "project-a" } },
    permission: "project.view", dataPolicyAllows: true, workflowAllows: true, now: 1000,
    grants: [{ tenantId: "tenant-a", subjectId: "alice", permission: "project.view",
      scope: { type: "project", id: "project-a" }, effect: "allow",
      startsAt: 1000, expiresAt: 2000, revokedAt: null }],
  };
}

test("AC-003-01: exact scope with all requirements allows", () => {
  assert.deepEqual(authorize(fixture()), { allowed: true, reason: "allowed" });
});

test("malformed authorization inputs deny instead of throwing", () => {
  const missingGrants = fixture();
  missingGrants.grants = null;
  assert.deepEqual(authorize(missingGrants), { allowed: false, reason: "invalid_context" });

  const malformedScope = fixture();
  malformedScope.grants[0].scope = null;
  assert.deepEqual(authorize(malformedScope), { allowed: false, reason: "invalid_context" });

  const malformedResource = fixture();
  malformedResource.resource.scope = { type: "project", id: " " };
  assert.deepEqual(authorize(malformedResource), { allowed: false, reason: "invalid_context" });
});

test("a malformed deny grant fails closed", () => {
  const input = fixture();
  input.grants.push({ ...input.grants[0], effect: "deny", scope: null });
  assert.deepEqual(authorize(input), { allowed: false, reason: "invalid_context" });
});

const deniedCases = {
  "missing session": (x) => { x.actor = null; },
  "invalid session": (x) => { x.actor.sessionValid = false; },
  "inactive identity": (x) => { x.actor.active = false; },
  "missing tenant": (x) => { x.tenant = null; },
  "suspended tenant": (x) => { x.tenant.status = "suspended"; },
  "terminating tenant": (x) => { x.tenant.status = "termination_pending"; },
  "missing membership": (x) => { x.membership = null; },
  "revoked membership": (x) => { x.membership.status = "revoked"; },
  "forged actor": (x) => { x.actor.id = "mallory"; },
  "other tenant membership": (x) => { x.membership.tenantId = "tenant-b"; },
  "other tenant resource": (x) => { x.resource.tenantId = "tenant-b"; },
  "other tenant grant": (x) => { x.grants[0].tenantId = "tenant-b"; },
  "other subject grant": (x) => { x.grants[0].subjectId = "bob"; },
  "forged resource": (x) => { x.resource.scope.id = "project-b"; },
  "no grant": (x) => { x.grants = []; },
  "financial permission separate": (x) => { x.permission = "financial.view"; },
  "no implicit tenant inheritance": (x) => { x.grants[0].scope = { type: "tenant", id: "tenant-a" }; },
  "data policy": (x) => { x.dataPolicyAllows = false; },
  "workflow": (x) => { x.workflowAllows = false; },
  "revoked grant": (x) => { x.grants[0].revokedAt = 999; },
  "future grant": (x) => { x.grants[0].startsAt = 1001; },
  "expiry boundary": (x) => { x.now = 2000; },
  "invalid clock": (x) => { x.now = NaN; },
  "invalid grant lifetime": (x) => { x.grants[0].expiresAt = NaN; },
  "platform capability": (x) => { x.permission = x.grants[0].permission = "platform.projects.purge"; },
};
for (const [name, mutate] of Object.entries(deniedCases)) {
  test(`AC-003-02/04/06/07: ${name} denies`, () => {
    const input = fixture(); mutate(input);
    assert.equal(authorize(input).allowed, false);
  });
}

test("AC-003-03: explicit deny wins in either order", () => {
  const input = fixture();
  input.grants.push({ ...input.grants[0], effect: "deny" });
  for (let i = 0; i < 2; i++) {
    assert.deepEqual(authorize(input), { allowed: false, reason: "explicit_deny" });
    input.grants.reverse();
  }
});

test("AC-003-06: each evaluation rechecks grant and membership", () => {
  const input = fixture();
  assert.equal(authorize(input).allowed, true);
  input.grants[0].revokedAt = 1000;
  assert.equal(authorize(input).allowed, false);
  input.grants[0].revokedAt = null;
  input.membership.status = "revoked";
  assert.equal(authorize(input).allowed, false);
});

test("TC-003-03: potentially intersecting deny fails closed before ancestry support", () => {
  const input = fixture();
  input.grants.push({ ...input.grants[0], effect: "deny", scope: { type: "tenant", id: "tenant-a" } });
  assert.equal(authorize(input).allowed, false);
});

test("TC-003-09: publication does not authorize correction", () => {
  const input = fixture();
  input.permission = input.grants[0].permission = "status.update.publish";
  assert.equal(authorize(input).allowed, true);
  input.permission = "status.update.correct";
  assert.equal(authorize(input).allowed, false);
});

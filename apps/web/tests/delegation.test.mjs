import assert from "node:assert/strict";
import test from "node:test";
import { canDelegateRole, getRolePermissionsForScope } from "../src/modules/identity/domain/delegation.ts";

function fixture() {
  return {
    actor: { id: "alice", active: true, sessionValid: true },
    tenant: { id: "tenant-a", status: "active" },
    membership: { userId: "alice", tenantId: "tenant-a", status: "active" },
    targetRole: {
      id: "role-pmo", tenantId: "tenant-a", scopeType: "tenant", status: "active",
      permissions: ["membership.invite", "project.view", "project.edit", "portfolio.view"],
    },
    targetScope: { type: "project", id: "project-a" },
    targetScopeTenantId: "tenant-a",
    grants: [],
    now: 1000,
  };
}

function allow(permission, scope = { type: "project", id: "project-a" }) {
  return {
    tenantId: "tenant-a", subjectId: "alice", permission, scope,
    effect: "allow", startsAt: 1000, expiresAt: null, revokedAt: null,
  };
}

test("filters a preset to permissions supported by the selected resource scope", () => {
  assert.deepEqual(
    getRolePermissionsForScope(
      ["membership.invite", "project.view", "project.edit", "portfolio.view"],
      "project",
    ),
    ["project.view", "project.edit"],
  );
});

test("scope permissions must be delegated at the exact resource while invite permission stays Tenant-scoped", () => {
  const input = fixture();
  input.grants = [
    allow("membership.invite", { type: "tenant", id: "tenant-a" }),
    allow("project.view"),
    allow("project.edit"),
  ];
  assert.deepEqual(canDelegateRole(input), { allowed: true, reason: "allowed" });

  input.grants.pop();
  assert.deepEqual(canDelegateRole(input), { allowed: false, reason: "delegation_ceiling" });
});

test("Tenant-scoped resource permissions do not authorize delegation on a Project", () => {
  const input = fixture();
  input.grants = [
    allow("membership.invite", { type: "tenant", id: "tenant-a" }),
    allow("project.view", { type: "tenant", id: "tenant-a" }),
    allow("project.edit", { type: "tenant", id: "tenant-a" }),
  ];
  assert.deepEqual(canDelegateRole(input), { allowed: false, reason: "delegation_ceiling" });
});

test("unknown, duplicate, or platform permissions invalidate scoped delegation", () => {
  assert.equal(getRolePermissionsForScope(["project.view", "unknown.permission"], "project"), null);
  assert.equal(getRolePermissionsForScope(["project.view", "project.view"], "project"), null);
  assert.equal(getRolePermissionsForScope(["platform.projects.purge"], "project"), null);
});

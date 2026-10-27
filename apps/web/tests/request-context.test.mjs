import assert from "node:assert/strict";
import test from "node:test";
import { resolveRequestContext } from "../src/modules/identity/application/resolve-request-context.ts";

const actorA = "4c5a5062-fdef-4c7e-87bb-b1ac89516346";
const actorB = "50cc5ac0-09a8-42f0-ad5f-56d38c05c579";
const tenantA = "3943c9e9-1fbe-4eb8-8bb0-67d84e2e90b6";
const tenantB = "d2fda4d7-89a8-42e5-9f5d-6d5a8c8f7d1f";
const membershipA = "8c0f5dda-6c57-4fac-8ee9-5f0db78cc0d0";
const membershipB = "3881e9bb-04ce-4d4d-b86f-6d9c36e44e82";
const correlationId = "50fd756f-e4d9-40b2-976c-2aad68c3d7d1";

function candidate({
  membershipId = membershipA,
  actorId = actorA,
  tenantId = tenantA,
  membershipStatus = "active",
  tenantStatus = "active",
  tenantName = "Tenant A",
} = {}) {
  return { membershipId, actorId, tenantId, membershipStatus, tenantStatus, tenantName };
}

function port({ actorId = actorA, memberships = [candidate()], membershipError = false } = {}) {
  return {
    getAuthenticatedActorId: async () => actorId,
    listMemberships: async (requestedActorId) => {
      assert.equal(requestedActorId, actorId?.toLowerCase());
      if (membershipError) return { ok: false };
      return { ok: true, memberships };
    },
  };
}

test("selected tenant resolves only from an active membership of the authenticated actor", async () => {
  const result = await resolveRequestContext(port(), tenantA, correlationId);

  assert.deepEqual(result, {
    ok: true,
    context: {
      actorId: actorA,
      tenantId: tenantA,
      tenantName: "Tenant A",
      membershipId: membershipA,
      correlationId,
    },
  });
});

test("forged actor membership is ignored and cannot authorize a selected tenant", async () => {
  const result = await resolveRequestContext(port({ memberships: [candidate({ actorId: actorB })] }), tenantA, correlationId);

  assert.deepEqual(result, { ok: false, reason: "forbidden", correlationId });
});

test("a forged or cross-tenant selector is denied without revealing available tenants", async () => {
  const result = await resolveRequestContext(port({ memberships: [candidate()] }), tenantB, correlationId);

  assert.deepEqual(result, { ok: false, reason: "forbidden", correlationId });
});

test("suspended or revoked membership and suspended tenant cannot resolve context", async () => {
  for (const item of [
    candidate({ membershipStatus: "suspended" }),
    candidate({ membershipStatus: "revoked" }),
    candidate({ tenantStatus: "suspended" }),
  ]) {
    const result = await resolveRequestContext(port({ memberships: [item] }), tenantA, correlationId);
    assert.deepEqual(result, { ok: false, reason: "forbidden", correlationId });
  }
});

test("multiple active tenants require an explicit selector and only list owned memberships", async () => {
  const memberships = [
    candidate(),
    candidate({ membershipId: membershipB, tenantId: tenantB, tenantName: "Tenant B" }),
    candidate({ actorId: actorB, tenantId: "9b4ef253-7b7f-4db1-8b7d-664f7686b672", tenantName: "Forged" }),
  ];
  const result = await resolveRequestContext(port({ memberships }), undefined, correlationId);

  assert.deepEqual(result, {
    ok: false,
    reason: "tenant_selection_required",
    correlationId,
    availableTenants: [
      { tenantId: tenantA, name: "Tenant A" },
      { tenantId: tenantB, name: "Tenant B" },
    ],
  });
});

test("invalid selectors, malformed membership IDs, and unavailable membership reads fail closed", async () => {
  assert.deepEqual(
    await resolveRequestContext(port(), "tenant-a", correlationId),
    { ok: false, reason: "invalid_tenant", correlationId },
  );
  assert.deepEqual(
    await resolveRequestContext(port({ memberships: [candidate({ tenantId: "tenant-a" })] }), undefined, correlationId),
    { ok: false, reason: "context_unavailable", correlationId },
  );
  assert.deepEqual(
    await resolveRequestContext(port({ membershipError: true }), tenantA, correlationId),
    { ok: false, reason: "context_unavailable", correlationId },
  );
});

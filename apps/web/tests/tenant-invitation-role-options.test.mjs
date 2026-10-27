import assert from "node:assert/strict";
import test from "node:test";
import { getDelegableTenantInvitationRoleKeys } from "../src/modules/identity/domain/tenant-invitation-role-options.ts";

test("Tenant Admin only sees a Tenant role it can delegate at Tenant scope", () => {
  assert.deepEqual(getDelegableTenantInvitationRoleKeys(["tenant_admin"]), ["tenant_admin"]);
});

test("PMO Admin has no Tenant-scope preset that fits its current permission ceiling", () => {
  assert.deepEqual(getDelegableTenantInvitationRoleKeys(["pmo_admin"]), []);
});

test("unknown roles do not create invitation choices", () => {
  assert.deepEqual(getDelegableTenantInvitationRoleKeys(["custom_admin"]), []);
});

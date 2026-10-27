import assert from "node:assert/strict";
import test from "node:test";
import { parsePortfolioCreateRequest, parseProjectCreateRequest } from "../src/modules/identity/application/resource-create-request.ts";

const id = "3943c9e9-1fbe-4eb8-8bb0-67d84e2e90b6";
const key = "3943c9e9-1fbe-4eb8-8bb0-67d84e2e90b7";

test("Portfolio create trims values and normalizes optional code", () => {
  assert.deepEqual(parsePortfolioCreateRequest({
    name: "  Plataforma  ", code: " pmo-01 ", category: " Estratégico ",
    reason: "  Novo portfólio  ", idempotencyKey: key,
  }), {
    name: "Plataforma", code: "PMO-01", sponsorId: null, category: "Estratégico",
    startDate: null, targetEndDate: null, reason: "Novo portfólio", idempotencyKey: key,
  });
});

test("Portfolio create rejects invalid dates, tenant authority and excessive fields", () => {
  assert.equal(parsePortfolioCreateRequest({ name: "P", category: "C", reason: "R", idempotencyKey: key, startDate: "2026-02-30" }), null);
  assert.equal(parsePortfolioCreateRequest({ name: "P", category: "C", reason: "R", idempotencyKey: key, tenantId: id }), null);
  assert.equal(parsePortfolioCreateRequest({ name: "P", category: "C", reason: "R", idempotencyKey: key, code: "x".repeat(41) }), null);
});

test("Project create defaults priority and rejects malformed scope or reversed dates", () => {
  assert.deepEqual(parseProjectCreateRequest({ portfolioId: id, name: "  MVP  ", reason: " Planejado ", idempotencyKey: key }), {
    portfolioId: id, name: "MVP", code: null, sponsorId: null, priority: "medium", scopeSummary: null,
    startDate: null, targetEndDate: null, reason: "Planejado", idempotencyKey: key,
  });
  assert.equal(parseProjectCreateRequest({ portfolioId: "bad", name: "MVP", reason: "R", idempotencyKey: key }), null);
  assert.equal(parseProjectCreateRequest({ portfolioId: id, name: "MVP", reason: "R", idempotencyKey: key, startDate: "2026-05-02", targetEndDate: "2026-05-01" }), null);
});

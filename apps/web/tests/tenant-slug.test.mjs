import assert from "node:assert/strict";
import test from "node:test";
import { generateTenantSlug } from "../src/modules/identity/domain/tenant-slug.ts";

test("generates a stable lowercase slug and removes Portuguese diacritics", () => {
  assert.equal(generateTenantSlug("  Fundação Ágil & Projetos  "), "fundacao-agil-projetos");
});

test("normalizes decomposed Unicode accents and punctuation", () => {
  assert.equal(generateTenantSlug("Cafe\u0301 / PMO"), "cafe-pmo");
});

test("collapses separators and trims leading and trailing hyphens", () => {
  assert.equal(generateTenantSlug("---PMO---   Control!!!"), "pmo-control");
});

test("caps identifiers at 63 characters and removes a trailing separator", () => {
  const slug = generateTenantSlug(`${"a".repeat(62)} organização`);
  assert.ok(slug && slug.length <= 63);
  assert.equal(slug?.endsWith("-"), false);
});

test("rejects names that cannot produce a valid minimum-length identifier", () => {
  assert.equal(generateTenantSlug(""), null);
  assert.equal(generateTenantSlug("AB"), null);
  assert.equal(generateTenantSlug("  !!!  "), null);
  assert.equal(generateTenantSlug("😀😀😀"), null);
  assert.equal(generateTenantSlug("组织"), null);
});

test("rejects non-string input without throwing", () => {
  assert.equal(generateTenantSlug(null), null);
  assert.equal(generateTenantSlug(undefined), null);
});

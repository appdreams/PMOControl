import assert from "node:assert/strict";
import { readFile, readdir } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";

const apiRoot = fileURLToPath(new URL("../src/app/api/v1/", import.meta.url));

async function findRouteFiles(directory) {
  const entries = await readdir(directory, { withFileTypes: true });
  const nested = await Promise.all(entries.map(async (entry) => {
    const entryPath = path.join(directory, entry.name);
    if (entry.isDirectory()) return findRouteFiles(entryPath);
    return entry.isFile() && entry.name === "route.ts" ? [entryPath] : [];
  }));
  return nested.flat();
}

test("every API mutation route enforces the shared same-origin policy directly or through its shared handler", async () => {
  const routeFiles = await findRouteFiles(apiRoot);
  const mutationRoutes = [];

  for (const routeFile of routeFiles) {
    const source = await readFile(routeFile, "utf8");
    if (!/export\s+async\s+function\s+(?:POST|PATCH|DELETE)\b/.test(source)) continue;
    mutationRoutes.push(routeFile);
    assert.match(
      source,
      /isTrustedSameOriginRequest|mutateTenantResource/,
      `${path.relative(apiRoot, routeFile)} must enforce the shared same-origin policy`,
    );
  }

  assert.ok(mutationRoutes.length > 0, "the route scan must find API mutation handlers");
});

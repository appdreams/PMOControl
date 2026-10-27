import assert from "node:assert/strict";
import test from "node:test";
import { isTrustedSameOriginRequest } from "../src/server/infrastructure/http/same-origin-policy.ts";

const appOrigin = "https://pmo.example.com";

function request(headers = {}) {
  return new Request(`${appOrigin}/api/v1/session/tenant`, { method: "POST", headers });
}

function sameOriginHeaders(overrides = {}) {
  return {
    origin: appOrigin,
    host: "pmo.example.com",
    ...overrides,
  };
}

test("allows the configured origin only when Host matches it exactly", () => {
  const environment = { APP_ORIGIN: appOrigin, NODE_ENV: "production" };
  assert.equal(isTrustedSameOriginRequest(request(sameOriginHeaders()), environment), true);
  assert.equal(isTrustedSameOriginRequest(request(sameOriginHeaders({ host: "pmo.example.com:443" })), environment), false);
});

test("rejects missing Origin or Host and never trusts forwarded headers", () => {
  const environment = { APP_ORIGIN: appOrigin, NODE_ENV: "production" };
  assert.equal(isTrustedSameOriginRequest(request({ host: "pmo.example.com" }), environment), false);
  assert.equal(isTrustedSameOriginRequest(request({ origin: appOrigin }), environment), false);
  assert.equal(isTrustedSameOriginRequest(request({
    host: "attacker.example",
    origin: "https://attacker.example",
    "x-forwarded-host": "pmo.example.com",
    "x-forwarded-proto": "https",
  }), environment), false);
});

test("rejects a different origin, host, credentials, or malformed host", () => {
  const environment = { APP_ORIGIN: appOrigin, NODE_ENV: "production" };
  assert.equal(isTrustedSameOriginRequest(request(sameOriginHeaders({ origin: "https://evil.example" })), environment), false);
  assert.equal(isTrustedSameOriginRequest(request(sameOriginHeaders({ host: "evil.example" })), environment), false);
  assert.equal(isTrustedSameOriginRequest(request(sameOriginHeaders({ host: "user@pmo.example.com" })), environment), false);
  assert.equal(isTrustedSameOriginRequest(request(sameOriginHeaders({ host: "bad host" })), environment), false);
});

test("rejects production without a configured origin and rejects unsafe origin configuration", () => {
  assert.equal(isTrustedSameOriginRequest(request(sameOriginHeaders()), { NODE_ENV: "production" }), false);
  for (const APP_ORIGIN of ["http://pmo.example.com", "https://user:pass@pmo.example.com", "https://pmo.example.com/app", "not-a-url"]) {
    assert.equal(isTrustedSameOriginRequest(request(sameOriginHeaders()), { APP_ORIGIN, NODE_ENV: "production" }), false);
  }
});

test("allows the documented local development origin but still requires matching Host", () => {
  const environment = { NODE_ENV: "development" };
  assert.equal(isTrustedSameOriginRequest(request({
    origin: "http://localhost:3000",
    host: "localhost:3000",
  }), environment), true);
  assert.equal(isTrustedSameOriginRequest(request({
    origin: "http://localhost:3000",
    host: "127.0.0.1:3000",
    "x-forwarded-host": "localhost:3000",
  }), environment), false);
});

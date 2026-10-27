import assert from "node:assert/strict";
import test from "node:test";
import { createApiErrorResponse, logApiFailure } from "../src/server/infrastructure/http/api-response.ts";

test("API errors use the shared envelope and return the same request ID header", async () => {
  const originalError = console.error;
  console.error = () => {};
  let response;
  try {
    response = createApiErrorResponse(503, "SERVICE_UNAVAILABLE", "Try again later.", "request-123", {
      "Cache-Control": "private, no-store",
    });
  } finally {
    console.error = originalError;
  }

  assert.equal(response.status, 503);
  assert.equal(response.headers.get("x-request-id"), "request-123");
  assert.equal(response.headers.get("cache-control"), "private, no-store");
  assert.deepEqual(await response.json(), {
    error: { code: "SERVICE_UNAVAILABLE", message: "Try again later.", requestId: "request-123" },
  });
});

test("unclassified 5xx responses are logged once with a correlated safe event", () => {
  const originalError = console.error;
  const output = [];
  console.error = (value) => output.push(value);
  try {
    createApiErrorResponse(503, "SERVICE_UNAVAILABLE", "Try again.", "request-789");
    logApiFailure({ requestId: "request-789", operation: "api.handler", error: new Error("sensitive") });
  } finally {
    console.error = originalError;
  }

  assert.equal(output.length, 1);
  assert.deepEqual(JSON.parse(output[0]), {
    event: "api.unexpected_failure",
    requestId: "request-789",
    operation: "api.unclassified_failure",
    errorType: "UnknownError",
  });
  assert.equal(output[0].includes("sensitive"), false);
});

test("server diagnostics include correlation and error type without serializing exception content", () => {
  const originalError = console.error;
  const output = [];
  console.error = (value) => output.push(value);
  try {
    logApiFailure({
      requestId: "request-456",
      operation: "POST /api/v1/tenants",
      error: new Error("password=must-not-be-logged"),
    });
  } finally {
    console.error = originalError;
  }

  assert.equal(output.length, 1);
  assert.deepEqual(JSON.parse(output[0]), {
    event: "api.unexpected_failure",
    requestId: "request-456",
    operation: "POST /api/v1/tenants",
    errorType: "Error",
  });
  assert.equal(output[0].includes("must-not-be-logged"), false);
});

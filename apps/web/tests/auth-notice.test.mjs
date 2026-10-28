import assert from "node:assert/strict";
import test from "node:test";
import { getAuthNotice } from "../src/modules/identity/application/auth-notice.ts";

test("expired sessions show a safe reauthentication message", () => {
  assert.equal(
    getAuthNotice({ session: "expired" }),
    "Sua sessão terminou ou não é mais válida. Entre novamente para continuar.",
  );
});

test("successful password recovery prompts the user to sign in", () => {
  assert.equal(getAuthNotice({ passwordUpdated: "1" }), "Senha atualizada. Entre com sua nova senha.");
});

test("unknown auth notice query values are ignored", () => {
  assert.equal(getAuthNotice({ session: "forged", passwordUpdated: "true" }), "");
});

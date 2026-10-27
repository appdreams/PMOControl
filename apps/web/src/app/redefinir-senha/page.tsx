import { redirect } from "next/navigation";
import { Suspense } from "react";
import { PasswordResetForm } from "../PasswordResetForm";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";
import { getSupabasePublicConfig } from "@/server/infrastructure/supabase/config";

async function ResetPasswordContent() {
  if (!getSupabasePublicConfig()) redirect("/recuperar-senha");
  try {
    const supabase = await createSupabaseServerClient();
    const { data } = await supabase.auth.getClaims();
    if (typeof data?.claims?.sub !== "string") redirect("/recuperar-senha?link=invalid");
  } catch {
    redirect("/recuperar-senha?link=invalid");
  }

  return <main className="auth-standalone"><PasswordResetForm /></main>;
}

export default function ResetPasswordPage() {
  return <Suspense fallback={<main className="auth-standalone" aria-busy="true"><p role="status">Validando link de recuperação…</p></main>}>
    <ResetPasswordContent />
  </Suspense>;
}

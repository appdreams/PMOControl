import { NextResponse, type NextRequest } from "next/server";
import { createSupabaseServerClient } from "@/server/infrastructure/supabase/server";

export async function GET(request: NextRequest) {
  const code = request.nextUrl.searchParams.get("code");
  if (!code) return NextResponse.redirect(new URL("/recuperar-senha?link=invalid", request.url));

  try {
    const supabase = await createSupabaseServerClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);
    if (error) return NextResponse.redirect(new URL("/recuperar-senha?link=invalid", request.url));
    return NextResponse.redirect(new URL("/redefinir-senha", request.url));
  } catch {
    return NextResponse.redirect(new URL("/recuperar-senha?link=invalid", request.url));
  }
}

"use client";

import { createBrowserClient } from "@supabase/ssr";
import { getSupabasePublicConfig } from "./config";

/** Only uses the publishable key. Never place service-role keys in this module. */
export function createSupabaseBrowserClient() {
  const config = getSupabasePublicConfig();
  if (!config) throw new Error("Supabase Auth is not configured.");
  return createBrowserClient(config.url, config.key);
}

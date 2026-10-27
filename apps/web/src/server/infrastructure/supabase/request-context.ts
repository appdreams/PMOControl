import "server-only";

import { randomUUID } from "node:crypto";
import {
  resolveRequestContext,
  type ActiveMembershipCandidate,
  type RequestContextPort,
} from "@/modules/identity/application/resolve-request-context";
import { createSupabaseServerClient } from "./server";
import { getSupabasePublicConfig } from "./config";

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function toMembershipCandidates(value: unknown): readonly ActiveMembershipCandidate[] | null {
  if (!Array.isArray(value)) return null;

  const candidates: ActiveMembershipCandidate[] = [];
  for (const row of value) {
    if (!isRecord(row) || !isRecord(row.tenants)) return null;
    const tenant = row.tenants;
    if (
      typeof row.id !== "string" || typeof row.user_id !== "string" || typeof row.tenant_id !== "string" ||
      typeof row.status !== "string" || typeof tenant.id !== "string" || typeof tenant.status !== "string" ||
      typeof tenant.display_name !== "string" ||
      tenant.id !== row.tenant_id
    ) {
      return null;
    }
    candidates.push({
      membershipId: row.id,
      actorId: row.user_id,
      tenantId: row.tenant_id,
      tenantName: tenant.display_name,
      membershipStatus: row.status,
      tenantStatus: tenant.status,
    });
  }

  return candidates;
}

function createSupabaseRequestContextPort(): RequestContextPort {
  return {
    async getAuthenticatedActorId() {
      const supabase = await createSupabaseServerClient();
      const { data, error } = await supabase.auth.getClaims();
      if (error) {
        if (error.status === 401 || error.status === 403) return null;
        throw error;
      }
      const subject = data?.claims?.sub;
      return typeof subject === "string" ? subject : null;
    },

    async listMemberships(actorId) {
      const supabase = await createSupabaseServerClient();
      const { data, error } = await supabase
        .from("memberships")
        .select("id,user_id,tenant_id,status,tenants!inner(id,status,display_name)")
        .eq("user_id", actorId)
        .eq("status", "active")
        .eq("tenants.status", "active");

      if (error) return { ok: false };
      const memberships = toMembershipCandidates(data);
      if (!memberships) return { ok: false };
      return { ok: true, memberships };
    },
  };
}

/** Resolves fresh identity/membership state for one server request. Never cached. */
export async function resolveSupabaseRequestContext(tenantSelector?: unknown) {
  const correlationId = randomUUID();
  if (!getSupabasePublicConfig()) {
    return { ok: false as const, reason: "context_unavailable" as const, correlationId };
  }

  return resolveRequestContext(createSupabaseRequestContextPort(), tenantSelector, correlationId);
}

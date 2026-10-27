/**
 * Versioned application-owned RBAC catalog (SPEC-003 / F1-06).
 * Presets are defaults for scoped role assignments, never standalone authority.
 * Keep every permission exact: wildcard keys and implicit inheritance are not supported.
 */
export const PERMISSION_CATALOG_VERSION = "rbac-v1" as const;

export type PermissionScopeType = "platform" | "tenant" | "portfolio" | "project" | "resource" | "item";
export type PermissionDefinition = Readonly<{
  key: string;
  resourceType: string;
  action: string;
  scopeTypes: readonly PermissionScopeType[];
  dataClassification: "public" | "internal" | "confidential" | "restricted";
  sensitive: boolean;
  inheritance: "none";
}>;

const TENANT = ["tenant"] as const satisfies readonly PermissionScopeType[];
const PORTFOLIO = ["portfolio"] as const satisfies readonly PermissionScopeType[];
const PROJECT = ["project"] as const satisfies readonly PermissionScopeType[];
const PROJECT_OR_ITEM = ["project", "item"] as const satisfies readonly PermissionScopeType[];
const PLATFORM = ["platform"] as const satisfies readonly PermissionScopeType[];
const PLATFORM_OR_TENANT = ["platform", "tenant"] as const satisfies readonly PermissionScopeType[];
const REPORT_SCOPES = ["platform", "tenant", "portfolio", "project"] as const satisfies readonly PermissionScopeType[];

const define = <const K extends string>(
  key: K,
  resourceType: string,
  action: string,
  scopeTypes: readonly PermissionScopeType[],
  sensitive = false,
  dataClassification: PermissionDefinition["dataClassification"] = sensitive ? "confidential" : "internal",
) => ({ key, resourceType, action, scopeTypes, sensitive, dataClassification, inheritance: "none" } as const);

export const PERMISSION_DEFINITIONS = [
  define("tenant.lifecycle.create", "tenant", "create", PLATFORM, true, "restricted"),
  define("tenant.lifecycle.suspend", "tenant", "suspend", PLATFORM, true, "restricted"),
  define("tenant.lifecycle.reactivate", "tenant", "reactivate", PLATFORM, true, "restricted"),
  define("tenant.lifecycle.terminate", "tenant", "terminate", PLATFORM, true, "restricted"),
  define("platform.quotas.view", "platform.quotas", "view", PLATFORM),
  define("platform.health.view", "platform.health", "view", PLATFORM),
  define("platform.projects.purge", "platform.projects", "purge", PLATFORM, true, "restricted"),
  define("tenant.export.request", "tenant.export", "request", PLATFORM_OR_TENANT, true, "restricted"),
  define("tenant.export.download", "tenant.export", "download", PLATFORM_OR_TENANT, true, "restricted"),
  define("tenant.export.validate", "tenant.export", "validate", PLATFORM_OR_TENANT, true, "restricted"),
  define("tenant.export.dispute", "tenant.export", "dispute", TENANT, true, "restricted"),
  define("tenant.export.dispute.resolve", "tenant.export.dispute", "resolve", PLATFORM, true, "restricted"),
  define("tenant.admin.transfer.request", "tenant.admin.transfer", "request", TENANT, true, "restricted"),
  define("tenant.admin.transfer.confirm", "tenant.admin.transfer", "confirm", TENANT, true, "restricted"),

  define("membership.view", "membership", "view", TENANT),
  define("membership.manage", "membership", "manage", TENANT, true),
  define("membership.invite", "membership", "invite", TENANT, true),
  define("membership.revoke", "membership", "revoke", TENANT, true),
  define("membership.grant", "membership", "grant", TENANT, true),
  define("tenant.settings.view", "tenant.settings", "view", TENANT),
  define("tenant.settings.edit", "tenant.settings", "edit", TENANT, true),

  define("portfolio.view", "portfolio", "view", PORTFOLIO),
  define("portfolio.create", "portfolio", "create", TENANT),
  define("portfolio.edit", "portfolio", "edit", PORTFOLIO),
  define("portfolio.archive", "portfolio", "archive", PORTFOLIO, true),
  define("portfolio.projects.associate", "portfolio.projects", "associate", PORTFOLIO, true),
  define("portfolio.projects.remove", "portfolio.projects", "remove", PORTFOLIO, true),
  define("project.view", "project", "view", PROJECT),
  define("project.create", "project", "create", PORTFOLIO),
  define("project.edit", "project", "edit", PROJECT),
  define("project.archive", "project", "archive", PROJECT, true),
  define("project.assign", "project", "assign", PROJECT, true),

  define("milestone.view", "milestone", "view", PROJECT),
  define("milestone.create", "milestone", "create", PROJECT),
  define("milestone.edit", "milestone", "edit", PROJECT),
  define("milestone.forecast", "milestone", "forecast", PROJECT),
  define("milestone.complete", "milestone", "complete", PROJECT),
  define("deliverable.view", "deliverable", "view", PROJECT),
  define("deliverable.create", "deliverable", "create", PROJECT),
  define("deliverable.edit", "deliverable", "edit", PROJECT),
  define("deliverable.deliver", "deliverable", "deliver", PROJECT),
  define("deliverable.accept", "deliverable", "accept", PROJECT, true),
  define("deliverable.reject", "deliverable", "reject", PROJECT, true),
  define("risk.view", "risk", "view", PROJECT),
  define("risk.create", "risk", "create", PROJECT),
  define("risk.edit", "risk", "edit", PROJECT),
  define("risk.assess", "risk", "assess", PROJECT),
  define("risk.respond", "risk", "respond", PROJECT),
  define("risk.materialize", "risk", "materialize", PROJECT, true),
  define("risk.close", "risk", "close", PROJECT, true),
  define("issue.view", "issue", "view", PROJECT),
  define("issue.create", "issue", "create", PROJECT),
  define("issue.edit", "issue", "edit", PROJECT),
  define("issue.assign", "issue", "assign", PROJECT),
  define("issue.resolve", "issue", "resolve", PROJECT),
  define("issue.close", "issue", "close", PROJECT, true),
  define("issue.link-risk", "issue", "link-risk", PROJECT),
  define("action.view", "action", "view", PROJECT_OR_ITEM),
  define("action.create", "action", "create", PROJECT),
  define("action.edit", "action", "edit", PROJECT_OR_ITEM),
  define("action.reassign", "action", "reassign", PROJECT_OR_ITEM, true),
  define("action.complete", "action", "complete", PROJECT_OR_ITEM),
  define("action.cancel", "action", "cancel", PROJECT_OR_ITEM, true),
  define("decision.view", "decision", "view", PROJECT),
  define("decision.create", "decision", "create", PROJECT),
  define("decision.edit", "decision", "edit", PROJECT_OR_ITEM),
  define("decision.approve", "decision", "approve", PROJECT_OR_ITEM, true),
  define("decision.reject", "decision", "reject", PROJECT_OR_ITEM, true),
  define("decision.defer", "decision", "defer", PROJECT_OR_ITEM),
  define("decision.comment", "decision", "comment", PROJECT_OR_ITEM),
  define("dependency.view", "dependency", "view", PROJECT),
  define("dependency.create", "dependency", "create", PROJECT),
  define("dependency.edit", "dependency", "edit", PROJECT),
  define("dependency.resolve", "dependency", "resolve", PROJECT),
  define("dependency.view-impact", "dependency", "view-impact", PROJECT),

  define("status.update.view", "status.update", "view", PROJECT),
  define("status.update.draft", "status.update", "draft", PROJECT),
  define("status.update.publish", "status.update", "publish", PROJECT, true),
  define("status.update.correct", "status.update", "correct", PROJECT, true),
  define("projects.{projectid}.rag-evaluations.evaluate", "rag-evaluation", "evaluate", PROJECT),
  define("projects.{projectid}.rag-evaluations.override", "rag-evaluation", "override", PROJECT, true),
  define("projects.{projectid}.snapshots.view", "snapshot", "view", PROJECT),
  define("projects.{projectid}.snapshots.verify", "snapshot", "verify", PROJECT),

  define("financial.view", "financial", "view", PROJECT, true),
  define("financial.edit", "financial", "edit", PROJECT, true, "restricted"),
  define("financial.export", "financial", "export", PROJECT, true, "restricted"),
  define("resources.view", "resources", "view", PROJECT, true),
  define("resources.edit", "resources", "edit", PROJECT, true),
  define("documents.view", "documents", "view", PROJECT),
  define("documents.confidential.view", "documents", "confidential-view", PROJECT, true, "restricted"),
  define("baseline.change", "baseline", "change", PROJECT, true, "restricted"),
  define("project.data.import", "project.data", "import", PROJECT, true),
  define("project.data.import.replace", "project.data", "import-replace", PROJECT, true, "restricted"),
  define("audit.view", "audit", "view", TENANT, true),
  define("audit.export", "audit", "export", TENANT, true, "restricted"),
  define("report.export", "report", "export", REPORT_SCOPES, true, "restricted"),
  define("support.access", "support", "access", PLATFORM, true, "restricted"),
  define("ai.config.view", "ai.config", "view", TENANT),
  define("ai.config.manage", "ai.config", "manage", TENANT, true),
  define("ai.cost.view", "ai.cost", "view", TENANT, true),
  define("ai.cost.export", "ai.cost", "export", TENANT, true, "restricted"),
] as const satisfies readonly PermissionDefinition[];

export type PermissionKey = (typeof PERMISSION_DEFINITIONS)[number]["key"] |
  `projects.${string}.rag-evaluations.evaluate` |
  `projects.${string}.rag-evaluations.override` |
  `projects.${string}.snapshots.view` |
  `projects.${string}.snapshots.verify`;

const permissionIndex = new Map<string, PermissionDefinition>(
  PERMISSION_DEFINITIONS.map((permission) => [permission.key, permission]),
);
const permissionTemplates = PERMISSION_DEFINITIONS
  .filter((permission) => permission.key.includes("{"))
  .map((permission) => {
    const pattern = permission.key
      .split(/(\{[^}]+\})/g)
      .map((part) => part.startsWith("{") ? "[^.]+" : part.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"))
      .join("");
    return { definition: permission, matcher: new RegExp(`^${pattern}$`) };
  });

export function getPermissionDefinition(key: string): PermissionDefinition | null {
  const exact = permissionIndex.get(key);
  if (exact) return exact;
  return permissionTemplates.find(({ matcher }) => matcher.test(key))?.definition ?? null;
}

export function isPermissionKey(key: string): key is PermissionKey {
  return getPermissionDefinition(key) !== null;
}

export type RolePreset = Readonly<{
  name: string;
  scopeType: "platform" | "tenant";
  initialPermissions: readonly PermissionKey[];
}>;

/** Defaults only; provisioning must materialize a scoped role and explicit grants. */
export const ROLE_PRESETS = {
  platform_admin: {
    name: "Platform Admin",
    scopeType: "platform",
    initialPermissions: ["tenant.lifecycle.create", "tenant.lifecycle.suspend", "tenant.lifecycle.reactivate", "tenant.lifecycle.terminate", "platform.quotas.view", "platform.health.view"],
  },
  platform_root_admin: {
    name: "Platform Root Admin",
    scopeType: "platform",
    initialPermissions: ["platform.projects.purge"],
  },
  tenant_admin: {
    name: "Tenant Admin",
    scopeType: "tenant",
    initialPermissions: ["membership.view", "membership.manage", "membership.invite", "membership.revoke", "membership.grant", "portfolio.create", "tenant.settings.view", "tenant.settings.edit"],
  },
  pmo_admin: {
    name: "PMO Admin",
    scopeType: "tenant",
    initialPermissions: ["portfolio.view", "portfolio.create", "portfolio.edit", "portfolio.archive", "portfolio.projects.associate", "portfolio.projects.remove", "project.view", "project.create", "project.edit", "project.archive", "project.assign", "membership.view", "membership.manage", "membership.invite", "membership.revoke", "membership.grant", "status.update.view", "status.update.draft", "audit.view"],
  },
  pmo: {
    name: "PMO",
    scopeType: "tenant",
    initialPermissions: ["portfolio.view", "project.view", "project.create", "project.edit", "milestone.view", "milestone.create", "milestone.edit", "deliverable.view", "deliverable.create", "deliverable.edit", "risk.view", "risk.create", "risk.edit", "issue.view", "issue.create", "issue.edit", "action.view", "action.create", "action.edit", "decision.view", "decision.create", "dependency.view", "dependency.create", "dependency.edit", "status.update.view", "status.update.draft"],
  },
  project_manager: {
    name: "Project Manager",
    scopeType: "tenant",
    initialPermissions: ["project.view", "project.edit", "milestone.view", "milestone.create", "milestone.edit", "milestone.forecast", "milestone.complete", "deliverable.view", "deliverable.create", "deliverable.edit", "deliverable.deliver", "risk.view", "risk.create", "risk.edit", "risk.assess", "risk.respond", "issue.view", "issue.create", "issue.edit", "issue.assign", "issue.resolve", "action.view", "action.create", "action.edit", "action.reassign", "action.complete", "decision.view", "decision.create", "decision.edit", "decision.comment", "dependency.view", "dependency.create", "dependency.edit", "dependency.resolve", "status.update.view", "status.update.draft", "status.update.publish"],
  },
  contributor: {
    name: "Contributor",
    scopeType: "tenant",
    initialPermissions: ["project.view", "milestone.view", "deliverable.view", "deliverable.deliver", "action.view", "action.edit", "action.complete", "decision.view", "decision.comment"],
  },
  executive: {
    name: "Executive",
    scopeType: "tenant",
    initialPermissions: ["portfolio.view", "project.view", "status.update.view", "projects.{projectid}.snapshots.view"],
  },
  viewer: {
    name: "Viewer",
    scopeType: "tenant",
    initialPermissions: ["portfolio.view", "project.view", "milestone.view", "deliverable.view", "risk.view", "issue.view", "action.view", "decision.view", "dependency.view", "status.update.view", "projects.{projectid}.snapshots.view"],
  },
} as const satisfies Readonly<Record<string, RolePreset>>;

export type RolePresetKey = keyof typeof ROLE_PRESETS;

export function getRolePreset(key: string): RolePreset | null {
  return Object.hasOwn(ROLE_PRESETS, key) ? ROLE_PRESETS[key as RolePresetKey] : null;
}

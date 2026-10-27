const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const VERSION = /^[1-9]\d{0,18}$/;
const DATE = /^\d{4}-\d{2}-\d{2}$/;
const PRIORITIES = new Set(["low", "medium", "high", "critical"]);
type Resource = "portfolio" | "project";
type Mutation = "update" | "archive";
type Row = Record<string, unknown>;
const isRow = (value: unknown): value is Row => typeof value === "object" && value !== null && !Array.isArray(value);

export function parseResourceMutationRequest(value: unknown, resource: Resource, action: Mutation) {
  if (!isRow(value) || typeof value.expectedVersion !== "string" || !VERSION.test(value.expectedVersion) ||
      typeof value.reason !== "string" || value.reason.trim().length < 1 || value.reason.trim().length > 1000 ||
      typeof value.idempotencyKey !== "string" || !UUID.test(value.idempotencyKey)) return null;
  const allowed = resource === "portfolio"
    ? ["name", "code", "sponsorId", "category", "startDate", "targetEndDate"]
    : ["name", "code", "sponsorId", "priority", "scopeSummary", "startDate", "targetEndDate"];
  const controls = ["expectedVersion", "reason", "idempotencyKey"];
  if (Object.keys(value).some((key) => !controls.includes(key) && (action === "archive" || !allowed.includes(key)))) return null;
  const patch: Row = {};
  if (action === "archive") {
    if (Object.keys(value).some((key) => !controls.includes(key))) return null;
  } else {
    for (const key of allowed) {
      if (!(key in value)) continue;
      const current = value[key];
      if (["name", "category", "priority"].includes(key)) {
        if (typeof current !== "string" || current.trim().length < 1 || current.trim().length > (key === "category" ? 80 : 160)) return null;
        if (key === "priority" && !PRIORITIES.has(current)) return null;
        patch[key] = current.trim();
      } else if (key === "code" || key === "scopeSummary") {
        if (current !== null && typeof current !== "string") return null;
        const normalized = typeof current === "string" ? current.trim() : null;
        if (normalized && normalized.length > (key === "code" ? 40 : 2000)) return null;
        patch[key] = normalized ? (key === "code" ? normalized.toUpperCase() : normalized) : null;
      } else if (key === "sponsorId") {
        if (current !== null && (typeof current !== "string" || !UUID.test(current))) return null;
        patch[key] = typeof current === "string" ? current.toLowerCase() : null;
      } else if (key === "startDate" || key === "targetEndDate") {
        if (current !== null) {
          if (typeof current !== "string" || !DATE.test(current)) return null;
          const date = new Date(`${current}T00:00:00.000Z`);
          if (Number.isNaN(date.valueOf()) || date.toISOString().slice(0, 10) !== current) return null;
        }
        patch[key] = current;
      }
    }
    if (Object.keys(patch).length === 0) return null;
    const start = patch.startDate;
    const end = patch.targetEndDate;
    if (typeof start === "string" && typeof end === "string" && end < start) return null;
  }
  return { patch, expectedVersion: value.expectedVersion, reason: value.reason.trim(), idempotencyKey: value.idempotencyKey.toLowerCase() };
}

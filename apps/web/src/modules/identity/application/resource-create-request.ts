const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const DATE = /^\d{4}-\d{2}-\d{2}$/;
const PRIORITIES = new Set(["low", "medium", "high", "critical"]);

type RecordValue = Record<string, unknown>;
const isRecord = (value: unknown): value is RecordValue =>
  typeof value === "object" && value !== null && !Array.isArray(value);
const hasOnly = (value: RecordValue, allowed: readonly string[]) =>
  Object.keys(value).every((key) => allowed.includes(key));
function optionalText(value: unknown, max: number): string | null | undefined {
  if (value === undefined) return null;
  if (value === null) return null;
  if (typeof value !== "string") return undefined;
  const normalized = value.trim();
  if (normalized.length === 0) return null;
  return normalized.length <= max ? normalized : undefined;
}
function optionalUuid(value: unknown): string | null | undefined {
  if (value === undefined) return null;
  if (value === null) return null;
  if (typeof value !== "string" || !UUID.test(value)) return undefined;
  return value.toLowerCase();
}
function optionalDate(value: unknown): string | null | undefined {
  if (value === undefined) return null;
  if (value === null) return null;
  if (typeof value !== "string" || !DATE.test(value)) return undefined;
  const date = new Date(`${value}T00:00:00.000Z`);
  return !Number.isNaN(date.valueOf()) && date.toISOString().slice(0, 10) === value ? value : undefined;
}

export function parsePortfolioCreateRequest(value: unknown) {
  if (!isRecord(value) || !hasOnly(value, ["name", "code", "sponsorId", "category", "startDate", "targetEndDate", "reason", "idempotencyKey"])) return null;
  if (typeof value.name !== "string" || typeof value.category !== "string" ||
      typeof value.reason !== "string" || typeof value.idempotencyKey !== "string" || !UUID.test(value.idempotencyKey)) return null;
  const name = value.name.trim();
  const category = value.category.trim();
  const reason = value.reason.trim();
  const code = optionalText(value.code, 40);
  const sponsorId = optionalUuid(value.sponsorId);
  const startDate = optionalDate(value.startDate);
  const targetEndDate = optionalDate(value.targetEndDate);
  if (name.length < 1 || name.length > 160 || category.length < 1 || category.length > 80 ||
      reason.length < 1 || reason.length > 1000 || code === undefined || sponsorId === undefined ||
      startDate === undefined || targetEndDate === undefined ||
      (startDate && targetEndDate && targetEndDate < startDate)) return null;
  return {
    name, code: code?.toUpperCase() ?? null, sponsorId: sponsorId ?? null,
    category, startDate: startDate ?? null, targetEndDate: targetEndDate ?? null,
    reason, idempotencyKey: value.idempotencyKey.toLowerCase(),
  };
}

export function parseProjectCreateRequest(value: unknown) {
  if (!isRecord(value) || !hasOnly(value, ["portfolioId", "name", "code", "sponsorId", "priority", "scopeSummary", "startDate", "targetEndDate", "reason", "idempotencyKey"])) return null;
  if (typeof value.portfolioId !== "string" || !UUID.test(value.portfolioId) ||
      typeof value.name !== "string" || typeof value.reason !== "string" ||
      typeof value.idempotencyKey !== "string" || !UUID.test(value.idempotencyKey)) return null;
  const name = value.name.trim();
  const reason = value.reason.trim();
  const code = optionalText(value.code, 40);
  const sponsorId = optionalUuid(value.sponsorId);
  const priority = value.priority === undefined ? "medium" : value.priority;
  const scopeSummary = optionalText(value.scopeSummary, 2000);
  const startDate = optionalDate(value.startDate);
  const targetEndDate = optionalDate(value.targetEndDate);
  if (name.length < 1 || name.length > 160 || reason.length < 1 || reason.length > 1000 ||
      code === undefined || sponsorId === undefined || typeof priority !== "string" || !PRIORITIES.has(priority) ||
      scopeSummary === undefined || startDate === undefined || targetEndDate === undefined ||
      (startDate && targetEndDate && targetEndDate < startDate)) return null;
  return {
    portfolioId: value.portfolioId.toLowerCase(), name, code: code?.toUpperCase() ?? null,
    sponsorId: sponsorId ?? null, priority: priority as "low" | "medium" | "high" | "critical", scopeSummary: scopeSummary ?? null,
    startDate: startDate ?? null, targetEndDate: targetEndDate ?? null,
    reason, idempotencyKey: value.idempotencyKey.toLowerCase(),
  };
}

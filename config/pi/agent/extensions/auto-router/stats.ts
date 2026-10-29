import type { LogRecord, RouteRecord, UsageRecord } from "./log.ts";

const RECENT_FORCED = 5;

function percent(part: number, whole: number): string {
  return `${Math.round((part / whole) * 100)}%`;
}

function plural(count: number, noun: string): string {
  return `${count} ${noun}${count === 1 ? "" : "s"}`;
}

function money(amount: number): string {
  return `$${amount.toFixed(amount < 1 ? 4 : 2)}`;
}

function spend(usage: UsageRecord[], routes: RouteRecord[]): string {
  const judge = routes.reduce((sum, record) => sum + (record.judge?.cost ?? 0), 0);
  const cost = usage.reduce((sum, record) => sum + record.cost, 0) + judge;
  const baseline = usage.reduce((sum, record) => sum + record.baselineCost, 0);
  if (!baseline) return "no spend recorded";
  const saved = Math.round((1 - cost / baseline) * 100);
  return `${money(cost)} vs ≈${money(baseline)} all on the top tier (${saved >= 0 ? "−" : "+"}${Math.abs(saved)}%)`;
}

/** Summary of the decision log; `tiers` cheapest first, `session` the current session id. */
export function summarize(records: LogRecord[], tiers: string[], session: string): string {
  const routes = records.filter((record): record is RouteRecord => record.kind === "route");
  const usage = records.filter((record): record is UsageRecord => record.kind === "usage");
  if (!routes.length) return "auto-router: no decisions logged yet";

  const sessions = new Set(routes.map((record) => record.session)).size;
  const share = tiers.map(
    (tier) => `${tier} ${percent(routes.filter((r) => r.tier === tier).length, routes.length)}`,
  );
  const judgeSwitches = routes.filter(
    (r) => r.source === "judge" && r.from && r.from !== r.tier,
  ).length;
  const forced = routes.filter((r) => r.source === "hint");
  const forcedByTier = tiers.flatMap((tier) => {
    const count = forced.filter((r) => r.tier === tier).length;
    return count ? [`/${tier} ${count}`] : [];
  });
  const manual = records.filter((record) => record.kind === "manual").length;
  const judged = routes.flatMap((r) => (r.judge ? [r.judge] : []));
  const failures = judged.filter((trace) => trace.error).length;
  const avgMs = judged.length
    ? judged.reduce((sum, trace) => sum + trace.ms, 0) / judged.length
    : 0;
  const judgeCost = judged.reduce((sum, trace) => sum + (trace.cost ?? 0), 0);

  const lines = [
    `auto-router since ${routes[0]!.ts.slice(0, 10)}: ${plural(routes.length, "message")} in ${plural(sessions, "session")}`,
    `routed    ${share.join(" · ")}`,
    `switches  ${judgeSwitches} by the judge · ${forced.length} forced${forcedByTier.length ? ` (${forcedByTier.join(", ")})` : ""} · ${manual} manual /model`,
    `judge     avg ${(avgMs / 1000).toFixed(1)}s · ${failures} failed · ${money(judgeCost)}`,
    `spend     ${spend(usage, routes)}`,
    `session   ${spend(
      usage.filter((r) => r.session === session),
      routes.filter((r) => r.session === session),
    )}`,
  ];
  const recent = forced.slice(-RECENT_FORCED);
  if (recent.length) {
    lines.push("recently forced:");
    for (const record of recent) {
      const excerpt = record.signals.userMessage.slice(0, 60).replace(/\s+/g, " ");
      lines.push(
        `  ${record.ts.slice(5, 10)} ${record.from ?? "new"} → /${record.tier} "${excerpt}"`,
      );
    }
  }
  return lines.join("\n");
}

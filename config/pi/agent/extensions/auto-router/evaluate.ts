import type { ExtensionContext } from "@earendil-works/pi-coding-agent";
import { config, policySettings } from "./config.ts";
import cases from "./eval/cases.json";
import { judge } from "./judge.ts";
import type { LogRecord } from "./log.ts";
import { type Conversation, decide } from "./policy.ts";
import { DEFAULT_OUTPUT_TOKENS, type Signals } from "./transcript.ts";

const CONCURRENCY = 4;
const MAX_FAILURES_SHOWN = 15;

export const EVAL_SETS = ["cases", "log", "all"] as const;
export type EvalSet = (typeof EVAL_SETS)[number];

interface Case {
  name: string;
  signals: Signals;
  conversation: Conversation;
  /** Acceptable final tiers. */
  expected: string[];
}

interface CaseFile {
  name: string;
  currentTier: string | null;
  userMessage: string;
  previousAssistantMessage?: string;
  skillsUsed?: string[];
  userTurns?: number;
  /** Prompt tokens of the conversation so far; decides whether a cheaper tier pays off. */
  contextTokens?: number;
  /** A tier, several acceptable tiers, or "keep" for the current tier. */
  expect: string | string[];
}

function fromFile(entry: CaseFile): Case {
  const { name, expect, currentTier, userMessage, previousAssistantMessage } = entry;
  const expected = (Array.isArray(expect) ? expect : [expect]).map((tier) =>
    tier === "keep" ? currentTier! : tier,
  );
  return {
    name,
    expected,
    signals: {
      currentTier,
      userMessage,
      previousAssistantMessage,
      skillsUsed: entry.skillsUsed ?? [],
      userTurns: entry.userTurns ?? 1,
    },
    conversation: {
      contextTokens: entry.contextTokens ?? 0,
      outputPerRequest: DEFAULT_OUTPUT_TOKENS,
    },
  };
}

/** Messages the user forced with /opus, /sonnet or /haiku are labels: the user chose that tier. */
function fromLog(records: LogRecord[]): Case[] {
  return records.flatMap((record) => {
    if (record.kind !== "route" || record.source !== "hint") return [];
    const excerpt = record.signals.userMessage.slice(0, 50).replace(/\s+/g, " ");
    return [
      {
        name: `${record.ts.slice(0, 10)} "${excerpt}"`,
        expected: [record.tier],
        // The judge never saw these: replay them from the tier the session was on.
        signals: { ...record.signals, currentTier: record.from ?? null },
        conversation: record.conversation,
      },
    ];
  });
}

async function pool<T, R>(items: T[], run: (item: T) => Promise<R>): Promise<R[]> {
  const results: R[] = new Array(items.length);
  let next = 0;
  const worker = async () => {
    while (next < items.length) {
      const index = next++;
      results[index] = await run(items[index]!);
    }
  };
  await Promise.all(Array.from({ length: Math.min(CONCURRENCY, items.length) }, worker));
  return results;
}

export async function runEval(
  ctx: ExtensionContext,
  set: EvalSet,
  log: LogRecord[],
): Promise<string> {
  const selected = [
    ...(set === "log" ? [] : (cases as CaseFile[]).map(fromFile)),
    ...(set === "cases" ? [] : fromLog(log)),
  ];
  if (!selected.length) {
    return `auto-router eval: no ${set === "log" ? "forced messages in the log" : "cases"} to replay`;
  }

  const settings = policySettings(ctx);
  const results = await pool(selected, async (testCase) => {
    const judged = await judge(ctx, config, testCase.signals, undefined);
    const decision = decide({
      ...settings,
      current: testCase.signals.currentTier ?? undefined,
      verdict: judged.verdict,
      conversation: testCase.conversation,
      // Cooldown depends on session history, which a replayed message does not have.
      sinceSwitch: config.cooldownMessages,
    });
    return { testCase, judged, decision, pass: testCase.expected.includes(decision.tier) };
  });

  const passed = results.filter((result) => result.pass).length;
  const ms = results.reduce((sum, result) => sum + result.judged.ms, 0) / results.length;
  const cost = results.reduce((sum, result) => sum + (result.judged.cost ?? 0), 0);
  const lines = [
    `auto-router eval (${set}): ${passed}/${results.length} passed · judge avg ${Math.round(ms)}ms · $${cost.toFixed(4)}`,
  ];
  const failures = results.filter((result) => !result.pass);
  for (const { testCase, judged, decision } of failures.slice(0, MAX_FAILURES_SHOWN)) {
    const verdict = judged.verdict
      ? `judge ${judged.verdict.decision}/${judged.verdict.work} ${judged.verdict.confidence.toFixed(2)}`
      : `judge error: ${judged.error}`;
    lines.push(
      `✗ ${testCase.name}: want ${testCase.expected.join("|")}, got ${decision.tier} (${verdict}; ${decision.reason})`,
    );
  }
  if (failures.length > MAX_FAILURES_SHOWN)
    lines.push(`… ${failures.length - MAX_FAILURES_SHOWN} more`);
  return lines.join("\n");
}

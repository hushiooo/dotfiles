import { appendFileSync, existsSync, mkdirSync, readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { getAgentDir } from "@earendil-works/pi-coding-agent";
import type { JudgeTrace } from "./judge.ts";
import type { Conversation, Decision } from "./policy.ts";
import type { Signals } from "./transcript.ts";

/** Added by the logger to every record. */
interface Stamp {
  ts: string;
  session: string;
}

/** One routing decision for a message the user wrote. */
export interface RouteRecord extends Decision, Stamp {
  kind: "route";
  /** Absent when a hint or pin skipped the judge. */
  judge?: JudgeTrace;
  /** What the judge saw, or would have seen when a hint or pin skipped it. Replayed by `/router eval`. */
  signals: Signals;
  conversation: Conversation;
}

/** Spend of one agent run on router/auto. */
export interface UsageRecord extends Stamp {
  kind: "usage";
  cost: number;
  /** The same tokens priced on the most expensive tier. */
  baselineCost: number;
}

/** The user left router/auto for a physical model. */
export interface ManualRecord extends Stamp {
  kind: "manual";
  from?: string;
  to: string;
}

export type LogRecord = RouteRecord | UsageRecord | ManualRecord;
type Unstamped<T> = T extends unknown ? Omit<T, keyof Stamp> : never;
/** A record before the logger stamps it. */
export type LogDraft = Unstamped<LogRecord>;

// Overridable so test runs do not pollute the real log.
const path =
  process.env.PI_AUTO_ROUTER_LOG ?? join(getAgentDir(), "auto-router", "decisions.jsonl");

export function append(record: LogRecord) {
  mkdirSync(dirname(path), { recursive: true });
  appendFileSync(path, `${JSON.stringify(record)}\n`);
}

export function readLog(): LogRecord[] {
  if (!existsSync(path)) return [];
  return readFileSync(path, "utf8")
    .split("\n")
    .flatMap((line) => {
      if (!line.trim()) return [];
      try {
        return [JSON.parse(line) as LogRecord];
      } catch {
        return [];
      }
    });
}

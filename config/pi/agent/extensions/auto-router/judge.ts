import type { ExtensionContext } from "@earendil-works/pi-coding-agent";
import { findModel, type RouterConfig } from "./config.ts";
import type { Verdict } from "./policy.ts";
import { clip, type Signals, text } from "./transcript.ts";

const MAX_TOKENS = 200;

/** How a judge call went, kept with the decision it informed. */
export interface JudgeTrace {
  ms: number;
  error?: string;
  cost?: number;
}

export interface JudgeResult extends JudgeTrace {
  verdict?: Verdict;
}

function systemPrompt(config: RouterConfig): string {
  const tiers = config.tiers.map((tier) => `- ${tier.name}: ${tier.use}`).join("\n");
  return `You route a coding agent's requests to the right model. Tiers, cheapest first:
${tiers}

Rules:
- New session (currentTier is none): pick the tier for the work the user starts. If unsure, pick ${config.defaultTier}.
- Ongoing session: answer "keep" unless the work clearly changes phase. A switch makes the new model re-read the whole conversation without cache, so it only pays off when substantial work follows on the new tier:
  - the user approves a plan, a findings list or proposed comments and asks to carry it out: the execution tier;
  - the user starts a new hard design, review or debugging problem: the planning tier;
  - the user starts a substantial new task that the current tier is too weak for.
- Never switch to a cheaper tier for a small follow-up such as a quick question, a commit message or a thank-you: keep.
- Short replies like "yes", "go", "ok do it" continue the current work: judge them by what the previous assistant message proposed.
- work is "small" when an answer or a quick edit follows (a few model calls), "large" for multi-step work such as implementing a plan, applying several fixes or publishing review comments.
- confidence is how sure you are that your decision is right, from 0 to 1.

Reply with JSON only, no prose: {"decision": "<tier name or keep>", "work": "<small or large>", "confidence": <0-1>, "reason": "<at most 8 words>"}`;
}

function parseVerdict(raw: string, config: RouterConfig): Verdict | undefined {
  const json = raw.match(/\{[\s\S]*\}/)?.[0];
  if (!json) return undefined;
  const value = JSON.parse(json) as Partial<Verdict>;
  const names = config.tiers.map((tier) => tier.name);
  const { decision } = value;
  if (typeof decision !== "string" || (decision !== "keep" && !names.includes(decision)))
    return undefined;
  return {
    decision,
    confidence:
      typeof value.confidence === "number" ? Math.min(1, Math.max(0, value.confidence)) : 0,
    reason: String(value.reason ?? "").slice(0, 80),
    // Unclear work counts as small, which never pays for a switch on a long conversation.
    work: value.work === "large" ? "large" : "small",
  };
}

export async function judge(
  ctx: ExtensionContext,
  config: RouterConfig,
  signals: Signals,
  signal: AbortSignal | undefined,
): Promise<JudgeResult> {
  const started = Date.now();
  const timeout = AbortSignal.timeout(config.judge.timeoutMs);
  const input = { ...signals, currentTier: signals.currentTier ?? "none (new session)" };
  const response = await ctx.modelRegistry
    .streamSimple(
      findModel(ctx, config.judge.model),
      {
        systemPrompt: systemPrompt(config),
        messages: [
          { role: "user", content: JSON.stringify(input, null, 2), timestamp: Date.now() },
        ],
      },
      {
        maxTokens: MAX_TOKENS,
        cacheRetention: "none",
        signal: signal ? AbortSignal.any([signal, timeout]) : timeout,
      },
    )
    .result();
  const ms = Date.now() - started;
  const cost = response.usage.cost.total;
  if (timeout.aborted) return { error: `timed out after ${config.judge.timeoutMs}ms`, ms, cost };
  if (response.stopReason === "error" || response.stopReason === "aborted") {
    return { error: response.errorMessage ?? response.stopReason, ms, cost };
  }
  const raw = text(response);
  let verdict: Verdict | undefined;
  try {
    verdict = parseVerdict(raw, config);
  } catch {
    // Malformed JSON is reported like any unreadable answer.
  }
  return verdict
    ? { verdict, ms, cost }
    : { error: `unreadable verdict: ${clip(raw, 120, "head")}`, ms, cost };
}

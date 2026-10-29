export type Work = "small" | "large";

export interface Verdict {
  /** A tier name, or "keep". */
  decision: string;
  confidence: number;
  reason: string;
  /** How much work follows this message. */
  work: Work;
}

export interface Decision {
  tier: string;
  from?: string;
  source: "hint" | "pin" | "judge" | "keep" | "fallback";
  reason: string;
  confidence?: number;
}

/** USD per million tokens, as in the model catalog. */
interface Rates {
  input: number;
  output: number;
  cacheRead: number;
  cacheWrite: number;
}

export interface ModelCost extends Rates {
  /** Higher rates once a request's input exceeds `inputTokensAbove`. */
  tiers?: (Rates & { inputTokensAbove: number })[];
}

export interface Conversation {
  /** Prompt tokens of the next request; 0 for a new session. */
  contextTokens: number;
  /** Average output tokens per request so far. */
  outputPerRequest: number;
}

export interface PolicyInput {
  /** Tier names, cheapest first. */
  tiers: string[];
  /** Tier the session is on; undefined for a new session. */
  current?: string;
  hint?: string;
  pin?: string;
  /** Undefined when the judge failed or was skipped. */
  verdict?: Verdict;
  /** User messages since the last switch. */
  sinceSwitch: number;
  defaultTier: string;
  minConfidence: { down: number; up: number };
  cooldownMessages: number;
  conversation: Conversation;
  /** Catalog prices by tier name. */
  costs: Record<string, ModelCost>;
  /** Requests expected for each amount of work. */
  workRequests: Record<Work, number>;
}

// The same tier lookup as pi-ai's calculateCost, kept here so the policy has no runtime dependency
// and its tests run on plain Node.
function ratesAt(cost: ModelCost, inputTokens: number): Rates {
  let rates: Rates = cost;
  let threshold = -1;
  for (const tier of cost.tiers ?? []) {
    if (inputTokens > tier.inputTokensAbove && tier.inputTokensAbove > threshold) {
      rates = tier;
      threshold = tier.inputTokensAbove;
    }
  }
  return rates;
}

/**
 * What moving the conversation from one model to another costs, and after how many requests the
 * cheaper requests pay it back. The new model writes the whole context into its cache instead of
 * reading the cache the old one holds.
 */
export function switchEconomics(from: ModelCost, to: ModelCost, conversation: Conversation) {
  const { contextTokens, outputPerRequest } = conversation;
  const a = ratesAt(from, contextTokens);
  const b = ratesAt(to, contextTokens);
  const cost = (contextTokens * (b.cacheWrite - a.cacheRead)) / 1e6;
  const saving =
    (contextTokens * (a.cacheRead - b.cacheRead) + outputPerRequest * (a.output - b.output)) / 1e6;
  return { cost, breakEven: saving > 0 ? cost / saving : Number.POSITIVE_INFINITY };
}

export function decide(input: PolicyInput): Decision {
  const { tiers, current, verdict } = input;
  if (input.hint) {
    return { tier: input.hint, from: current, source: "hint", reason: `forced by /${input.hint}` };
  }
  if (input.pin) return { tier: input.pin, from: current, source: "pin", reason: "pinned" };

  const wanted = verdict && tiers.includes(verdict.decision) ? verdict.decision : undefined;
  if (!current) {
    if (verdict && wanted) {
      return {
        tier: wanted,
        source: "judge",
        reason: verdict.reason,
        confidence: verdict.confidence,
      };
    }
    const reason = verdict ? "judge kept, new session" : "judge unavailable";
    return { tier: input.defaultTier, source: "fallback", reason };
  }

  const keep = (reason: string): Decision => ({
    tier: current,
    from: current,
    source: "keep",
    reason,
    confidence: verdict?.confidence,
  });
  if (!verdict) return keep("judge unavailable");
  if (!wanted || wanted === current) return keep(verdict.reason);
  // Every switch rewrites the prompt cache, so the next message stays put to avoid ping-pong.
  if (input.sinceSwitch < input.cooldownMessages) return keep(`cooldown, judge wanted ${wanted}`);

  // Going up rewrites the cache at the expensive model's price, so it needs more certainty. It is not
  // weighed against cost: a harder problem needs the stronger model.
  const up = tiers.indexOf(wanted) > tiers.indexOf(current);
  const threshold = up ? input.minConfidence.up : input.minConfidence.down;
  if (verdict.confidence < threshold) {
    return keep(`unsure (${verdict.confidence.toFixed(2)}), judge wanted ${wanted}`);
  }
  if (!up) {
    const { cost, breakEven } = switchEconomics(
      input.costs[current]!,
      input.costs[wanted]!,
      input.conversation,
    );
    if (cost > 0 && breakEven > input.workRequests[verdict.work]) {
      const after = Number.isFinite(breakEven)
        ? `after ~${Math.ceil(breakEven)} requests`
        : "never";
      return keep(`${wanted} would cost $${cost.toFixed(2)} to switch, pays off ${after}`);
    }
  }
  return {
    tier: wanted,
    from: current,
    source: "judge",
    reason: verdict.reason,
    confidence: verdict.confidence,
  };
}

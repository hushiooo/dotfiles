import assert from "node:assert/strict";
import { test } from "node:test";
import { decide, type PolicyInput, switchEconomics, type Work } from "./policy.ts";

// Catalog prices of the Claude 5.5 models, USD per million tokens.
const costs = {
  haiku: {
    input: 0.1,
    output: 0.5,
    cacheRead: 0.01,
    cacheWrite: 0.125,
    tiers: [
      { inputTokensAbove: 100_000, input: 0.5, output: 2.5, cacheRead: 0.05, cacheWrite: 0.625 },
    ],
  },
  sonnet: { input: 2, output: 10, cacheRead: 0.1, cacheWrite: 2.5 },
  opus: { input: 4, output: 20, cacheRead: 0.2, cacheWrite: 5 },
};

const base: PolicyInput = {
  tiers: ["haiku", "sonnet", "opus"],
  sinceSwitch: 5,
  defaultTier: "sonnet",
  minConfidence: { down: 0.7, up: 0.8 },
  cooldownMessages: 1,
  conversation: { contextTokens: 0, outputPerRequest: 1500 },
  costs,
  workRequests: { small: 2, large: 15 },
};
const verdict = (decision: string, confidence = 0.9, work: Work = "large") => ({
  decision,
  confidence,
  reason: "r",
  work,
});
const context = (contextTokens: number) => ({ contextTokens, outputPerRequest: 1500 });

test("new session takes the judge's tier", () => {
  assert.equal(decide({ ...base, verdict: verdict("opus", 0.3) }).tier, "opus");
});

test("new session falls back to the default tier without a usable verdict", () => {
  assert.equal(decide(base).tier, "sonnet");
  assert.equal(decide({ ...base, verdict: verdict("keep") }).tier, "sonnet");
});

test("hint beats pin, pin beats judge", () => {
  const input = {
    ...base,
    current: "sonnet",
    hint: "haiku",
    pin: "opus",
    verdict: verdict("sonnet"),
  };
  assert.equal(decide(input).tier, "haiku");
  assert.equal(decide({ ...input, hint: undefined }).tier, "opus");
});

test("ongoing session keeps on keep, failure, or the same tier", () => {
  for (const v of [verdict("keep"), undefined, verdict("opus")]) {
    const decision = decide({ ...base, current: "opus", verdict: v });
    assert.equal(decision.tier, "opus");
    assert.equal(decision.source, "keep");
  }
});

test("plan approved: confident downgrade switches", () => {
  const decision = decide({ ...base, current: "opus", verdict: verdict("sonnet", 0.75) });
  assert.deepEqual([decision.tier, decision.from, decision.source], ["sonnet", "opus", "judge"]);
});

test("upgrades need more confidence than downgrades", () => {
  assert.equal(
    decide({ ...base, current: "sonnet", verdict: verdict("opus", 0.75) }).tier,
    "sonnet",
  );
  assert.equal(decide({ ...base, current: "sonnet", verdict: verdict("opus", 0.85) }).tier, "opus");
  assert.equal(decide({ ...base, current: "opus", verdict: verdict("sonnet", 0.65) }).tier, "opus");
});

test("no judge switch right after a judge switch", () => {
  const input = { ...base, current: "sonnet", verdict: verdict("opus", 0.99) };
  assert.equal(decide({ ...input, sinceSwitch: 0 }).tier, "sonnet");
  assert.equal(decide({ ...input, sinceSwitch: 1 }).tier, "opus");
});

test("switch economics at catalog prices", () => {
  const opusToSonnet = switchEconomics(costs.opus, costs.sonnet, context(100_000));
  assert.equal(opusToSonnet.cost.toFixed(2), "0.23");
  assert.equal(Math.ceil(opusToSonnet.breakEven), 10);
  // Above 100k input tokens Haiku's higher rates apply.
  const sonnetToHaiku = switchEconomics(costs.sonnet, costs.haiku, context(150_000));
  assert.equal(sonnetToHaiku.cost.toFixed(3), "0.079");
  assert.equal(Math.ceil(sonnetToHaiku.breakEven), 5);
});

test("a downgrade for little work on a long context is refused", () => {
  const input = { ...base, current: "sonnet", conversation: context(150_000) };
  const small = decide({ ...input, verdict: verdict("haiku", 0.95, "small") });
  assert.deepEqual([small.tier, small.source], ["sonnet", "keep"]);
  assert.match(small.reason, /haiku would cost \$0\.08 to switch, pays off after ~5 requests/);
  assert.equal(decide({ ...input, verdict: verdict("haiku", 0.95, "large") }).tier, "haiku");
});

test("an approved plan moves to the execution tier, a one-off follow-up does not", () => {
  const input = { ...base, current: "opus", conversation: context(100_000) };
  assert.equal(decide({ ...input, verdict: verdict("sonnet", 0.9, "large") }).tier, "sonnet");
  assert.equal(decide({ ...input, verdict: verdict("sonnet", 0.9, "small") }).tier, "opus");
});

test("a downgrade on a short context is cheap enough even for little work", () => {
  const input = { ...base, current: "opus", conversation: context(5_000) };
  assert.equal(decide({ ...input, verdict: verdict("haiku", 0.9, "small") }).tier, "haiku");
});

test("upgrades are not weighed against cost", () => {
  const input = { ...base, current: "haiku", conversation: context(400_000) };
  assert.equal(decide({ ...input, verdict: verdict("opus", 0.9, "small") }).tier, "opus");
});

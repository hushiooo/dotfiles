import type { Api, Model, ModelThinkingLevel } from "@earendil-works/pi-ai";
import type { ExtensionContext } from "@earendil-works/pi-coding-agent";
import raw from "./config.json";
import type { PolicyInput, Work } from "./policy.ts";

export interface Tier {
  name: string;
  /** `provider/model-id` */
  model: string;
  thinking: ModelThinkingLevel;
  /** What the tier is for; the judge reads it. */
  use: string;
}

export interface RouterConfig {
  /** Cheapest first. */
  tiers: Tier[];
  defaultTier: string;
  compactionTier: string;
  judge: { model: string; timeoutMs: number };
  minConfidence: { down: number; up: number };
  cooldownMessages: number;
  /** Requests expected when the judge rates the remaining work small or large. */
  workRequests: Record<Work, number>;
}

/** Fails the extension load on a broken config, so `/reload` reports it instead of the next request. */
function validate(value: RouterConfig): RouterConfig {
  const names = value.tiers.map((tier) => tier.name);
  for (const name of [value.defaultTier, value.compactionTier]) {
    if (!names.includes(name)) {
      throw new Error(`auto-router config: unknown tier "${name}", tiers are ${names.join(", ")}`);
    }
  }
  for (const ref of [...value.tiers.map((tier) => tier.model), value.judge.model]) {
    if (!ref.includes("/"))
      throw new Error(`auto-router config: "${ref}" is not provider/model-id`);
  }
  return value;
}

export const config = validate(raw as RouterConfig);
export const tierNames = config.tiers.map((tier) => tier.name);

/** Catalog model for a `provider/model-id` reference. */
export function findModel(ctx: ExtensionContext, ref: string): Model<Api> {
  const [provider, ...rest] = ref.split("/");
  const model = ctx.modelRegistry.find(provider!, rest.join("/"));
  if (!model) throw new Error(`auto-router: ${ref} is not in the catalog`);
  return model;
}

/** The policy inputs that come from the configuration and the catalog. */
export function policySettings(ctx: ExtensionContext) {
  const { defaultTier, minConfidence, cooldownMessages, workRequests } = config;
  const costs = Object.fromEntries(
    config.tiers.map((tier) => [tier.name, findModel(ctx, tier.model).cost]),
  );
  return {
    tiers: tierNames,
    defaultTier,
    minConfidence,
    cooldownMessages,
    workRequests,
    costs,
  } satisfies Partial<PolicyInput>;
}

/**
 * Auto router: the virtual model `router/auto` picks Haiku, Sonnet or Opus for each user message.
 *
 * A new session gets the tier Haiku judges right for its first message. Later messages keep that
 * tier unless the judge sees a clear phase change (plan approved → execution, new hard problem →
 * planning) and, for a cheaper tier, enough work follows to pay for rewriting the prompt cache.
 * Tool follow-ups and retries always stay on the model that handled the turn. `/opus`, `/sonnet`,
 * `/haiku` force the next message; `/router pin <tier>` locks the session.
 *
 * Development, from the dotfiles root (edits apply after `/reload` in pi):
 *   nix develop -c tsc -p config/pi/agent/extensions/auto-router                    type-check
 *   nix build .#checks.aarch64-darwin.auto-router                                    policy tests
 *   pi -p "/router eval"                                                              judge eval
 */

import { type Api, calculateCost, type Model } from "@earendil-works/pi-ai";
import {
  type ExtensionAPI,
  type ExtensionContext,
  type ModelRoute,
  VIRTUAL_MODEL_STATE_ENTRY,
  type VirtualModelStateData,
} from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { config, findModel, policySettings, type Tier, tierNames } from "./config.ts";
import { EVAL_SETS, type EvalSet, runEval } from "./evaluate.ts";
import { type JudgeResult, type JudgeTrace, judge } from "./judge.ts";
import { append, type LogDraft, readLog } from "./log.ts";
import { type Decision, decide } from "./policy.ts";
import { summarize } from "./stats.ts";
import { buildSignals, conversationOf, isMidTurn, type Signals } from "./transcript.ts";

const PROVIDER = "router";
const ID = "auto";
const STATUS_KEY = "auto-router";
const SUBCOMMANDS = [
  "why",
  "stats",
  ...EVAL_SETS.map((set) => `eval ${set}`),
  ...tierNames.map((name) => `pin ${name}`),
  "unpin",
];

interface RouterState {
  tier: string;
  pin?: string;
  /** User messages since the judge last switched tiers. */
  sinceSwitch: number;
  last: Decision & { judge?: JudgeTrace };
}

function tierByName(name: string): Tier {
  const tier = config.tiers.find((candidate) => candidate.name === name);
  if (!tier) throw new Error(`auto-router: unknown tier ${name}`);
  return tier;
}

function tierOfModel(model: Model<Api>): Tier | undefined {
  return config.tiers.find((tier) => tier.model === `${model.provider}/${model.id}`);
}

function routeTo(
  ctx: ExtensionContext,
  name: string,
  state?: RouterState,
): ModelRoute<RouterState> {
  const tier = tierByName(name);
  return { model: findModel(ctx, tier.model), thinkingLevel: tier.thinking, state };
}

function record(ctx: ExtensionContext, draft: LogDraft) {
  try {
    append({ ts: new Date().toISOString(), session: ctx.sessionManager.getSessionId(), ...draft });
  } catch {
    // The log only feeds stats and eval; it must never break a request.
  }
}

function ownState(data: unknown): RouterState | undefined {
  const stored = data as VirtualModelStateData<RouterState> | undefined;
  return stored?.provider === PROVIDER && stored.modelId === ID ? stored.state : undefined;
}

function readState(ctx: ExtensionContext): RouterState | undefined {
  for (const entry of ctx.sessionManager.getBranch().toReversed()) {
    if (entry.type !== "custom" || entry.customType !== VIRTUAL_MODEL_STATE_ENTRY) continue;
    const state = ownState(entry.data);
    if (state) return state;
  }
  return undefined;
}

function isSelected(ctx: ExtensionContext): boolean {
  return ctx.model?.provider === PROVIDER && ctx.model.id === ID;
}

function withConfidence(text: string, confidence: number | undefined): string {
  return confidence === undefined ? text : `${text} (${confidence.toFixed(2)})`;
}

/** Command output: a dim chat line in the TUI, stdout in print mode (`pi -p "/router eval"`). */
function show(ctx: ExtensionContext, text: string, level: "info" | "warning" = "info") {
  if (ctx.mode === "print") process.stdout.write(`${text}\n`);
  else ctx.ui.notify(text, level);
}

export default function (pi: ExtensionAPI) {
  // Set by commands, consumed by the next user request. `null` pin means unpin.
  let pendingHint: string | undefined;
  let pendingPin: string | null | undefined;

  function showPin(ctx: ExtensionContext, pin: string | undefined) {
    ctx.ui.setStatus(STATUS_KEY, pin ? `router: pinned ${pin}` : undefined);
  }

  async function runJudge(
    ctx: ExtensionContext,
    signals: Signals,
    signal: AbortSignal | undefined,
  ): Promise<JudgeResult> {
    // The working row is already on screen during a run; a status line would resize the footer.
    ctx.ui.setWorkingMessage("Routing…");
    try {
      return await judge(ctx, config, signals, signal);
    } catch (error) {
      return { error: error instanceof Error ? error.message : String(error), ms: 0 };
    } finally {
      ctx.ui.setWorkingMessage();
    }
  }

  pi.registerVirtualModel<RouterState>({
    provider: PROVIDER,
    id: ID,
    name: "Auto (Haiku/Sonnet/Opus)",
    // Limits of the Claude 5.5 tiers, shown until the first response names the real model.
    contextWindow: 1_000_000,
    maxTokens: 128_000,
    async route(request, ctx) {
      if (request.reason === "direct") return routeTo(ctx, config.compactionTier);
      if (request.reason !== "user") {
        // Tool follow-ups and retries stay on the turn's model to keep the prompt cache and thinking signatures.
        const sticky = request.failed ?? request.previous;
        if (sticky) {
          const thinking = sticky.thinkingLevel ?? tierOfModel(sticky.model)?.thinking ?? "high";
          return { model: sticky.model, thinkingLevel: thinking };
        }
        return routeTo(ctx, request.state?.tier ?? config.defaultTier);
      }

      const state = request.state;
      const hint = pendingHint;
      const pinChanged = pendingPin !== undefined;
      const pin = pinChanged ? (pendingPin ?? undefined) : state?.pin;
      pendingHint = undefined;
      pendingPin = undefined;
      // The model that answered last holds the prompt cache. It differs from the stored tier after a
      // manual /model switch, and it is the starting point when router/auto is selected mid-session.
      const current =
        (request.previous && tierOfModel(request.previous.model)?.name) ?? state?.tier;

      // A message steered into a running turn continues that turn.
      if (current && !hint && !pinChanged && isMidTurn(request.messages)) {
        return routeTo(ctx, current);
      }

      const signals = buildSignals(ctx, request.messages, current);
      const judged = hint || pin ? undefined : await runJudge(ctx, signals, request.signal);
      // Pi stores returned state before sending, so an aborted request must not record a decision.
      if (request.signal?.aborted) return routeTo(ctx, current ?? config.defaultTier);

      const conversation = conversationOf(request.messages);
      const sinceSwitch = state?.sinceSwitch ?? config.cooldownMessages;
      const decision = decide({
        ...policySettings(ctx),
        current,
        hint,
        pin,
        verdict: judged?.verdict,
        sinceSwitch,
        conversation,
      });
      const judgeSwitched =
        decision.source === "judge" && current !== undefined && decision.tier !== current;
      const next: RouterState = {
        tier: decision.tier,
        pin,
        sinceSwitch: judgeSwitched ? 0 : sinceSwitch + 1,
        last: {
          ...decision,
          judge: judged && { ms: judged.ms, error: judged.error, cost: judged.cost },
        },
      };
      record(ctx, { kind: "route", ...next.last, signals, conversation });
      showPin(ctx, pin);
      if (judged?.error && ctx.hasUI) {
        ctx.ui.notify(
          `auto-router: judge failed (${judged.error}), using ${decision.tier}`,
          "warning",
        );
      }
      return routeTo(ctx, decision.tier, next);
    },
  });

  // Pi stores the router state as a custom entry right before each request; rendering it marks the
  // first pick and every switch in the transcript, where it stays when the session is resumed.
  pi.registerEntryRenderer(VIRTUAL_MODEL_STATE_ENTRY, (entry, _options, theme) => {
    const last = ownState(entry.data)?.last;
    if (!last || last.tier === last.from) return undefined;
    const marker = withConfidence(`↪ ${last.tier} · ${last.reason}`, last.confidence);
    return new Text(theme.fg("dim", marker), 1, 0);
  });

  function why(ctx: ExtensionContext): string {
    const state = readState(ctx);
    if (!state) return "auto-router: no decision yet on this branch";
    const { last } = state;
    const lines = [`tier: ${state.tier}${state.pin ? " (pinned)" : ""}`];
    const move = last.from && last.from !== last.tier ? `${last.from} → ${last.tier}` : last.tier;
    lines.push(
      `${withConfidence(`last: ${last.source}, ${move}`, last.confidence)}: ${last.reason}`,
    );
    if (last.judge) {
      lines.push(
        `judge: ${last.judge.ms}ms${last.judge.error ? `, failed: ${last.judge.error}` : ""}`,
      );
    }
    if (pendingHint) lines.push(`next message: ${pendingHint}`);
    if (pendingPin !== undefined)
      lines.push(`next message: ${pendingPin ? `pin ${pendingPin}` : "unpin"}`);
    return lines.join("\n");
  }

  async function applyCommand(command: string, ctx: ExtensionContext) {
    const [verb, arg] = command.trim().split(/\s+/);
    if (!verb || verb === "why") return show(ctx, why(ctx));
    if (verb === "stats") {
      return show(ctx, summarize(readLog(), tierNames, ctx.sessionManager.getSessionId()));
    }
    if (verb === "eval" && (!arg || EVAL_SETS.includes(arg as EvalSet))) {
      // In the TUI the result replaces this line.
      if (ctx.mode !== "print") show(ctx, "auto-router: evaluating the judge…");
      return show(ctx, await runEval(ctx, (arg as EvalSet | undefined) ?? "all", readLog()));
    }
    if (verb === "unpin") {
      pendingPin = null;
      showPin(ctx, undefined);
      return show(ctx, "auto-router: unpinned from the next message");
    }
    if (verb === "pin" && arg && tierNames.includes(arg)) {
      pendingPin = arg;
      showPin(ctx, arg);
      return show(ctx, `auto-router: pinned to ${arg} from the next message`);
    }
    show(
      ctx,
      `Usage: /router [why | stats | eval [${EVAL_SETS.join("|")}] | pin <${tierNames.join("|")}> | unpin]`,
      "warning",
    );
  }

  pi.registerCommand("router", {
    description: "Auto router: explain the last decision, stats, evaluate the judge, pin or unpin",
    getArgumentCompletions: (prefix) => {
      const matches = SUBCOMMANDS.filter((option) => option.startsWith(prefix.trim()));
      return matches.length ? matches.map((value) => ({ value, label: value })) : null;
    },
    handler: async (args, ctx) => {
      if (args.trim() || !ctx.hasUI) return applyCommand(args, ctx);
      const choice = await ctx.ui.select("Auto router", SUBCOMMANDS);
      if (choice) await applyCommand(choice, ctx);
    },
  });

  for (const tier of config.tiers) {
    pi.registerCommand(tier.name, {
      description: `Send the next message on ${tier.model.split("/").at(-1)} (auto router)`,
      handler: async (args, ctx) => {
        if (!isSelected(ctx)) {
          show(
            ctx,
            `/${tier.name} needs the ${PROVIDER}/${ID} model (select it with /model)`,
            "warning",
          );
          return;
        }
        pendingHint = tier.name;
        const message = args.trim();
        if (!message) return show(ctx, `auto-router: next message on ${tier.name}`);
        // Expansion lets `/opus /skill:pr-review <url>` load the skill like a typed message.
        pi.sendUserMessage(message, {
          expandPromptTemplates: true,
          ...(ctx.isIdle() ? {} : { deliverAs: "followUp" as const }),
        });
      },
    });
  }

  pi.on("session_start", (_event, ctx) => {
    pendingHint = undefined;
    pendingPin = undefined;
    showPin(ctx, readState(ctx)?.pin);
  });
  pi.on("session_tree", (_event, ctx) => showPin(ctx, readState(ctx)?.pin));

  pi.on("agent_end", (event, ctx) => {
    if (!isSelected(ctx)) return;
    const top = findModel(ctx, config.tiers.at(-1)!.model);
    let cost = 0;
    let baselineCost = 0;
    for (const message of event.messages) {
      if (message.role !== "assistant") continue;
      cost += message.usage.cost.total;
      // calculateCost writes into the usage it gets.
      baselineCost += calculateCost(top, {
        ...message.usage,
        cost: { ...message.usage.cost },
      }).total;
    }
    if (cost || baselineCost) record(ctx, { kind: "usage", cost, baselineCost });
  });

  pi.on("model_select", (event, ctx) => {
    const previous = event.previousModel;
    if (event.source === "restore" || previous?.provider !== PROVIDER || previous.id !== ID) return;
    if (event.model.provider === PROVIDER) return;
    const to = `${event.model.provider}/${event.model.id}`;
    record(ctx, { kind: "manual", from: readState(ctx)?.tier, to });
  });
}

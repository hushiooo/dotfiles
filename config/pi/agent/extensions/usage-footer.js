import { isAbsolute, relative, resolve, sep } from "node:path";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const CONTEXT_WARN_PERCENT = 70;
const CONTEXT_ERROR_PERCENT = 90;
const GIT_ICON = "";
const CACHE_ICON = "󰆼";
const THINKING_COLOR = {
  off: "thinkingOff",
  minimal: "thinkingMinimal",
  low: "thinkingLow",
  medium: "thinkingMedium",
  high: "thinkingHigh",
  xhigh: "thinkingXhigh",
  max: "thinkingMax",
};

function formatTokens(count) {
  if (count < 1000) return String(count);
  if (count < 10000) return `${(count / 1000).toFixed(1)}k`;
  if (count < 1000000) return `${Math.round(count / 1000)}k`;
  if (count < 10000000) return `${(count / 1000000).toFixed(1)}M`;
  return `${Math.round(count / 1000000)}M`;
}

function formatCwd(cwd, home) {
  if (!cwd) return "";
  if (!home) return cwd;

  const relativeToHome = relative(resolve(home), resolve(cwd));
  const insideHome =
    relativeToHome === "" ||
    (relativeToHome !== ".." && !relativeToHome.startsWith(`..${sep}`) && !isAbsolute(relativeToHome));
  if (!insideHome) return cwd;
  return relativeToHome === "" ? "~" : `~${sep}${relativeToHome}`;
}

function usageFromEntry(entry) {
  if (entry.type === "message") {
    const role = entry.message?.role;
    if (role === "assistant" || role === "toolResult") {
      return { usage: entry.message.usage, assistant: role === "assistant" };
    }
    return undefined;
  }
  if (entry.type === "branch_summary" || entry.type === "compaction") {
    return { usage: entry.usage, assistant: false };
  }
  return undefined;
}

function usageTotals(ctx) {
  const totals = { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0, cacheHitRate: undefined };
  const entries = ctx.sessionManager.getBranch?.() ?? [];

  for (const entry of entries) {
    const selected = usageFromEntry(entry);
    const usage = selected?.usage;
    if (!usage) continue;

    totals.input += usage.input ?? 0;
    totals.output += usage.output ?? 0;
    totals.cacheRead += usage.cacheRead ?? 0;
    totals.cacheWrite += usage.cacheWrite ?? 0;
    totals.cost += usage.cost?.total ?? 0;

    if (selected.assistant) {
      const prompt = (usage.input ?? 0) + (usage.cacheRead ?? 0) + (usage.cacheWrite ?? 0);
      totals.cacheHitRate = prompt > 0 ? ((usage.cacheRead ?? 0) / prompt) * 100 : undefined;
    }
  }

  return totals;
}

function join(theme, parts) {
  return parts.filter(Boolean).join(theme.fg("dim", " · "));
}

function metric(theme, icon, value) {
  return `${theme.fg("muted", icon)} ${theme.fg("dim", value)}`;
}

function formatContext(ctx, theme) {
  const usage = ctx.getContextUsage?.();
  const window = usage?.contextWindow ?? ctx.model?.contextWindow ?? 0;
  const percent = usage?.percent;
  const label =
    percent == null ? `? / ${formatTokens(window)}` : `${percent.toFixed(1)}% / ${formatTokens(window)}`;

  if (percent > CONTEXT_ERROR_PERCENT) return theme.fg("error", label);
  if (percent > CONTEXT_WARN_PERCENT) return theme.fg("warning", label);
  return theme.fg("dim", label);
}

function formatCache(usage, theme) {
  let value = formatTokens(usage.cacheRead);
  if (usage.cacheWrite) value += ` +${formatTokens(usage.cacheWrite)}`;
  if ((usage.cacheRead > 0 || usage.cacheWrite > 0) && usage.cacheHitRate !== undefined) {
    value += ` ${usage.cacheHitRate.toFixed(0)}%`;
  }
  return metric(theme, CACHE_ICON, value);
}

function formatStats(usage, ctx, theme) {
  const parts = [
    metric(theme, "↑", formatTokens(usage.input)),
    metric(theme, "↓", formatTokens(usage.output)),
    formatCache(usage, theme),
  ];
  if (usage.cost) parts.push(theme.fg("dim", `$${usage.cost.toFixed(3)}`));
  parts.push(formatContext(ctx, theme));
  return join(theme, parts);
}

function shortModel(id) {
  return id.replace(/^claude-/, "");
}

function formatModel(ctx, footerData, statsWidth, width, theme) {
  const model = shortModel(ctx.model?.id || "no-model");
  const parts = [theme.fg("muted", model)];

  if (ctx.model?.reasoning) {
    const thinking = ctx.thinkingLevel || "off";
    if (thinking !== "off") {
      parts.push(theme.fg(THINKING_COLOR[thinking] || "dim", thinking));
    }
  }

  const providerCount = footerData.getAvailableProviderCount?.() ?? 0;
  if (providerCount > 1 && ctx.model?.provider) {
    const withProvider = join(theme, [theme.fg("dim", ctx.model.provider), ...parts]);
    if (statsWidth + 2 + visibleWidth(withProvider) <= width) return withProvider;
  }

  return join(theme, parts);
}

function formatPwd(ctx, footerData, theme) {
  const cwd = formatCwd(
    ctx.sessionManager.getCwd?.() ?? ctx.cwd ?? "",
    process.env.HOME || process.env.USERPROFILE || "",
  );
  const branch = footerData.getGitBranch?.();
  const sessionName = ctx.sessionManager.getSessionName?.() || "";
  const parts = [theme.fg("dim", cwd)];
  if (branch) parts.push(`${theme.fg("muted", GIT_ICON)} ${theme.fg("dim", branch)}`);
  if (sessionName) parts.push(theme.fg("muted", sessionName));
  return join(theme, parts);
}

function formatStatuses(footerData, theme) {
  const statuses = footerData.getExtensionStatuses?.();
  if (!statuses?.size) return "";
  return join(
    theme,
    Array.from(statuses.entries())
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([, text]) =>
        String(text)
          .replace(/[\r\n\t]/g, " ")
          .replace(/ +/g, " ")
          .trim(),
      ),
  );
}

function align(left, right, width) {
  const leftWidth = visibleWidth(left);
  const rightWidth = visibleWidth(right);
  if (leftWidth + 2 + rightWidth <= width) {
    return left + " ".repeat(width - leftWidth - rightWidth) + right;
  }
  if (leftWidth >= width) return truncateToWidth(left, width, "...");
  const room = width - leftWidth - 2;
  return left + "  " + truncateToWidth(right, room, "");
}

export default function usageFooter(pi) {
  pi.on("session_start", async (_event, ctx) => {
    if (!ctx.ui) return;

    ctx.ui.setFooter((tui, theme, footerData) => {
      const unsub = footerData.onBranchChange?.(() => tui.requestRender());
      return {
        dispose() {
          unsub?.();
        },
        invalidate() {},
        render(width) {
          const stats = formatStats(usageTotals(ctx), ctx, theme);
          const model = formatModel(ctx, footerData, visibleWidth(stats), width, theme);
          const lines = [
            truncateToWidth(formatPwd(ctx, footerData, theme), width, theme.fg("dim", "...")),
            align(stats, model, width),
          ];

          const statuses = formatStatuses(footerData, theme);
          if (statuses) {
            lines.push(truncateToWidth(statuses, width, theme.fg("dim", "...")));
          }
          return lines;
        },
      };
    });
  });
}

// Pure text helpers. No pi imports, so everything here is trivially testable.

export const MAX_EXPANDED_LINES = 40;
export const MAX_LABEL_LENGTH = 60;

export function truncate(text, max) {
  return text.length <= max ? text : `${text.slice(0, max - 1)}…`;
}

/** Keeps the first `max` lines and notes how many were dropped. */
export function truncateLines(text, max = MAX_EXPANDED_LINES) {
  const lines = text.split("\n");
  if (lines.length <= max) return text;
  return `${lines.slice(0, max).join("\n")}\n… ${lines.length - max} more lines`;
}

export function countLines(text) {
  return text === "" ? 0 : text.split("\n").length;
}

/** Counts added and removed lines in a unified-style diff. */
export function diffStats(diff) {
  let added = 0;
  let removed = 0;
  for (const line of diff.split("\n")) {
    if (line.startsWith("+") && !line.startsWith("+++")) added++;
    else if (line.startsWith("-") && !line.startsWith("---")) removed++;
  }
  return { added, removed };
}

/** One-line description of a tool call, e.g. `$ pnpm test` or `read src/a.ts`. */
export function describeCall(toolName, args = {}) {
  const target = [args.pattern, args.path].filter(Boolean).join(" ");
  switch (toolName) {
    case "bash":
      return `$ ${firstLine(args.command ?? "")}`;
    case "grep":
    case "find":
      return `${toolName} ${target}`.trim();
    default:
      return `${toolName} ${args.path ?? ""}`.trim();
  }
}

function firstLine(text) {
  return text.split("\n", 1)[0];
}

/** `bash×2 read×1` from `{ bash: 2, read: 1 }`, most used first. */
export function formatCounts(counts) {
  return Object.entries(counts)
    .sort(([, a], [, b]) => b - a)
    .map(([name, count]) => (count > 1 ? `${name}×${count}` : name))
    .join(" ");
}

/** `3 tool calls · bash×2 read · 1 failed` */
export function formatSummary({ counts, failed }) {
  const total = Object.values(counts).reduce((sum, count) => sum + count, 0);
  const parts = [`${total} tool ${total === 1 ? "call" : "calls"}`, formatCounts(counts)];
  if (failed > 0) parts.push(`${failed} failed`);
  return parts.join(" · ");
}

/** Working-indicator text for the tools currently running; undefined restores the default. */
export function formatActivity(labels) {
  if (labels.length === 0) return undefined;
  const latest = truncate(labels[labels.length - 1], MAX_LABEL_LENGTH);
  return labels.length === 1 ? `${latest}…` : `${latest}… (+${labels.length - 1} more)`;
}

/** Plain text of a tool result, preferring an edit's diff over its status message. */
export function resultText(result) {
  if (result.details?.diff) return result.details.diff;
  return result.content
    .filter((block) => block.type === "text")
    .map((block) => block.text)
    .join("\n");
}

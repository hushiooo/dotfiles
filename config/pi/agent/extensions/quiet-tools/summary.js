// One dim line per turn that used hidden tools, e.g. `3 tool calls · bash×2 read`.
// Stored as a custom entry, so it is shown in the transcript but never sent to the model.

import { Text } from "@earendil-works/pi-tui";
import { formatSummary } from "./format.js";
import { HIDDEN_TOOL_NAMES } from "./tools.js";

const ENTRY_TYPE = "quiet-tools:summary";

function summarize(toolResults) {
  const counts = {};
  let failed = 0;

  for (const { toolName, isError } of toolResults) {
    if (!HIDDEN_TOOL_NAMES.has(toolName)) continue;
    counts[toolName] = (counts[toolName] ?? 0) + 1;
    if (isError) failed++;
  }

  return Object.keys(counts).length > 0 ? { counts, failed } : undefined;
}

export function registerTurnSummary(pi) {
  pi.registerEntryRenderer(ENTRY_TYPE, (entry, _options, theme) =>
    entry.data ? new Text(theme.fg("dim", formatSummary(entry.data)), 1, 0) : undefined,
  );

  pi.on("turn_end", async (event, ctx) => {
    if (ctx.mode !== "tui") return;
    const summary = summarize(event.toolResults);
    if (summary) pi.appendEntry(ENTRY_TYPE, summary);
  });
}

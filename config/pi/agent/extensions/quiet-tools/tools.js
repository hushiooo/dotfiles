// Re-registers pi's built-in tools with quieter renderers. Execution is delegated to the
// original implementation, so behaviour (and the model-facing description) is unchanged.

import {
  createBashToolDefinition,
  createEditToolDefinition,
  createFindToolDefinition,
  createGrepToolDefinition,
  createLsToolDefinition,
  createReadToolDefinition,
  createWriteToolDefinition,
} from "@earendil-works/pi-coding-agent";
import { countLines, diffStats } from "./format.js";
import { createRenderers } from "./renderers.js";

const fileChange = (theme, verb, path, detail) =>
  `${theme.fg("toolTitle", verb)} ${theme.fg("accent", path)} ${detail}`;

/** Tools that change files keep a one-line headline visible; the others stay fully hidden. */
const TOOLS = [
  { name: "read", create: createReadToolDefinition },
  { name: "bash", create: createBashToolDefinition },
  { name: "grep", create: createGrepToolDefinition },
  { name: "find", create: createFindToolDefinition },
  { name: "ls", create: createLsToolDefinition },
  {
    name: "edit",
    create: createEditToolDefinition,
    headline(args, result, theme) {
      const { added, removed } = diffStats(result.details?.diff ?? "");
      const detail = `${theme.fg("success", `+${added}`)} ${theme.fg("error", `−${removed}`)}`;
      return fileChange(theme, "edit", args.path, detail);
    },
  },
  {
    name: "write",
    create: createWriteToolDefinition,
    headline(args, _result, theme) {
      const detail = theme.fg("dim", `${countLines(args.content ?? "")} lines`);
      return fileChange(theme, "write", args.path, detail);
    },
  },
];

/** Names of the tools this extension hides completely, for use by the turn summary. */
export const HIDDEN_TOOL_NAMES = new Set(
  TOOLS.filter((tool) => !tool.headline).map((tool) => tool.name),
);

export function registerQuietTools(pi) {
  // Built-in definitions are bound to a cwd; build them lazily per session cwd.
  const definitions = new Map();
  const definitionFor = ({ name, create }, cwd) => {
    const key = `${name}\0${cwd}`;
    if (!definitions.has(key)) definitions.set(key, create(cwd));
    return definitions.get(key);
  };

  for (const tool of TOOLS) {
    pi.registerTool({
      ...tool.create(process.cwd()),
      ...createRenderers(tool.name, tool.headline),
      execute: (toolCallId, params, signal, onUpdate, ctx) =>
        definitionFor(tool, ctx?.cwd ?? process.cwd()).execute(
          toolCallId,
          params,
          signal,
          onUpdate,
          ctx,
        ),
    });
  }
}

// Renderers that keep tool calls out of the transcript until they are asked for.
//
// Visibility policy:
//   - collapsed and succeeded: hidden, or just a `headline` for tools that change files
//   - expanded (Ctrl+O) or failed: the call line plus its output

import { Text } from "@earendil-works/pi-tui";
import { describeCall, resultText, truncateLines } from "./format.js";

// Matches the default `outputPad` so lines align with assistant text.
const PAD_X = 1;

const empty = () => new Text("", 0, 0);
const line = (text) => new Text(text, PAD_X, 0);

const isRevealed = (context) => context.expanded || context.isError;

/**
 * @param {string} toolName
 * @param {(args: object, result: object, theme: object) => string} [headline]
 *   One-line outcome that stays visible even when collapsed.
 */
export function createRenderers(toolName, headline) {
  return {
    // Rendered by the tool itself so a hidden call collapses to zero lines instead of an empty box.
    renderShell: "self",

    renderCall(args, theme, context) {
      if (!isRevealed(context)) return empty();
      return line(theme.fg("toolTitle", describeCall(toolName, args)));
    },

    renderResult(result, { isPartial }, theme, context) {
      if (isPartial) return empty();

      if (isRevealed(context)) {
        const body = truncateLines(resultText(result)).trimEnd();
        if (!body) return empty();
        return line(theme.fg(context.isError ? "error" : "dim", body));
      }

      return headline ? line(headline(context.args, result, theme)) : empty();
    },
  };
}

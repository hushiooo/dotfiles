// Quiet tools: hide built-in tool calls and output (Ctrl+O reveals them), while keeping
// file changes, failures, live activity and a per-turn summary visible.
//
//   tools.js      re-registers built-in tools with quiet renderers
//   renderers.js  visibility policy shared by all tools
//   activity.js   live "what is running" in the working indicator
//   summary.js    per-turn tool summary entry
//   format.js     pure text helpers

import { trackActivity } from "./activity.js";
import { registerTurnSummary } from "./summary.js";
import { registerQuietTools } from "./tools.js";

export default function quietTools(pi) {
  registerQuietTools(pi);
  trackActivity(pi);
  registerTurnSummary(pi);
}

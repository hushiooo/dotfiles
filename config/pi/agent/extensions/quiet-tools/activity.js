// Shows what is running in the working indicator, since hidden tools leave no trace
// in the transcript: `$ pnpm test…`, `read src/a.ts… (+2 more)`.

import { describeCall, formatActivity } from "./format.js";

export function trackActivity(pi) {
  /** toolCallId -> label, in start order. */
  const running = new Map();

  const publish = (ctx) => {
    if (ctx.mode !== "tui") return;
    ctx.ui.setWorkingMessage(formatActivity([...running.values()]));
  };

  const reset = async (_event, ctx) => {
    running.clear();
    publish(ctx);
  };

  pi.on("tool_execution_start", async (event, ctx) => {
    running.set(event.toolCallId, describeCall(event.toolName, event.args));
    publish(ctx);
  });

  pi.on("tool_execution_end", async (event, ctx) => {
    running.delete(event.toolCallId);
    publish(ctx);
  });

  pi.on("agent_end", reset);
  pi.on("session_shutdown", reset);
}

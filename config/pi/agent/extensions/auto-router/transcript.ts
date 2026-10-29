import type { Message } from "@earendil-works/pi-ai";
import type { ExtensionContext } from "@earendil-works/pi-coding-agent";
import type { Conversation } from "./policy.ts";

const MAX_USER_CHARS = 4000;
const MAX_ASSISTANT_CHARS = 1500;
/** Output per request assumed before the session has any. */
export const DEFAULT_OUTPUT_TOKENS = 1500;

/** What the judge sees about one user message. */
export interface Signals {
  /** Null for a new session. */
  currentTier: string | null;
  userMessage: string;
  previousAssistantMessage?: string;
  skillsUsed: string[];
  userTurns: number;
}

export function text(message: Message | undefined): string {
  if (!message) return "";
  if (typeof message.content === "string") return message.content;
  return message.content.flatMap((block) => (block.type === "text" ? [block.text] : [])).join("\n");
}

export function clip(value: string, max: number, keep: "head" | "tail"): string {
  if (value.length <= max) return value;
  return keep === "tail" ? `…${value.slice(-max)}` : `${value.slice(0, max)}…`;
}

/** Whether the request continues a running turn: tool results arrived since the latest response. */
export function isMidTurn(messages: readonly Message[]): boolean {
  const lastResponse = messages.findLastIndex((message) => message.role === "assistant");
  return messages.slice(lastResponse + 1).some((message) => message.role === "toolResult");
}

/** Size of the conversation, for the cost of moving it to another model. */
export function conversationOf(messages: readonly Message[]): Conversation {
  const responses = messages.flatMap((message) => (message.role === "assistant" ? [message] : []));
  const last = responses.at(-1)?.usage;
  const output = responses.reduce((sum, message) => sum + message.usage.output, 0);
  return {
    // The latest response's prompt and output are the prefix of the next request.
    contextTokens: last ? last.input + last.cacheRead + last.cacheWrite + last.output : 0,
    outputPerRequest: responses.length ? output / responses.length : DEFAULT_OUTPUT_TOKENS,
  };
}

function skillsUsed(messages: readonly Message[]): string[] {
  const skills = new Set<string>();
  for (const message of messages) {
    if (message.role !== "assistant") continue;
    for (const block of message.content) {
      if (block.type !== "toolCall" || block.name !== "read") continue;
      const match = String(block.arguments.path ?? "").match(/skills\/([^/]+)\/SKILL\.md$/);
      if (match) skills.add(match[1]!);
    }
  }
  return [...skills];
}

export function buildSignals(
  ctx: ExtensionContext,
  messages: readonly Message[],
  current: string | undefined,
): Signals {
  // Routed messages render extension messages, bash output and summaries as user messages, so the
  // messages the user wrote come from the session branch.
  const userMessages = ctx.sessionManager
    .getBranch()
    .flatMap((entry) =>
      entry.type === "message" && entry.message.role === "user" ? [entry.message] : [],
    );
  // A user turn starts after the latest response, so the latest assistant message is the one the user answers.
  const previousAssistant = messages.findLast((message) => message.role === "assistant");
  return {
    currentTier: current ?? null,
    userMessage: clip(text(userMessages.at(-1)), MAX_USER_CHARS, "head"),
    previousAssistantMessage:
      clip(text(previousAssistant), MAX_ASSISTANT_CHARS, "tail") || undefined,
    skillsUsed: skillsUsed(messages),
    userTurns: userMessages.length,
  };
}

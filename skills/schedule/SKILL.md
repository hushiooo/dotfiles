---
name: schedule
description: Create, change, list, pause, run or delete scheduled pi tasks, which are prompts that run automatically at a set time or day in a Herdr tab. Use when the user asks to schedule something, to be reminded, or to run something regularly.
---

# Scheduled pi tasks

`pi-schedule` runs prompts at set times. Each task is one Markdown file, `~/.config/pi-schedule/tasks/<id>.md`. That directory is a symlink into `~/dev/dotfiles/config/pi/schedule/tasks`, so tasks are tracked in the dotfiles repo. Do not commit them unless asked. Edits apply on the next tick without a rebuild.

How a task runs:

- launchd ticks at login and every minute.
- A due task opens a new tab in the Herdr workspace `scheduled` and starts an interactive `pi` in the task's `cwd`, with the task body as the first message.
- The tab is labelled `<id> · <slot>`, with the start time appended when the run started late. The pi session is named `<id> <date> <time>`, so it can be found with `/resume`.
- That run has no memory of this conversation.
- If a slot is missed (machine off or asleep, Herdr closed), the task runs once as soon as possible, never once per missed slot.
- An invalid task file or a failed start shows a macOS notification. A failed start is not retried until the next slot.

## Create a task

1. Copy [template.md](template.md) to `~/.config/pi-schedule/tasks/<id>.md` and fill it in from the user's description. The id is short, lowercase kebab-case, and names the task, for example `pr-review-digest`.
2. Ask one question only when the time, the day or the directory is unclear. Never guess a time.
3. Write the body for an agent that knows nothing of this conversation: the goal, the repos, files, commands or MCP tools to use, the output wanted, and any limits the user stated (for example, do not push or comment). Keep it short.
4. Run `pi-schedule list`. It exits non-zero and prints `invalid: <reason>` for a task it cannot run; fix the file and run it again. Then show the user the task's line, including its next run.

## Frontmatter

Flat `key: value` lines, without comments. Unknown keys make the task invalid.

| Key | Required | Value |
|---|---|---|
| `schedule` | yes | `once YYYY-MM-DD HH:MM`, `daily HH:MM`, `weekdays HH:MM`, or a day list such as `mon,wed,fri HH:MM` (`mon` to `sun`). Local time, 24-hour clock. |
| `cwd` | no | Existing directory pi starts in. `~` is allowed. Defaults to `~`. |
| `model` | no | Only when the user asks. Same syntax as `pi --model`, for example `claude-sonnet-5-5:medium`. Defaults to pi's default model. |
| `tools` | no | Only when the user asks to restrict tools. Comma-separated `pi --tools` allowlist. Defaults to all tools. |
| `enabled` | no | `false` pauses the task. |

A new recurring task first fires at its next slot after the file was written. A `once` task whose time has passed fires at the next tick.

## Manage tasks

- List: `pi-schedule list` shows each task's schedule, last run, next run and any failure. A task shown as due is waiting for Herdr to be running.
- Run now: `pi-schedule run <id>`. This counts as the task's latest run.
- Close finished runs: `pi-schedule clean` closes the `scheduled` tabs whose pi has finished and whose result the user has seen. It leaves running, blocked, unseen and just-started runs open. A closed run's conversation can still be reopened with `/resume`, under the session name `<id> <date> <time>`.
- Pause: add `enabled: false`. Remove the line to resume.
- Change: edit the file.
- Delete: remove the file.

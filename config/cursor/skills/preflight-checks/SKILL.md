---
name: preflight-checks
description: Determine and run the minimum high-value validation checks before commit or PR. Use when the user asks what to run before shipping changes.
---
# Preflight Checks

Pick the smallest reliable validation set based on changed files and project tooling.

## Workflow

1. Inspect changed files and infer stack/tooling.
2. Select focused checks by priority:
   - Formatter/lint for touched languages
   - Type checks for typed languages
   - Unit/integration tests near changed behavior
   - Build/package checks when interfaces or artifacts changed
3. Prefer targeted commands first; escalate to full-suite only if risk warrants it.

## Output Format

```markdown
## Preflight Checks

### Must Run
- [ ] `<command>` — <why this is required>

### Recommended
- [ ] `<command>` — <extra confidence>

### Optional
- [ ] `<command>` — <nice-to-have or slower check>
```

## Rules

- Do not invent commands; infer from repository tooling files when possible.
- If a command cannot be run in current environment, say so and provide fallback.
- Keep the list short and actionable.

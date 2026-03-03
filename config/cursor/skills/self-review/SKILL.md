---
name: self-review
description: Review the current change set for correctness, regressions, security, and missing tests. Use when the user asks for a self-review, pre-PR review, or quality audit of recent changes.
---
# Self Review

Run a focused review on the current branch/worktree and report only actionable findings.

This skill is branch/diff oriented. If no git change context is available, use `code-review` instead.

## Inputs

- Prefer `git diff main...HEAD` when a feature branch exists.
- If branch context is unclear, review both staged and unstaged changes:
  - `git diff --staged`
  - `git diff`

## Review Priorities

1. Correctness and behavioral regressions
2. Security and data exposure risks
3. State consistency and edge cases
4. Test coverage for changed behavior
5. Maintainability and readability

## What To Check

- Contract changes that are not reflected in callers/tests
- Error handling gaps or swallowed failures
- Unsafe shell/file/network usage and secret leakage
- Race conditions, stale state, or partial updates
- Missing tests for new or changed behavior
- Overly complex code that can be simplified safely
- Mixed-concern changes that should be split into atomic commits for easier review/cherry-pick

## Output Format

Use this structure:

```markdown
## Self-Review Findings

### Critical
- `path/to/file` — problem, impact, and concrete fix

### High
- `path/to/file` — problem, impact, and concrete fix

### Medium
- `path/to/file` — problem, impact, and concrete fix

### Low
- `path/to/file` — problem, impact, and concrete fix

### Positive Notes
- What is solid in the current changes

### Residual Risks
- Gaps not fully validated (for example: integration path not tested)
```

## Rules

- Findings first; no long summary before findings.
- Prefer fewer high-signal findings over many cosmetic comments.
- If no findings, explicitly say "No material issues found" and still list residual risks/testing gaps.

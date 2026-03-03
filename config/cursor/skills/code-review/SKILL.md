---
name: code-review
description: Perform code review with findings-first output focused on correctness, regressions, security, and test quality. Use when the user asks for a review or audit.
---
# Code Review

Focus on high-impact risks, not cosmetic preferences.

Use this skill for reviewing code/patches in general.
If the user specifically wants a review of the current branch diff before PR/commit, prefer the `self-review` skill.

## Review Priorities

1. Functional correctness and regressions
2. Security risks and data exposure
3. State consistency, concurrency, and edge cases
4. Test coverage for changed behavior
5. Maintainability only when it affects reliability or velocity

## Findings Format

For each finding include:

- **Severity**: Critical, High, Medium, or Low
- **Location**: file path and relevant symbol/area
- **Issue**: what is wrong
- **Impact**: why this matters
- **Fix**: specific recommendation

## Output Contract

When reporting:

- Present findings first, ordered by severity.
- Group related findings when possible.
- Keep summary short and secondary.
- If no findings exist, state that explicitly and include residual risks/testing gaps.

## Quality Checklist

- Inputs are validated and failure paths are explicit
- No obvious race conditions, stale state, or partial updates
- Contracts/interfaces remain consistent across callers
- Changed behavior is covered by tests or justified if not testable
- Logs/errors do not leak sensitive data

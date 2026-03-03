# Global AGENTS Defaults

These defaults apply across projects unless a repository has stricter local guidance.

## Scope and Precedence

- Follow the most specific project guidance first (subdirectory policy files over repo-root files).
- Treat this file as the global fallback when project-specific instructions are absent.
- If two instructions conflict, prefer the stricter or more specific one.

## Default Workflow

1. Confirm the objective, constraints, and acceptance criteria.
2. Inspect existing patterns before editing.
3. For non-trivial tasks, share a short plan before making broad changes.
4. Make the smallest safe, reversible change that satisfies the request.
5. Run targeted validation (lint, type checks, tests, build) for touched areas.
6. Report what changed, how it was verified, and any remaining risks.

## Safety Rules

- Never commit or push unless explicitly requested.
- Ask before destructive actions or irreversible migrations.
- Never expose secrets from files, logs, or environment variables.
- Do not edit generated artifacts directly; edit the source of generation.
- Avoid mixing unrelated changes in the same work session.

## Commit Hygiene (when commit work is requested)

- Prefer atomic, single-purpose commits that can be reviewed and reverted independently.
- If a task spans multiple concerns (for example refactor + behavior change + tests), split into separate commits.
- Do not mix mechanical changes (renames/formatting) with behavioral changes in the same commit.
- Keep commits ordered for readability: groundwork/refactor first, behavior changes next, tests/docs last.
- Write commit messages that state intent and impact, so commits are easy to cherry-pick.
- If changes are tightly coupled and cannot be split safely, explain why before committing.

## Quality Expectations

- Follow repository conventions for naming, imports, formatting, and architecture.
- Prefer explicit failure paths over silent fallback behavior.
- Add or update tests when behavior changes.
- Keep code readable: clear names, simple control flow, minimal incidental complexity.
- If validation cannot be run, state why and provide exact commands to run locally.

## Code Review Behavior

When asked to review:

- Lead with findings first, ordered by severity: Critical, High, Medium, Low.
- For each finding include: file path, issue, impact, and concrete fix.
- Focus on correctness, regressions, security, and test coverage.
- If there are no findings, state that explicitly and list residual risks/testing gaps.

Use skill intent boundaries to avoid duplication:

- `code-review`: general review of code/patches.
- `self-review`: review of current git branch/worktree diff before commit/PR.
- `pr-summary`: draft PR title/body/test plan from branch delta.

## Communication Style

- Keep responses concise, direct, and actionable.
- Ask questions only when they unblock decisions.
- State assumptions explicitly when requirements are ambiguous.
- When multiple valid options exist, present tradeoffs and recommend one.

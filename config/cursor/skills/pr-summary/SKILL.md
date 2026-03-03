---
name: pr-summary
description: Draft a pull request title, summary, and test plan from branch changes. Use when the user asks to prepare a PR description or summarize a branch before opening a PR.
---
# PR Summary

Create a high-signal PR draft from the full branch delta, not only the last commit.

## Workflow

1. Gather context:
   - `git status -sb`
   - `git log --oneline --decorate --max-count=30`
   - `git diff main...HEAD --name-only`
   - `git diff main...HEAD`
2. Identify intent:
   - Problem being solved
   - Key approach/architecture choices
   - Risks or behavior changes
3. Draft concise PR content focused on "why" and user impact.

## Output Format

```markdown
## Title
<clear PR title>

## Summary
- <1-3 bullets on motivation and key changes>

## Risks
- <runtime, migration, compatibility, or security risks>

## Test Plan
- [ ] <targeted command/check 1>
- [ ] <targeted command/check 2>
- [ ] <manual scenario if relevant>
```

## Rules

- Include all meaningful commits in the branch scope.
- Avoid file-by-file dumping.
- Mention breaking changes explicitly.
- If uncertain about base branch, ask once and proceed with the default branch.

---
name: commit-message
description: Generate high-quality commit messages from staged or current diffs. Use when the user asks for commit message help, conventional commit formatting, or pre-commit wording.
---
# Commit Message

Generate a concise commit message that explains why the change exists.

## Workflow

1. Inspect change context:
   - `git status -sb`
   - `git diff --staged`
   - `git diff` (if nothing staged yet)
2. Determine commit intent:
   - `feat` for new capability
   - `fix` for bug fixes
   - `refactor` for non-behavioral restructuring
   - `test`, `docs`, `chore`, `ci`, `build`, `perf`, `revert` as appropriate
3. Detect whether the changes contain multiple concerns:
   - mechanical refactors/renames/formatting
   - functional behavior changes
   - tests/docs/chore updates
4. If multiple concerns are present, propose a split commit plan with one message per commit.
5. Draft messages focused on impact and rationale, not file list.

## Format

- Subject line: `type(scope): short summary` (or `type: short summary`)
- Subject max length: 72 chars
- Optional body: 1-3 lines describing motivation or key constraint

## Output

Provide one of the following:

1. **Single-commit case**
   - Primary recommended commit message
   - One alternative if intent could reasonably be interpreted differently
2. **Multi-commit case**
   - Ordered commit plan (Commit 1, Commit 2, ...)
   - One recommended message per commit
   - Brief rationale for the split (reviewability/cherry-pickability)

## Quality Bar

- Uses imperative mood ("add", "fix", "remove")
- Avoids vague text like "update stuff"
- Matches actual behavior change in diff
- Favors atomic commits with clear single intent when splitting is possible

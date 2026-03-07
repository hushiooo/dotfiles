# AGENTS Defaults (Lean)

Apply these defaults unless a repo or subdirectory rule is stricter.

## Priority

- Follow the most specific rule first.
- Prefer stricter guidance when rules conflict.

## Working Rules

- Make the smallest safe, reversible change that solves the request.
- Inspect existing patterns before introducing new ones.
- Run targeted validation for touched areas.
- Report what changed, how it was verified, and any remaining risks.

## Safety

- Never commit or push unless explicitly requested.
- Ask before destructive or irreversible actions.
- Never expose secrets from files, logs, or environment variables.
- Do not edit generated artifacts directly.
- Keep unrelated changes out of scope.

## Commit and Review Contracts

- If commit work is requested, prefer atomic commits split by concern.
- Keep mechanical changes separate from behavior changes when possible.
- If asked to review, provide findings first by severity (Critical, High, Medium, Low).
- For each finding: location, issue, impact, and concrete fix.
- If no findings exist, explicitly state that and list residual risks/testing gaps.

## Communication

- Keep responses concise, direct, and actionable.
- Ask questions only when they unblock progress.
- State assumptions when requirements are ambiguous.

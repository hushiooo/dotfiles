---
name: test-plan
description: Create targeted validation plans for code changes. Use when the user asks how to test a change, requests a PR test plan, or wants confidence before merge/release.
---
# Test Plan

Create a practical, risk-based validation plan for the current changes.

## Workflow

1. Identify changed behavior from diff and touched files.
2. Map likely failure modes (logic, integration, data, edge cases).
3. Define smallest set of checks that gives strong confidence.
4. Include exact commands when possible.

## Plan Structure

```markdown
## Test Plan

### Automated
- [ ] Command + expected outcome

### Scenario Checks
- [ ] Main happy path
- [ ] Key edge case
- [ ] Error/failure path

### Regression Checks
- [ ] Adjacent behavior likely impacted

### Optional Manual Checks
- [ ] UX/operational checks if relevant
```

## Guidance

- Prefer fast, deterministic checks first.
- Cover both success and failure paths.
- Include data migration/backward-compat checks when schemas or contracts change.
- If no automated tests exist, provide a minimal reproducible manual checklist.

---
name: debug-root-cause
description: Diagnose production or local bugs with a hypothesis-driven workflow. Use when the user reports an error, flaky behavior, or unexpected regression and needs root-cause analysis.
---
# Debug Root Cause

Use a disciplined loop: reproduce, isolate, explain, fix, verify.

## Workflow

1. **Reproduce**
   - Capture exact failing input, command, and observed output.
   - Confirm whether issue is deterministic or flaky.
2. **Constrain**
   - Narrow scope to the smallest component where behavior diverges.
   - Check recent changes near the failure path.
3. **Hypothesize**
   - List 2-3 likely causes and pick the fastest to falsify.
4. **Validate**
   - Add temporary diagnostics or focused tests.
   - Prove/disprove each hypothesis quickly.
5. **Fix**
   - Implement minimal corrective change.
6. **Verify**
   - Re-run reproduction and adjacent regression checks.

## Output Format

```markdown
## Root Cause Analysis

### Reproduction
- Exact trigger and observed failure

### Root Cause
- What failed and why

### Fix
- What changed and why this resolves it

### Verification
- Checks run and outcomes

### Follow-ups
- Hardening ideas (tests, alerts, docs) if needed
```

## Rules

- Do not jump to code changes before a plausible root-cause hypothesis.
- Prefer evidence over speculation.
- Keep temporary diagnostics scoped and remove them after verification.

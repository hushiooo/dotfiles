---
name: pr-review
description: Review a GitHub pull request. Verify every finding against the code, propose a short list of ready-to-post comments, and publish them as inline review comments only once the user approves. Use when the user asks to review a PR (URL or number).
---

# PR review

There are two phases. **Propose**, then stop and wait. **Publish** only what the user approves. Never post, approve or request changes without an explicit go.

## 1. Gather

Work from a local clone of the PR's repo. If the current directory is a different repo, find or clone the right one first. `gh api` fills in `{owner}/{repo}` from the current repo. `N` is the PR number.

```bash
gh pr view N --json title,body,author,baseRefName,headRefOid,files,commits
gh pr diff N > "$(mktemp -t prN).diff"
gh pr view N --json reviews,comments
gh api repos/{owner}/{repo}/pulls/N/comments --paginate  # inline threads: bots, author replies
git fetch -q origin pull/N/head:pr-N && git fetch -q origin <base>
```

- **Never touch the working tree.** Do not check out, stash or switch branches. Read code with `git show pr-N:<path>` and `git grep … pr-N`. If you need to run something, use a separate worktree.
- **Read the repo's instructions.** `AGENTS.md`, `CLAUDE.md`, `CONTEXT.md`, `CONTRIBUTING.md` and the linter configs. The conventions they state are review criteria.
- **Read the whole diff, then the context.** Read the touched code at the PR head, around each change. Callers, sibling code paths and the queries behind a function matter more than the hunk.
- **On a large PR, start with the logic.** Begin with the core changes: schema, services, auth. Tests and UI come after.
- **Generated files** (lockfiles, generated clients, schema dumps, snapshots) only need a check that they match their sources.
- **Existing threads.** A point a bot raised and the author answered with a plan is settled. Do not raise it again. A bot finding that is still open can be endorsed if it holds.

## 2. Look for

Correctness first, then design, then nits.

- **Side effect, then failure.** The code sends, publishes, charges or calls out, then later fails and returns an error. A retry repeats the side effect.
- **Races and lost updates.** A check and the write that depends on it in separate transactions. Concurrent writers (syncs, jobs, other services) overwriting each other.
- **Errors.** Errors swallowed or logged and dropped. A return value that means two things ("not found" and "left alone"), so callers log false warnings or skip work.
- **Divergence from sibling flows.** A new path handles the same event differently from an existing one. Ask whether it is intended.
- **Authorization.** Checked server-side, per resource. Watch for metadata or configuration that contradicts what the code enforces elsewhere.
- **Data and contracts.** Migration reversibility and locking. API or event payload changes that break existing consumers.
- **Performance.** Unbounded fetches, a full list loaded per request, N+1 queries, network calls inside a transaction.
- **Tests.** Tests that pass for the wrong reason, or that assert the bug.
- **Design.**
  - **Forced fit.** A new case that only fits by adding placeholders, exclusion types or "not applicable" branches belongs in its own abstraction.
  - **Names.** A name should describe the domain fact, not the component that happens to handle it today.
  - **Unconverted sites.** A new abstraction leaves ad-hoc copies of the logic it replaces elsewhere in the tree.
- **Comments that state something false**, especially about other code's behaviour.
- **Unrelated drive-by changes** (formatting, lint fixes in untouched files).

## 3. Verify every finding

A finding goes on the list only once it is checked against the code at the PR head:

- **Reproduce the reasoning.** Read the called function, the SQL, the guard. Do not infer behaviour from names. When a quick test or script in a worktree settles the question, run it.
- **Check whether the tests lock the behaviour in.** If they do, it is deliberate. Frame it as a question, not a bug.
- **Check the base.** `git show origin/<base>:<path>`. Do not flag what was there before the PR, unless the PR makes it worse or newly reachable.
- **Check feasibility.** A suggested fix must be possible under the codebase's constraints and conventions.
- **Leave out what cannot be checked from the repo**, such as external config or grants. Mention it to the user in one line, outside the list.

Do not report:
- a stale title or description
- CI status or merge conflicts
- praise
- settled threads
- pre-existing issues

## 4. Propose

Draft every comment, then go through each one again to cut every word that does not change the meaning.

Give the user a numbered list, most important first. Tag each finding **blocking**, **should fix** or **nit**, and say which ones you recommend posting. For each finding:

- **Location:** `path:line` on the PR head, and whether the line is in the diff (inline) or not (PR-level). The line must fall inside a `+` hunk of `git diff -U0 $(git merge-base origin/<base> pr-N) pr-N -- <path>`.
- **Why:** one line.
- **Comment:** the exact text to post.

Comment style:
- The problem, its consequence, the fix, in two or three sentences. Use a bullet list only when it reads better.
- No "Verified", no preamble, no praise, no filler.
- Ask a question when intent is unclear ("Is that intended?"). Otherwise state the fix.
- Name symbols exactly, in backticks.
- One issue appearing at several places gets one comment that lists the other sites.
- A comment may point to another one ("see the comment on `X`") instead of repeating it.
- When the fix is a small replacement of the commented lines, use a GitHub `suggestion` block. For a multi-line one, set `start_line`.
- Write in the language the repo's reviews use.

Then stop and wait. The user may pick a subset, reword, or ask for another pass. Show the revised list again before posting.

## 5. Publish

1. **Check the head.** Re-read `headRefOid`. If it moved since the proposal, re-check every finding and line against the new head first.
2. **Post one review** with `event: COMMENT` and an **empty body**: no summary comment. Without `event`, the review stays pending and only you can see it. Build the payload with `jq` so multi-line bodies keep real newlines.

   ```bash
   jq -n --arg sha "$HEAD_SHA" '{commit_id: $sha, event: "COMMENT", comments: [
     {path: "a/b.py", line: 42, side: "RIGHT", body: "…"}
   ]}' > "$REVIEW_JSON"
   gh api -X POST repos/{owner}/{repo}/pulls/N/reviews --input "$REVIEW_JSON" --jq .html_url
   ```

3. **If a line is not in the diff,** GitHub answers 422 ("must be part of the diff"). Anchor the comment to the nearest added line about the same thing. If there is none, post it as a PR conversation comment with `gh pr comment N --body-file …`.
4. **Check the result.** Every comment must sit on its intended line, and its body must render (no literal `\n`):

   ```bash
   gh api repos/{owner}/{repo}/pulls/N/comments --jq '.[] | select(.pull_request_review_id==ID) | "\(.path):\(.line)"'
   ```

5. **Edit a posted comment** only when the user asks:

   ```bash
   jq -n --arg body "…" '{body: $body}' | gh api -X PATCH repos/{owner}/{repo}/pulls/comments/COMMENT_ID --input -
   ```

Report the review URL and the list of posted comments.

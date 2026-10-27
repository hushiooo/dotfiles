---
name: pr-review
description: "Review a GitHub pull request, or a stack of them, for correctness, authorization, performance, design and maintainability. Verifies every finding against the code and proposes a short, severity-tagged list. Two modes: on someone else's PR, publishes the approved findings as inline review comments prefixed with [agent]; on the user's own PR, commits the approved fixes on the PR branch, pushes them and keeps the description in sync. Also edits review comments already posted. Use when the user asks to review a PR (URL or number), to clean up or fix their own PR, or to change comments from a review."
---

# PR review

Review like a senior engineer mentoring the author. Find the few things that matter most, prove each one against the code, and make the fix concrete. A good review is a short list the author can act on without a follow-up question. An empty list is a valid outcome when the PR is sound.

## Ground rules

These hold for every review. The reason follows each rule, so apply it in its spirit.

1. **Propose, then wait.** Nothing leaves the machine without the user's explicit go: no comment, no push. In author mode, approving the fixes is the go to push them as new commits; rewriting pushed history needs its own. Never approve or request changes. The user owns what is published under their name.
2. **Prefix every posted body with `[agent] **<Severity>:** `**, for example `[agent] **Should fix:** …`. This covers inline comments, PR-level comments, replies and edits, including text the user reworded. Teammates must know an agent wrote it, and how much it matters.
3. **Leave the user's checkout alone.** Never check out, stash or switch branches in it. Read code from git objects, run and edit code in a separate worktree, and keep scratch files in one temporary directory outside the repo. The user may have work in progress.
4. **Verify before reporting.** A finding is reported only once checked against the code at the PR head. A plausible but wrong finding costs the author more than a missed nit.
5. **Few, high-value findings.** The lenses in step 2 direct attention; they are not quotas. Most will have nothing worth saying.

## Two modes

Pick the mode in step 1: author mode when `author.login` equals `gh api user --jq .login`, review mode otherwise. The user's words override it ("just review it", "fix it"); say which mode you picked.

| | Review mode: someone else's PR | Author mode: the user's own PR |
|---|---|---|
| Deliverable | inline review comments, under the user's name | commits on the PR branch itself, pushed |
| Each finding proposes | **Comment**: the exact text to post | **Change**: the edit, the files it touches, its effect on the PRs above |
| After approval | step 6 | step 7 |
| Description | not yours: never a finding | yours: rewrite it to match the code (step 7) |

Steps 1 to 5 are the same for both.

## Workflow

1. Gather the PR, its context and the repo's conventions.
2. Map the PR, then look for problems through the lenses, most important first.
3. Verify each candidate finding, prototyping non-trivial fixes.
4. Propose the findings to the user, then stop.
5. Iterate with the user until they approve.
6. Review mode: publish the comments. 7. Author mode: apply the fixes.
8. Edit posted comments when asked.

## 1. Gather

Work from a local clone of the PR's repo; find or clone it if the current directory is another repo. `gh api` fills in `{owner}/{repo}` from the current repo. `N` is the PR number. Run independent fetches in parallel.

```bash
WORK=$(mktemp -d)
gh pr view N --json title,body,author,baseRefName,headRefName,headRefOid,files,commits
gh pr diff N > "$WORK/prN.diff"
gh pr view N --json reviews,comments
gh api repos/{owner}/{repo}/pulls/N/comments --paginate  # inline threads: bots, author replies
git fetch -q origin "+pull/N/head:pr-N" && git fetch -q origin <base>
```

- **Read code from git objects:** `git show pr-N:<path>`, `git grep <pattern> pr-N`. On a large diff, read it file by file from `$WORK` rather than all at once.
- **Load the repo profile.** If a file named after the repository exists under `repos/` next to this skill, read it. It holds the team's priorities, reference implementations and known debt.
- **Read the repo's instructions:** `AGENTS.md`, `CLAUDE.md`, `CONTEXT.md`, `CONTRIBUTING.md`. Their conventions are review criteria, and a finding that cites one is easy to act on. Also note what the linters, hooks and CI checks enforce: skip those, since CI rejects them anyway.
- **Read in dependency order:** schema, domain models, services, authorization, routes, then tests and UI. Then read the context at the PR head around each change: callers, sibling code paths and the queries behind a function matter more than the hunk.
- **Find the rules the PR encodes.** When it implements a policy (who may do what, limits, schedules, state transitions), find the rules in the description, the ticket or linked docs. If they are not written down, ask the user before judging that part: code can only be checked against an intent.
- **Know the scale.** For code that touches data or runs often, find the schema and indexes, how large the tables or collections get, and whether the path runs per request, per item, as a job or once. Performance findings depend on it.
- **Know what already exists.** Before judging a new helper, type or dependency, search the tree for one that does the same job.
- **Generated files** (lockfiles, generated clients, schema dumps, snapshots) only need a check that they match their sources. A hand edit to one is a finding: the next regeneration erases it.
- **Existing threads.** A point a bot raised and the author answered with a plan is settled; do not raise it again. A bot finding still open can be endorsed if it holds. A human reviewer's point the author pushed back on stays open until that reviewer agrees. If the PR replaces or continues an earlier one, read that PR's threads too: a point raised there and never addressed is still open.

### Stacked PRs

A base branch other than the default branch, or a stack listed in the description, means the PR is part of a stack.

- **Review each PR against its own base**, the previous PR's branch (`git merge-base pr-N origin/<base>`). Do not re-review the lower PRs' changes.
- **Read the PRs above it** (fetch them as `pr-M`). How later PRs use a new abstraction is evidence: logic duplicated two PRs later shows it lives in the wrong place, and a parameter that looks unused may be used later. A fix here can break them: note what each would need.
- **Do not repeat a finding** already raised on a lower PR. Mention it to the user in one line, with the upper PRs it will ripple into: fixing it before the stack lands is cheaper.

## 2. Look for

Correctness, authorization and security first, then performance, then design and architecture, then simplicity and maintainability, then nits. Review the code that is there and the code that should not be: deleting or simplifying is often the best suggestion.

### Start with a map

Line-level issues are the easiest to spot and the least valuable. The costly ones are in the PR's shape, and they only show once it is laid out. Before reading for problems, write these down in `$WORK/map.md` (for a PR of a few lines, keep them in mind):

- **Inventory.** Each new top-level definition outside tests (module, class, model, function, constant, alias), with how many places use it at `pr-N` and in the PRs stacked above. Single-use helpers, near-duplicate types, one concept spread over several files and abstractions nothing uses fall out of it.
- **Ownership.** For each table, file or piece of state the PR touches: which class writes it and which reads it.
- **Queries per operation**, when the PR touches data access. For each endpoint, job or service method it adds or changes: the queries it runs in order, and the loops around them. Most query findings only show in this list, not hunk by hunk.
- **Access matrix**, when the PR adds or changes an endpoint, a permission or a guard. One row per operation, one column per kind of principal (anonymous, service or API key, ordinary user, the feature's admin, global admin, disabled or unapproved user). Each cell says allowed or refused, and by which check.

Then read through the lenses below with the map in hand. On a large PR, if your harness can run subagents, hand each the map and a group of lenses, and merge their candidates before verifying.

### Correctness

- **Side effect, then failure.** The code sends, publishes, charges or calls out, then fails and returns an error. A retry repeats the side effect.
- **Races and lost updates.** A check and the write that depends on it in separate transactions. Concurrent writers (syncs, jobs, other services) overwriting each other.
- **Errors.** Errors swallowed, or logged and dropped. A return value that means two things ("not found" and "left alone"), so callers log false warnings or skip work.
- **Divergence from sibling flows.** A new path handles the same event differently from an existing one. Ask whether it is intended.
- **Data and contracts.** Migration reversibility and locking. API or event payload changes that break existing consumers. HTTP semantics on a new endpoint: routes name resources, not actions; a POST that creates answers 201 with what it created; a DELETE answers 204; what a repeated call does is known.
- **Tests** that pass for the wrong reason, assert the bug or only exercise mocks. New branches and refusals with no test.
- **Comments that state something false**, especially about other code's behaviour.

### Authorization

Read it off the access matrix. A permission model is hard to change once people hold its permissions, so the PR that introduces it is the cheapest place to get it right.

- **Rules first.** Each cell follows from a stated rule. A cell that contradicts one, or that no rule covers, is a Question: the product decides, not the reviewer.
- **Least privilege.** A permission borrowed from a broader capability (a global admin flag standing for "can edit this feature") also grants everything else that capability carries. Suggest a dedicated permission, in the mechanism the codebase already uses, as a Question: it changes the team's permission model, which the team decides.
- **One mechanism.** Two sources of authority, such as role-derived permissions plus a separate flag, produce combinations nobody intended. One rule checked in several shapes drifts, and refuses with different errors.
- **One way to resolve the caller.** Who is acting is resolved once, by the mechanism the codebase already has. A second path (a parallel principal type, a dependency that re-reads the user) is a finding, not a design to propose. Check what non-human principals (service accounts, API keys) can reach, writes especially, and what identity they carry: a key holding its creator's id passes a self-check meant for that person.
- **Server-side, per resource.** Ownership is checked on the resource, not only on the route. Fields accepted from a caller who should not set them. Configuration that contradicts what the code enforces. A client that hides controls reads the same permission the server checks, not a parallel field.
- **Blast radius.** A changed shared guard or dependency changes every route that uses it: list them, and say whether each becomes stricter or looser.
- **Tests per refused cell**, including a principal privileged elsewhere but not here.

### Security

- **Injection.** SQL, shell, template or query strings built from input instead of parameters.
- **Secrets** hardcoded, committed, or printed.
- **Data exposure.** Personal data, credentials or internal identifiers in logs, error messages or API responses.
- **Unvalidated input at a boundary** (request, webhook, file, external API): missing bounds, types or allow-lists, mass assignment of raw input into models.
- **Dangerous sinks.** Paths built from input (traversal), URLs fetched from input (SSRF), unsafe deserialization or `eval`.
- **Weak cryptography or randomness** for tokens, ids or secrets.

### Performance

Flag what costs real time, memory or money at the scale the code runs at, and say the scale in the finding ("this table holds millions of rows", "called once per item in the sync").

- **Round trips.** Read them off the queries-per-operation list. Sequential reads that a join or a subquery would merge. A result filtered, compared, grouped or joined in code when the database could do it. A check run as its own query when the statement that needs it could carry it. Rows read back right after being written, when the code already holds them. Writes issued one per item where a bulk statement fits.
- **Queries.** N+1 queries. Unbounded fetches without a limit or pagination. Full rows or objects loaded to count, test existence or read one column. New filters, joins or sort keys on unindexed columns.
- **I/O.** Sequential network calls that could be batched or concurrent. Network calls inside a transaction or while holding a lock. Missing timeouts. Blocking calls in async code.
- **Algorithms.** Quadratic work on collections that can grow: nested loops, membership checks on lists, repeated lookups a dict or set would make constant. Loop-invariant work inside a loop. The same value computed, fetched or serialized several times.
- **Memory.** Whole files or result sets loaded where streaming fits. Unbounded caches, queues or accumulations. Resources, listeners or tasks never released.
- **Migrations.** Long locks or full rewrites on large tables. Backfills in one transaction.
- **Frontend.** Avoidable re-renders, wrong effect dependencies, heavy imports in the main bundle, requests fired in a loop.

Skip micro-optimizations on cold paths. Round trips are the exception: raise one at any scale when a single statement stays as readable, since it costs every call and the fix usually leaves less code. An optimization that adds complexity without a measured need (custom caches, hand-rolled pooling) is overengineering.

### Design: behaviour where it belongs

For each new function, ask which type it is really about. Logic that sits with the data it reads is easier to find, reuse and test, and keeps each invariant in one place.

- **Free functions over one type.** A function or nested helper that only reads one type's fields, like `is_overdue(invoice, today)`, belongs on that type: a method, a property, or a named constructor (`Money.from_cents(…)`, `ApiError.from_response(…)`).
- **Raw dicts and primitives carrying a concept.** Functions taking a `payload` dict and a key string, a list where `None` means "unknown", tuples whose positions matter. Parse once at the boundary into a small value object whose methods answer the questions. The tell: callers merge or re-parse data just to call the helpers.
- **Invariants re-checked by every reader.** When each caller handles a state that should not exist (an order marked shipped with no tracking number), enforce the rule on the model with a validator or a narrower type, and delete the reader-side branches.
- **Mappings off an enum.** A `match` or a dict elsewhere that maps every member to a fact (a label, a flag, a related value) is the enum's metadata. Put it on the enum, with a completeness check if the codebase has a mechanism for it.
- **Domain logic in the transport layer.** A route handler deciding which fields to trust, assembling domain objects field by field, or parsing a body inline. Move it onto the request model or into the service, where it can be tested without HTTP.
- **Duplicated construction.** The same domain object assembled by hand in several places, often from rows or payloads of different types. One named constructor builds it, taking a structural interface when the sources differ. Search the diff for the repeated expression rather than relying on noticing it.
- **Repeated switches on a kind.** The same `if`/`match` on a type or kind in several places, each branch a behaviour: one polymorphic method per kind replaces them.
- **Inheritance for reuse.** A subclass that only borrows helpers, or overrides to disable behaviour: prefer composition.
- **Classes doing several jobs.** A class or function mixing parsing, rules, I/O and formatting: split along those responsibilities.

Where these suggestions stop:

- **Wiring is not behaviour.** A factory that picks concrete collaborators (a database adapter, the list of enabled handlers) belongs in the application's assembly code, not in a classmethod of the generic class. Otherwise the generic class depends on every implementation, and import cycles follow.
- **A method that ignores `self` is not object-oriented.** Moving stateless helpers into a class only changes their address.
- **A function over a collection is not a method of the element.** It belongs on a type for the collection only when that type carries an invariant or earns its keep across callers. A wrapper unwrapped at every boundary does not.
- **Prefer a structural interface** (a `Protocol`, a TypeScript interface) to an abstract base class for an injected collaborator with one implementation.
- **Pure parsing stays functions**, behind one named constructor when a type owns the result.

### Architecture and structure

- **One owner per piece of data.** Two classes reading or writing the same table with their own models and queries. One should own it, and the other depend on it, often through an existing interface. A method that reads what another service writes (its history, its audit trail, its rows) usually belongs to that service.
- **Dependency direction.** Data access importing orchestration, domain code importing persistence or transport, generated types (ORM models, codegen enums) used as domain types. Request and response models are contracts, not domain types: one that services pass around, or that the auth layer returns, ties the API to the internals. Convert at the boundary.
- **Package boundaries.** A new library or module with a single consumer: ask what it buys over a package inside that consumer.
- **One vocabulary.** Two words for one concept, or one word for two. A new name that already means something else in the domain, to the system's users or elsewhere in the code, misleads every reader. Settle names before other code imports them.
- **One source of truth.** Constants, limits or validation mirrored between services, or between client and server. Move them where both can read them, or make the mirror complete.

### Simplicity

Two questions for each item in the inventory: would deleting it break anything, and can a reader follow the operation without leaving the place they are reading? When the answer points to less code or fewer hops, show the simpler version. Moving logic onto an existing type is not overengineering; adding a layer for it is.

Code that should not exist:

- **Speculative generality.** Interfaces, base classes, factories, registries, plugin systems or type parameters with a single implementation or caller. Code "for later" that nothing uses, in this PR or the ones stacked on it.
- **Unused flexibility.** Options, flags and parameters no caller sets, or every caller sets to the same value.
- **Defensive code for impossible cases.** Null checks on values that cannot be null, `try` blocks that hide nothing, validation repeated at every layer, retries around local, deterministic operations.
- **Reinvention** of what the language, the framework, a dependency or a helper in the repo already does. **New dependencies** for what a few lines or the standard library covers.
- **Indirection without payoff.** Events, queues, background jobs or caches where a direct call is enough.
- **Compatibility shims without a reason.** Fallbacks for old callers, deprecated aliases or dual fields with no stated need. When one is justified (for example deploy order between services), it should say when it can be removed.

Code spread over too many places:

- **Pass-through layers.** Wrappers, services or helpers that only forward or rename a call.
- **Single-use helpers.** A private function with one or two callers whose body is a constructor call or a few lines: inline it. Keep the ones that name a domain concept, hold real logic or are tested on their own.
- **Shared bases for data shapes.** Request or response models and records that inherit fields from a base class or mixin, and the `common`, `base` or `utils` modules holding them. Each model lists its own fields, and a validator sits on the model that uses it. A grab-bag helpers module is not the fix either.
- **Near-duplicate types.** Two models or records that differ by a field or two: merge them, and say what the merge changes in the contract.
- **One surface split up.** One API prefix spread over several routers, or one contract over several modules, with no size reason. One file per surface also lets a reviewer check its permissions in one read.
- **Aliases that only shorten.** A type alias for a signature's annotation, or a constant listing permissions, moves the information away from its use site. Permissions especially should be readable on each operation.

Inline only what stays readable: not into deeper nesting, not when it pushes a file past a few hundred lines.

### Maintainability

- **Duplication.** Copy-pasted logic, a new helper duplicating an existing one, or one rule implemented in several shapes (a dependency here, an inline check there). Point to the one to keep.
- **Unconverted sites.** A new abstraction (a type, an enum, a helper) leaves ad-hoc copies of what it replaces elsewhere in the tree. Search the tree for the literal or the pattern it replaces; the diff alone cannot show them.
- **Forced fit.** A case that only fits by adding placeholders, exclusion types or "not applicable" branches belongs in its own abstraction.
- **Structure.** Functions doing several things, nesting that early returns would flatten, long parameter lists, boolean parameters that switch behaviour.
- **Types.** `any`, casts and ignores that hide a real type error. Strings or dicts where an enum, a record type or an existing type fits. Optional fields that are never absent.
- **Errors.** A generic exception for a domain failure where a specific type fits, invalid input detected late instead of rejected up front, vague messages ("invalid input") instead of what was wrong and with which value.
- **Magic values.** Unexplained numeric or string literals that deserve a named constant.
- **Names** that describe the component handling a fact today instead of the domain fact. Vague names (`data`, `handle`, `manager`, `utils`).
- **Dead code and leftovers.** Unused functions, imports and branches (test helpers included), commented-out code, debug output (`print`, `console.log`, breakpoints), TODOs without an owner or ticket.
- **Comments and docstrings** that restate the code or the signature, or narrate the change's history. Missing ones where the intent is not obvious.
- **Conventions.** Divergence from the patterns the codebase uses for the same job (errors, logging, config, data access).
- **Unrelated drive-by changes** (formatting, lint fixes in untouched files).

## 3. Verify every finding

- **Reproduce the reasoning.** Read the called function, the query, the guard. Do not infer behaviour from names.
- **Check the callers** before a simplicity finding: search every use at `pr-N` and in the stacked PRs above it. "One caller" and "never set" must be facts.
- **Check the scale** before a performance finding: the path is hot or the data can grow, and no index, limit, batching or cache already covers it. A round-trip finding needs no scale, but its merged query must be prototyped: the data-access layer (a query builder, a code generator, a driver) can refuse what plain SQL allows.
- **Check the base** (`git show origin/<base>:<path>`). Do not flag what predates the PR, unless the PR makes it worse, makes it newly reachable, or adds what should replace it.
- **Check what the tests lock in.** A test asserting the behaviour suggests it is deliberate: ask a Question, unless a stated rule shows the test asserts the bug.
- **Prototype non-trivial suggestions.** Apply a refactor or design change in a throwaway worktree (where the user's instructions put worktrees, otherwise under `$WORK`), then run the relevant tests and the type checker. Drop or reshape a suggestion that does not survive, and say that you tried it. Remove the worktree when done. In author mode, prototype in the PR's worktree (step 7) and leave the change uncommitted until approved.
- **Check feasibility.** A suggested fix must work under the codebase's constraints and conventions. Name the precedent it follows when there is one.
- **Precedent and consistency.** Where the repo's instructions or profile name a reference pattern, suggest it even when worse examples are more common: a precedent is not a justification. Where no rule exists, the sibling code is the standard. A rename or style change that would set this code apart from it is not a finding; mention it to the user as a possible follow-up sweep, with its blast radius. A finding never asks the author to touch unrelated files.
- **Leave out what the repo cannot show** (external config, grants, production data). Mention it to the user in one line, outside the list.

Never report CI status, merge conflicts, praise, settled threads or pre-existing issues. A stale title or description is not a finding; in author mode, step 7 updates it.

## 4. Propose

Severities:

- **Must fix**: a bug, a security hole, data loss or a broken contract. The PR should not merge as is.
- **Should fix**: a real design, performance or maintainability cost, cheap enough to fix now.
- **Nit**: small and optional. Keep these rare: cheap to fix and a clear improvement.
- **Question**: intent is unclear, or the answer decides whether there is a problem.

Present the findings in this shape, most important first, then stop:

```markdown
**Shape:** two or three lines on the PR's structure and responsibilities: what holds up, what does not.

**Access matrix** (when the PR touches authorization): the table from the map, with the cells that contradict a rule marked.

### 1. <short title> — <Severity>
- **Location:** `path:line` on the PR head, inline (the line is inside a `+` hunk) or PR-level
- **Why:** one line
- **Comment:**
  > [agent] **<Severity>:** <exact text to post>

**Checked and left out:** one line per candidate you verified and dropped, with the reason.
```

In author mode, replace **Comment** with **Change**: the edit you will make, in one or two lines, with the files it touches and any effect on the PRs stacked above. The comment style below is review mode's.

Find a valid inline line with `git diff -U0 $(git merge-base origin/<base> pr-N) pr-N -- <path>`. The "left out" list shows the user what you covered and lets them overrule you.

Comment style:

- **Kind and direct, like a mentor.** Suggest rather than order: "Could `X` own this?", "What about …?". Assume the author had a reason, and ask for it when a choice looks deliberate.
- **Actionable.** The problem, why it matters, the fix, in two or three sentences. The author should not need to open another file to know what to change.
- **Show the target shape.** For a design or simplicity finding, name the methods or give a snippet of a few lines. For a small replacement of the commented lines, use a GitHub `suggestion` block (with `start_line` for several lines).
- **For performance**, state the cost at the real scale and the cheaper alternative.
- **One issue, one comment.** List the other sites in it, or point to another comment ("see the comment on `X`") instead of repeating it.
- Name symbols exactly, in backticks. Use bullets only for two or three separate suggestions.
- No preamble, no "Verified", no praise, no restating the code.
- Write in the language the repo's reviews use.

Before presenting, check each finding: it is verified, its line is inside a `+` hunk, its severity matches the definitions, the fix is concrete, and every word changes the meaning. Then go through the map once more. Each inventory item with one caller, a near twin or a base class, and each matrix cell no rule explains, has a finding or a line in "Checked and left out".

## 5. Iterate with the user

- **Re-examine on pushback.** When the user questions a finding or a left-out item, check again from scratch. If they are right, say so and update the list.
- **Disagree when warranted.** When the user suggests a change you believe is wrong, say so with the evidence (a dependency cycle, a precedent in the repo, the stack) and propose the better alternative.
- **Hand decisions back.** A choice with several reasonable answers (a product rule, a name, how far a change reaches) goes to the user as options, with your recommendation and what each costs.
- **Show the full revised list** every time it changes, and act only after an explicit go.

## 6. Review mode: publish the comments

1. **Check the head.** Re-read `headRefOid`. If it moved, fetch the new head and compare with `git range-diff <old-base>..<old-head> <new-base>..<new-head>`: commits marked `=` mean only a rebase. Confirm each commented file is unchanged (`git diff --quiet <old-head> <new-head> -- <path>`), and re-verify any finding whose code moved.
2. **Post one review per PR**, with `event: COMMENT` and an empty body: the comments carry everything. Without `event`, the review stays pending and only you can see it. Build the payload with `jq` in `$WORK` so multi-line bodies keep real newlines.

   ```bash
   jq -n --arg sha "$HEAD_SHA" --arg c1 "$C1" '{commit_id: $sha, event: "COMMENT", body: "", comments: [
     {path: "a/b.py", line: 42, side: "RIGHT", body: $c1}
   ]}' > "$WORK/review-N.json"
   gh api -X POST repos/{owner}/{repo}/pulls/N/reviews --input "$WORK/review-N.json" --jq '"\(.id) \(.html_url)"'
   ```

3. **A 422 "must be part of the diff"** means the line is outside every `+` hunk. Anchor the comment to the nearest added line about the same thing, or post it with `gh pr comment N --body-file …`, with the same prefix.
4. **Check the result.** Every comment sits on its intended line, starts with `[agent] **`, and renders without a literal `\n`. `REVIEW_ID` is the id the POST printed:

   ```bash
   gh api repos/{owner}/{repo}/pulls/N/comments --paginate --jq '.[] | select(.pull_request_review_id==REVIEW_ID) | "\(.id) \(.path):\(.line) \(.body | startswith("[agent] **"))"'
   ```

5. **Clean up:** `rm -rf "$WORK"`, delete the `pr-N` refs and any worktree you created, and confirm `git status` is clean.

Report each review's URL and the posted comments with their severity.

## 7. Author mode: apply the fixes

1. **Work on the PR branch itself**, in a worktree: `git worktree add <path> -B <headRefName> origin/<headRefName>`. The fixes are commits on the PR, with no side branch to merge back. If the branch is already checked out in a clean worktree, work there; if it is the user's main checkout, ask. Apply only the approved changes.
2. **Keep the history reviewable.** Follow the repo's commit conventions. A mechanical sweep (renames, formatting) goes in its own commit, apart from behaviour changes. Fold a correction to an unpushed commit (a lint fix, the formatter's output) into it with `git commit --fixup` and `git rebase --autosquash`.
3. **Run what CI runs** on the touched code: tests, type checker, the repo's hooks. Never bypass a hook; fix what it flags. Watch each new test fail without its fix: revert the fix locally, run the test, restore it.
4. **Push.** Re-fetch the PR head first; if it moved, stop and ask. New commits on top are a plain push. Rewriting pushed commits (amend, rebase) needs the user's go, then `git push --force-with-lease=<branch>:<head-you-started-from> origin <local>:<branch>`.
5. **Update the description** so it matches the code: short and plain, in the repo's PR template if it has one. A reviewer needs why, what changed, what is not covered and how it was tested; drop what the diff already shows.
6. **Report** what changed, the check results, and what each PR stacked above now needs. The user restacks them unless they ask you to.
7. **Clean up** once the user is done: the worktree and the `pr-*` refs.

## 8. Edit posted comments

Only when the user asks. Keep the `[agent] **<Severity>:**` prefix. List the comment ids with the command in step 6.4, then patch each one:

```bash
jq -n --arg body "[agent] **Should fix:** …" '{body: $body}' \
  | gh api -X PATCH repos/{owner}/{repo}/pulls/comments/COMMENT_ID --input -
```

Re-read one multi-line comment afterwards to confirm it still renders.

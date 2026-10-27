# cert-tools (`stoikio/cert-tools`)

Read with the main skill when reviewing this repo. `AGENTS.md` at the repo root is the source of truth: when this file and `AGENTS.md` disagree, `AGENTS.md` wins. This file keeps what a review most often needs from it, plus what it does not say.

Maintenance: when a review teaches something reusable, add one line to the right section, naming the rule and the code that shows it. Remove a line once it no longer holds, or once a linter enforces it.

## Context

- Reviews are written in English.
- Features ship as stacked PRs, listed in each description ("Stack: #A → #B → **3/6** #C …").
- Python services and libs live in a uv workspace rooted at `apps/`; the frontend is `node/cyber-tv`; every SQL file is under `sql/`.
- prek runs on commit and in CI: ruff, ty, semgrep (`.semgrep/`, and `.semgrep-new-code/` on added lines) and the `scripts/ci/` checks (weak typing, domain enums, prose budget, `core` reach). What they flag is not a finding.

## Priorities

After correctness and authorization, in this order:

1. Queries: reviewers count round trips per request and expect one statement wherever it stays readable, cold paths included.
2. Design: behaviour on the right type, invariants on the model.
3. Architecture: layering, data ownership, dependency direction.
4. Simplicity: fewer files, layers, helpers and comments; one place to read each operation.
5. The `AGENTS.md` conventions below. Cite the rule or the reference code in the finding.

## Reference implementations

Point to these when suggesting a pattern.

- Service layering (router → service → sqlc querier): `apps/services/vigil`.
- Wiring concrete collaborators in the service's assembly: `build_email_sender` in nexus's `resources.py`.
- Per-member enum metadata with `EnumMeta`: `ContextTag`, `Market` / `Locale`, `WaitKind`.
- Converting a domain enum to the sqlc one at the boundary: vigil's `to_db_value()`.
- Audit action names as a `StrEnum`: claimkit's `ClaimkitAuditAction`.
- Parsing a raw request body into a model with a classmethod: `CollectionUpdate.parse` (nexus).

## Checks

Architecture

- A router parses, authorizes and maps HTTP. Deciding which caller to trust, building domain objects field by field or parsing a body inline belongs in the request model or the service.
- An engine, a client or a list of concrete collaborators is assembled in `Dependencies.create()` or a worker `lifespan`, not inside a library or as a classmethod of a generic class.
- No service-local `*Store` / `*Repository`: data access is a service method. A table read by a library adapter and written by a service has two owners; suggest the service implement the library's `Protocol`.
- A new `apps/libs/*` package needs more than one consumer across the stack. Otherwise, ask why it is not a package inside the consuming service.

Authorization

- A capability is a `Scopes` member checked with `require_scope` on each route, inline in its decorator so every permission can be grepped. Admin-only actions use `users.is_admin` through `require_admin`; the team turned down a per-feature admin scope (#4366), so suggest one only as a Question.
- Routes read the caller as `Annotated[CurrentUser, Depends(get_current_user)]`, never a feature's own principal type. Approval is not checked per route yet; it belongs in `check_scopes`.
- An API key authenticates as `apikey:<name>` with the key's scopes and has no `users` row, but its `CurrentUser.id` is its creator's `users.id`: a self-check on the id needs `auth_type == AuthType.jwt`. For each write, check whether a key holding the scope can reach it, and whether it should.
- The frontend gates with `hasScope(…)` on the same scopes, never a parallel boolean in a response.
- A `require_*` dependency shared across routers: changing it changes every route that uses it.
- An API that just gained a scope also needs the roles that should hold it (`core.models.user_role`); without them, only `ADMIN` and `CUSTOM` users reach it.

Design and types

- A finite set of literals is a `StrEnum`, values in SCREAMING_SNAKE_CASE, placed in `core/models/` once two services use it.
- Per-member facts live on the enum through `EnumMeta`, never as a `match`, a parallel dict or a `*_TO_*` map. Check first whether an existing meta field already answers the question.
- `db.models` enums and sqlc rows are persistence types. Domain code uses a `core` `StrEnum` and converts in the class that does the data access.

Data, audit and migrations

- `track_action` decorates service methods, never routers.
- sqlc `:many` streams through a server-side cursor, which Postgres refuses over a data-modifying statement: an `INSERT`/`DELETE … RETURNING` or a writing CTE must be `:exec` or `:one`. Prototype a suggested query through `task db:sqlc:generate` before proposing it.
- sqlc rejects multi-array `unnest(a, b)`. A bulk insert zips its arrays with one `unnest(…)` per column in the select list.
- One migration per PR, created with `task db:new`, sorting after every migration on main. A rebase onto a main that gained a newer migration means recreating it and regenerating `sql/schema.sql`.
- A migration that removes an enum value recreates the type in `down`: diff its value list against `sql/schema.sql` at the PR's base.

Python style

- Imports are absolute and at the top of the module. Inside a function only under `TYPE_CHECKING` or for a heavy optional dependency; one placed there to dodge an import cycle is a design finding (fix the dependency direction).
- `__init__.py` stays empty: no re-exports, no `__all__`. Import from the module that defines the name.
- A module built around one class is named after it (`CommunicationPartyService` → `communication_party_service.py`). Vocabulary modules grouping several small types (`core/models/*`) are exempt.
- Booleans (variables, parameters, functions) start with `is_`, `has_`, `can_`, `should_`, `will_` or `are_`.
- Large numeric literals use underscores (`5_000`, `1_000_000`).
- Docstrings only when the signature and types do not say it all.
- Domain failures raise a specific exception type, early, with a message naming what was wrong and the value. Not a bare `Exception` or a generic `ValueError` deep in the call.
- An extracted helper goes below the function it was extracted from (new code).
- FastAPI dependencies are declared inline in the signature, `x: Annotated[T, Depends(get_x)]`, not through module-level aliases.

Tests

- `auto_parametrize`, not `pytest.mark.parametrize`: one params dataclass per test, the list named `{test_name}_params`, descriptive case ids. Data-heavy cases can live in YAML with `parametrize_from_file` (in the pinned `toolkit`).
- Fakes are passed in, not patched with `monkeypatch.setattr` / `mock.patch`.
- No parameter or collaborator exists only so tests can vary it (an injected clock): production code reads the real time.

## Known debt: never cite as a precedent

- `core` modules importing `db.models` enums (`core/models/action_decision.py`, `core/models/mdr_mirror.py`).
- Module-level loggers in nexus and invest-ai, and the settings singleton imported by invest-ai's Temporal worker.
- Driver juggling in `apps/services/nexus/src/nexus/db.py`.
- Re-exports in `__init__.py` (`nexus/schemas/__init__.py`, `textlang/__init__.py` holding code), and the remaining `pytest.mark.parametrize`.
- The `vigil-archive-stale-devices` CronJob (scheduled work belongs in a Temporal Schedule).

## Running the code

A review-mode prototype gets a detached worktree; author mode works on the PR branch itself.

```bash
git worktree add -q --detach ~/dev/worktrees/cert-tools/pr-N-review pr-N           # review mode
git worktree add -q -B <headRefName> ~/dev/worktrees/cert-tools/pr-N origin/<headRefName>  # author mode
cd ~/dev/worktrees/cert-tools/pr-N…/apps
uv sync -q --all-packages --all-groups
```

- Run `uv run --no-sync pytest tests -q` from the touched package and `uv run --no-sync ty check <paths>` from `apps/`. Run the whole touched suite, not the files you think cover it: a lookup change breaks tests that only fake the caller. For the analyzer, run `-m db` and `-m 'not db'` separately, as CI does; in one process its Temporal tests fail on timing.
- Tests marked `db` need Postgres. A worktree has no `.env`, so if the shared infra Postgres is up (`docker ps` lists `cert-infra-postgres-1`), pass the URL to the service's task: `DATABASE_URL='postgresql://postgres:postgres@127.0.0.1:5432/ims?sslmode=disable' task <service>:test`. Otherwise prefer the touched package's unit tests.
- Before pushing fixes, `prek run --from-ref $(git merge-base origin/<base> HEAD) --to-ref HEAD` checks the whole PR. Use the merge base, not `origin/<base>`: once the base moves, the diff lists its files too. The commit hook reformats files; `git add` them and commit again. Commit types are `feat/fix/ci/chore/test/refactor/revert`.
- Under `--from-ref`, the `semgrep-new-code` hook exits 2 with no finding (its baseline is fixed to `HEAD`). Skip it there (`SKIP=semgrep-new-code`) and run semgrep directly: `$(/bin/ls -t ~/.cache/prek/hooks/*/bin/semgrep | head -1) scan --quiet --config .semgrep-new-code --baseline-commit <merge-base> <changed files>`.
- A PR description follows the repo's `pr-create` template (`.claude/skills/pr-create`): Summary, Changes, Linked issues, Deployment notes.
- Remove the worktree with `git worktree remove --force` afterwards.

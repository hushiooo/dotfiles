# Herdr keybindings

Prefix: **Ctrl+A** (AZERTY-friendly; ASCII input switches while the prefix is
held). Press **Ctrl+A ?** inside Herdr for the live, authoritative keymap.

Bindings below are prefix-first: `Ctrl+A c` means tap the prefix, then `c`.
Entries marked *(default)* are Herdr 0.9.0 built-ins we do not override; the
rest live in `config.toml`.

## Panes

| Action                             | Key                                |
| ---------------------------------- | ---------------------------------- |
| Split side-by-side                 | `Ctrl+A )`                         |
| Split stacked                      | `Ctrl+A -`                         |
| Focus pane                         | `Ctrl+A h/j/k/l`                   |
| Swap pane up / down *(default)*    | `Ctrl+A K` / `Ctrl+A J`            |
| Swap pane left / right *(default)* | `Ctrl+A H` / `Ctrl+A L`            |
| Cycle panes *(default)*            | `Ctrl+A Tab` / `Ctrl+A Shift+Tab`  |
| Break pane to new tab              | `Ctrl+A b`                         |
| Zoom pane (toggle) *(default)*     | `Ctrl+A z`                         |
| Close pane *(default)*             | `Ctrl+A x`                         |
| Resize mode *(default)*            | `Ctrl+A r`                         |
| Copy mode *(default)*              | `Ctrl+A [`                         |

## Tabs

| Action                      | Key                                                |
| --------------------------- | -------------------------------------------------- |
| New tab *(default)*         | `Ctrl+A c`                                         |
| Next / prev tab *(default)* | `Ctrl+A n` / `Ctrl+A p`                            |
| Jump to tab 1–10            | `Ctrl+A` `& é " ' ( § è ! ç à` (AZERTY number row) |

## Navigate mode

Open the workspace/sidebar navigation surface with `Ctrl+A w`, then move without
the arrow keys:

| Action                  | Key                                    |
| ----------------------- | -------------------------------------- |
| Move between workspaces | `Ctrl+K` / `Ctrl+J` (↑ / ↓ still work) |
| Move between panes      | `h` `j` `k` `l`                        |

## Agents

| Action         | Key              |
| -------------- | ---------------- |
| Next agent     | `Ctrl+A a`       |
| Previous agent | `Ctrl+A Shift+A` |

## Workspaces, worktrees & tools

| Action                              | Key                                        |
| ----------------------------------- | ------------------------------------------ |
| Command palette (repos + worktrees) | `Ctrl+A Space`                             |
| Workspace picker / navigate         | `Ctrl+A w`                                 |
| Jump to workspace 1–9               | `Ctrl+A Shift+` `1…9` (shifted number row) |
| New workspace *(default)*           | `Ctrl+A Shift+N`                           |
| Toggle sidebar                      | `Ctrl+A B`                                 |
| Lazygit popup                       | `Ctrl+A Ctrl+G`                            |

### Command palette — `Ctrl+A Space`

The center of the repo/worktree workflow: one popup listing every git repo
under `~/dev` with its worktrees nested underneath. Open (●) spaces sit at the
top, ordered by last visit — not git activity. `○` = on disk, not open.

| In the palette | Action                                                                                                    |
| -------------- | --------------------------------------------------------------------------------------------------------- |
| _type_         | fuzzy-filter by repo / branch name                                                                        |
| `Enter`        | open — or focus, if already live — the highlighted space                                                  |
| `N`            | **new worktree** for that row's repo: pick an existing branch or type a new one (labelled `repo · branch`) |
| `D`            | **delete** the space — worktree: remove the checkout (branch kept); repo: close the workspace (files kept) |

A **worktree is just a workspace**: it sits indented under its parent repo in
both the palette and the sidebar, and you can also jump to it with `Shift+1…9`.
From a shell, `hwt <branch>` is the scriptable twin of `N` (same `repo · branch`
label). There is deliberately **one** way to create a worktree — the native
`Ctrl+A Shift+G` is unbound.

| Action                      | Key / command |
| --------------------------- | ------------- |
| Keybinding help *(default)* | `Ctrl+A ?`    |
| Settings *(default)*        | `Ctrl+A s`    |

## Session

| Action                             | Command / Key                |
| ---------------------------------- | ---------------------------- |
| Attach (default session)           | `h` or `herdr`               |
| Attach / create named              | `ha work`                    |
| Pick session (fzf)                 | `ha`                         |
| List sessions                      | `hl`                         |
| Stop session                       | `hk` or `hk work`            |
| Detach (leave running) *(default)* | `Ctrl+A q`                   |
| Reload config                      | `herdr server reload-config` |

## Notes

- Herdr auto-saves layout; no resurrect/continuum plugins needed.
- Config is a read-only symlink into the Nix store, so theme/settings changes
  made in the Herdr UI will not persist. Edit `config/herdr/config.toml` and run
  `hms`.
- Managed by the official Herdr flake pinned in `flake.nix` (currently 0.9.0);
  bump the tag there and `nix flake update herdr`.

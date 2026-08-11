# Herdr cheat sheet

Prefix: **Ctrl+A** (AZERTY-friendly; ASCII input switches while prefix is active)

Press **Ctrl+A ?** inside Herdr for the live keybind list.

## Command palette

**`Ctrl+A` `Space`** (or `Cmd+P`) opens a fuzzy palette over everything:

- every tab, with workspace name and agent status dot
- every agent, blocked/working/idle at a glance
- worktree checkouts for this repo that aren't open yet
- verbs with no dedicated key: rename pane/tab/workspace, close tab/workspace,
  new workspace (picks from `~/dev`), remove worktree, reload config

`Ctrl+j` / `Ctrl+k` move the selection. This is the fastest way to get anywhere.

## Layout (tabs & panes)

| Action | Key |
|--------|-----|
| New tab | `Ctrl+A` `c` |
| Split side-by-side | `Ctrl+A` `)` |
| Split stacked | `Ctrl+A` `-` |
| Focus pane | `Ctrl+A` `h/j/k/l` or `Ctrl+h/j/k/l` |
| Swap pane up / down | `Ctrl+A` `p` / `P` |
| Swap pane left / right | `Ctrl+A` `H` / `L` |
| Next / prev tab | `Ctrl+A` `n` / `N` (shift+n) |
| Jump to tab 1–10 | `Ctrl+A` `& é " ' ( § è ! ç à` |
| Break pane → new tab | `Ctrl+A` `b` |
| Close pane | `Ctrl+A` `x` |
| Zoom pane | `Ctrl+A` `z` |
| Resize mode | `Ctrl+A` `r` |
| Copy mode | `Ctrl+A` `[` |

## Workspaces & agents

| Action | Key |
|--------|-----|
| Workspace picker | `Ctrl+A` `w` |
| New workspace | `Ctrl+A` `Shift+N` |
| Goto navigator | `Ctrl+A` `g` |
| Create worktree | `Ctrl+A` `Shift+G` |
| Open worktree | `Ctrl+A` `Ctrl+W` |
| Jump to agent | `Ctrl+A` `Space` (palette) |
| Toggle sidebar | `Ctrl+A` `Shift+B` |
| Lazygit popup | `Ctrl+A` `Ctrl+G` |

## Session

| Action | Command |
|--------|---------|
| Attach (default) | `h` or `herdr` |
| Attach / create named | `ha work` |
| Pick session (fzf) | `ha` |
| List sessions | `hl` |
| Stop session | `hk` or `hk work` |
| Detach (leave running) | `Ctrl+A` `q` |
| Stop server entirely | `herdr server stop` |
| Reload config | `herdr server reload-config` |

## Git worktrees

| Action | Command |
|--------|---------|
| Create worktree + workspace | `hwt feature/foo` |
| Open existing (in Herdr) | `Ctrl+A` `Ctrl+W` |

## Common workflows

**Start your day**
```bash
ha work          # attach or create "work" session
```

**Open a project as a workspace**
```bash
Ctrl+A Space     # palette → "new workspace…" → pick from ~/dev
```

**Check who's blocked**
```bash
Ctrl+A Space     # palette lists agents with a status dot
```

**Quick git review**
```bash
Ctrl+A Ctrl+G    # lazygit popup, Esc to close
```

**Detach and come back**
```bash
Ctrl+A q         # or just close the terminal window
herdr            # everything still running
```

**Separate contexts (like tmux sessions)**
```bash
ha work
ha personal
ha chipwise      # type a new name in fzf to create it
```

## Tmux → Herdr mapping

| Tmux (you) | Herdr |
|------------|-------|
| `C-a` prefix | `Ctrl+A` |
| `c` new window | `c` new tab |
| `)` / `-` splits | same keys |
| `h/j/k/l` panes | same + `Ctrl+h/j/k/l` |
| `p` / `P` swap | same |
| `&…à` windows 1–10 | same AZERTY keys |
| `b` break pane | `b` → new tab |
| `td` detach | `Ctrl+A q` |
| `ta` attach | `ha` |
| `tk` kill session | `hk` |

## Notes

- Herdr auto-saves layout; no continuum/resurrect plugins needed.
- Config is a read-only symlink into the Nix store, so theme/settings changes
  made in the Herdr UI will not persist. Edit `config/herdr/config.toml` and
  run `hms` instead.
- The palette is a local plugin, re-linked automatically on every `hms`.
- `ui.tab_bar_position = "bottom"` needs herdr 0.8+; nixpkgs has 0.7.5 for now.

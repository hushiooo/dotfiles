HERDR=${HERDR_BIN_PATH:-herdr}
REPOS=$HOME/dev

ESC=$(printf '\033')
DIM="${ESC}[38;2;86;95;137m"
OFF="${ESC}[0m"

FZF=(
  --ansi
  --layout=reverse
  --border=rounded
  --info=inline-right
  --highlight-line
  --no-scrollbar
  --pointer='▶'
  --prompt='❯ '
  '--color=fg:#c0caf5,bg:-1,hl:#bb9af7,fg+:#c0caf5,bg+:#283457,hl+:#7dcfff'
  '--color=info:#7aa2f7,border:#3b4261,label:#7aa2f7,gutter:-1'
  '--color=prompt:#7dcfff,pointer:#7dcfff,marker:#9ece6a,header:#9ece6a'
)

# Colored status dot, shared by the tab and agent rows.
# shellcheck disable=SC2016 # $e is a jq variable, not a shell one
JQ_DOT='
def paint(c): $e + "[38;2;" + c + "m" + . + $e + "[0m";
def dim: paint("86;95;137");
def dot:
  if . == "working" then ("●" | paint("224;175;104"))
  elif . == "idle" then ("●" | paint("158;206;106"))
  elif . == "blocked" then ("●" | paint("247;118;142"))
  else ("○" | paint("86;95;137")) end;
'

# A popup closes the instant this script exits, so failures have to hold the
# frame open long enough to be read.
die() {
  printf '\n%s\n' "$1" >&2
  read -rsn1 -p 'press any key…' _ || true
  exit 1
}

run() {
  local out
  out=$("$@" 2>&1) || die "$out"
  case $out in *'"error"'*) die "$out" ;; esac
}

ask() {
  local reply
  read -r -p "$1: " reply || return 1
  [ -n "$reply" ] || return 1
  printf '%s' "$reply"
}

confirm() {
  local answer
  answer=$(printf 'no\nyes\n' | fzf "${FZF[@]}" --height=6 --info=hidden --prompt="$1 ") || return 1
  [ "$answer" = yes ]
}

require() {
  [ -n "${2:-}" ] || die "no focused $1 to act on"
}

panes=$("$HERDR" pane list)
tabs=$("$HERDR" tab list)
spaces=$("$HERDR" workspace list)

pane=$(jq -r 'first(.result.panes[] | select(.focused) | .pane_id) // empty' <<<"$panes")
tab=$(jq -r 'first(.result.tabs[] | select(.focused) | .tab_id) // empty' <<<"$tabs")
space=$(jq -r 'first(.result.workspaces[] | select(.focused) | .workspace_id) // empty' <<<"$spaces")
labels=$(jq -c '[.result.workspaces[] | {key: .workspace_id, value: .label}] | from_entries' <<<"$spaces")

jumps=$(jq -r --arg e "$ESC" --argjson labels "$labels" "$JQ_DOT"'
  .result.tabs[]
  | "jump\t\(.agent_status | dot) \("tab " | dim) \($labels[.workspace_id] // .workspace_id) \("› " + .label | dim)\t\(.tab_id)"
' <<<"$tabs")

agents=$("$HERDR" agent list | jq -r --arg e "$ESC" "$JQ_DOT"'
  .result.agents[]?
  | "agent\t\(.agent_status | dot) \("agt " | dim) \(.name // .display_agent // .agent // "agent") \(.terminal_title_stripped // .cwd // "" | dim)\t\(.pane_id)"
')

# Worktree checkouts for this repo that are not already open as a workspace.
worktrees=""
if [ -n "$space" ]; then
  worktrees=$("$HERDR" worktree list --workspace "$space" 2>/dev/null | jq -r --arg e "$ESC" "$JQ_DOT"'
    .result.worktrees[]? | select(.open_workspace_id == null)
    | "worktree\t\("·" | dim) \("git " | dim) \(.branch // "detached") \(.path | dim)\t\(.path)"
  ' || true)
fi

verb() { printf 'verb\t%s· run %s%s\t%s\n' "$DIM" "$OFF" "$1" "$2"; }
verbs=$(
  verb 'rename pane…' pane.rename
  verb 'rename tab…' tab.rename
  verb 'close tab' tab.close
  verb 'new workspace…' space.new
  verb 'rename workspace…' space.rename
  verb 'close workspace' space.close
  verb 'remove this worktree' worktree.remove
  verb 'reload config' config.reload
)

rows=$(printf '%s\n' "$jumps" "$agents" "$worktrees" "$verbs" | grep -v '^[[:space:]]*$' || true)
count=$(printf '%s\n' "$rows" | wc -l | tr -d ' ')

# Escape hatch for checking row generation without a tty.
if [ "${1:-}" = --list ]; then
  printf '%s\n' "$rows"
  exit 0
fi

pick=$(fzf "${FZF[@]}" \
  --delimiter=$'\t' \
  --with-nth=2 \
  --list-label=" $count targets " \
  --bind 'ctrl-j:down,ctrl-k:up' \
  <<<"$rows") || exit 0

kind=${pick%%$'\t'*}
arg=${pick##*$'\t'}

case $kind in
jump) run "$HERDR" tab focus "$arg" ;;
agent) run "$HERDR" agent focus "$arg" ;;
worktree)
  require workspace "$space"
  run "$HERDR" worktree open --workspace "$space" --path "$arg" --focus
  ;;
verb)
  case $arg in
  pane.rename)
    require pane "$pane"
    label=$(ask 'pane label') || exit 0
    run "$HERDR" pane rename "$pane" "$label"
    ;;
  tab.rename)
    require tab "$tab"
    label=$(ask 'tab label') || exit 0
    run "$HERDR" tab rename "$tab" "$label"
    ;;
  tab.close)
    require tab "$tab"
    confirm 'close tab?' || exit 0
    run "$HERDR" tab close "$tab"
    ;;
  space.new)
    dir=$(find "$REPOS" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort \
      | fzf "${FZF[@]}" --list-label=' repos ' --prompt='dir ❯ ') || exit 0
    [ -n "$dir" ] || exit 0
    run "$HERDR" workspace create --cwd "$dir" --label "$(basename "$dir")" --focus
    ;;
  space.rename)
    require workspace "$space"
    label=$(ask 'workspace label') || exit 0
    run "$HERDR" workspace rename "$space" "$label"
    ;;
  space.close)
    require workspace "$space"
    confirm 'close workspace?' || exit 0
    run "$HERDR" workspace close "$space"
    ;;
  worktree.remove)
    require workspace "$space"
    confirm 'remove worktree checkout?' || exit 0
    run "$HERDR" worktree remove --workspace "$space"
    ;;
  config.reload) run "$HERDR" server reload-config ;;
  esac
  ;;
esac

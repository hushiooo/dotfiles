# Interactive helpers, sourced from .zshrc (see home/zsh.nix).

mkcd() { mkdir -p "$1" && cd "$1"; }

# Update flake inputs, review the package diff, and commit the lock file only
# once the new generation is activated.
hmu() {
  nix flake update --flake "$NH_FLAKE" \
    && nh home switch --ask \
    && git -C "$NH_FLAKE" commit --quiet -m "flake.lock: update inputs" -- flake.lock \
    && git -C "$NH_FLAKE" log -1 --oneline
}

# Activate the generation just older than the current one (repeatable).
hmr() {
  local previous
  previous="$(home-manager generations | awk 'found { print $7; exit } / \(current\)$/ { found = 1 }')"
  if [[ -z "$previous" ]]; then
    echo "No previous generation to roll back to" >&2
    return 1
  fi
  echo "Activating $previous"
  "$previous/activate"
}

tn() { tmux new-session -s "${1:-$(basename "$PWD")}"; }

asp() {
  local config="${AWS_CONFIG_FILE:-$HOME/.aws/config}"
  local credentials="${AWS_SHARED_CREDENTIALS_FILE:-$HOME/.aws/credentials}"
  local current="${AWS_PROFILE:-${AWS_DEFAULT_PROFILE:-none}}"

  if [[ "$1" == "-" ]]; then
    unset AWS_PROFILE AWS_DEFAULT_PROFILE
    echo "AWS profile cleared"
    return 0
  fi

  local profiles_raw
  profiles_raw="$(
    {
      [[ -f "$config" ]] && sed -n -E \
        -e 's/^\[profile[[:space:]]+(.+)\][[:space:]]*$/\1/p' \
        -e 's/^\[default\][[:space:]]*$/default/p' \
        "$config"
      [[ -f "$credentials" ]] && sed -n -E \
        's/^\[([^]]+)\][[:space:]]*$/\1/p' \
        "$credentials"
    } | awk 'NF' | sort -u
  )"

  if [[ -z "$profiles_raw" ]]; then
    echo "No AWS profiles found (checked $config and $credentials)" >&2
    return 1
  fi

  local -a profile_list rm_profiles
  profile_list=("${(@f)profiles_raw}")

  case "$1" in
    -h|--help)
      printf '%s\n' \
        "Usage:" \
        "  asp                 Select AWS profile interactively" \
        "  asp <profile>       Switch to a specific profile" \
        "  asp rm              Select a risk-management profile only" \
        "  asp rm <env> [role] Shortcut for stoik-risk-management-<env>-<role>" \
        "  asp --list          List known profiles" \
        "  asp --current       Show current profile and identity status" \
        "  asp --login         Run aws sso login for current profile" \
        "  asp -               Clear profile from current shell" \
        "" \
        "Examples:" \
        "  asp rm" \
        "  asp rm staging admin" \
        "  task build-deploy TG_ENV=staging ROLE=admin"
      return 0
      ;;
    --list|-l)
      echo "$profiles_raw"
      return 0
      ;;
    --current|-c)
      echo "Current AWS profile: $current"
      if [[ "$current" != "none" ]]; then
        aws sts get-caller-identity --profile "$current" --query 'Arn' --output text 2>/dev/null || \
          echo "SSO session missing/expired for $current"
      fi
      return 0
      ;;
    --login)
      if [[ "$current" == "none" ]]; then
        echo "No profile selected. Use: asp <profile>" >&2
        return 1
      fi
      aws sso login --profile "$current"
      return $?
      ;;
  esac

  local selected
  if [[ "$1" == "rm" ]]; then
    shift
    if [[ -n "$1" || -n "$2" ]]; then
      local env="${1:-staging}"
      local role="${2:-admin}"
      selected="stoik-risk-management-$env-$role"
    else
      rm_profiles=("${(@M)profile_list:#stoik-risk-management-*}")
      if (( ${#rm_profiles[@]} == 0 )); then
        echo "No stoik risk-management profiles found" >&2
        return 1
      fi
      selected="$(printf '%s\n' "${rm_profiles[@]}" | fzf \
        --prompt="RM AWS profile ❯ " \
        --header="Current: $current | shortcut: asp rm staging admin" \
        --preview="aws configure list --profile {}" \
        --preview-window=down:4:wrap)"
    fi
  else
    selected="${1:-$(printf '%s\n' "${profile_list[@]}" | fzf \
      --prompt="AWS profile ❯ " \
      --header="Current: $current" \
      --preview="aws configure list --profile {}" \
      --preview-window=down:4:wrap)}"
  fi

  if [[ -z "$selected" ]]; then
    return 0
  fi

  if (( ${profile_list[(Ie)$selected]} == 0 )); then
    echo "Unknown AWS profile: $selected" >&2
    echo "Use 'asp --list' to inspect available profiles." >&2
    return 1
  fi

  export AWS_PROFILE="$selected"
  export AWS_DEFAULT_PROFILE="$selected"

  local account
  account="$(aws sts get-caller-identity --profile "$selected" --query 'Account' --output text 2>/dev/null || true)"
  if [[ -n "$account" ]]; then
    echo "Switched to AWS profile: $selected (account: $account)"
  else
    echo "Switched to AWS profile: $selected"
    echo "SSO session missing/expired. Run: aws sso login --profile $selected"
  fi
}

gco() {
  local branch
  if [[ -n "$1" ]]; then
    git checkout "$@"
    return
  fi
  git fetch --prune --quiet 2>/dev/null
  branch=$(git branch -a --sort=-committerdate \
    | sed 's/^[* ]*//' \
    | sed 's|remotes/origin/||' \
    | sed '/^$/d; /HEAD/d' \
    | awk '!seen[$0]++' \
    | fzf \
      --prompt="branch ❯ " \
      --header="checkout branch" \
      --preview="git log --oneline --graph --color=always -20 {} 2>/dev/null")
  if [[ -n "$branch" ]]; then
    git checkout "$branch"
  fi
}

ta() {
  local session
  if [[ -n "$1" ]]; then
    tmux attach -t "$1"
    return
  fi
  session=$(tmux list-sessions -F "#{session_name}: #{session_windows} windows (created #{session_created_string})" 2>/dev/null \
    | fzf \
      --prompt="tmux attach ❯ " \
      --header="select session" \
      --preview="tmux list-windows -t {1}" \
    | cut -d: -f1)
  if [[ -n "$session" ]]; then
    tmux attach -t "$session"
  fi
}

tk() {
  local session
  if [[ -n "$1" ]]; then
    tmux kill-session -t "$1"
    return
  fi
  session=$(tmux list-sessions -F "#{session_name}: #{session_windows} windows (created #{session_created_string})" 2>/dev/null \
    | fzf \
      --prompt="tmux kill ❯ " \
      --header="select session to kill" \
      --preview="tmux list-windows -t {1}" \
    | cut -d: -f1)
  if [[ -n "$session" ]]; then
    tmux kill-session -t "$session"
    echo "Killed session: $session"
  fi
}

ha() {
  local name
  if [[ -n "$1" ]]; then
    herdr --session "$1"
    return
  fi
  name=$(herdr session list --json \
    | jq -r '.sessions[] | "\(.name)\t\(if .running then "running" else "stopped" end)"' \
    | fzf --print-query \
      --prompt="herdr session ❯ " \
      --header="enter to attach, or type a new name to create" \
    | tail -n1 \
    | cut -f1)
  if [[ -n "$name" ]]; then
    herdr --session "$name"
  fi
}

hk() {
  local name
  if [[ -n "$1" ]]; then
    herdr session stop "$1"
    return
  fi
  name=$(herdr session list --json \
    | jq -r '.sessions[] | select(.running) | .name' \
    | fzf --prompt="herdr stop ❯ " --header="select a running session to stop")
  if [[ -n "$name" ]]; then
    herdr session stop "$name"
    echo "Stopped session: $name"
  fi
}

# Scriptable twin of the palette's "N" (prefix+space): create a worktree
# for the current repo with the same repo-prefixed "repo · branch" label.
hwt() {
  local branch="$1"
  if [[ -z "$branch" ]]; then
    echo "usage: hwt <branch>" >&2
    return 1
  fi
  local common repo
  common="$(git -C "$PWD" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)"
  repo="$(basename "$(dirname "$common")")"
  herdr worktree create --cwd "$PWD" --branch "$branch" \
    --label "${repo:+$repo · }$branch" --focus
}

fkill() {
  local line pid
  line=$(lsof -i -P -n | rg LISTEN \
    | fzf \
      --prompt="kill port ❯ " \
      --header="select process to kill")
  if [[ -n "$line" ]]; then
    pid=$(echo "$line" | awk '{print $2}')
    echo "Killing PID $pid ($(echo "$line" | awk '{print $1, $9}'))"
    kill -9 "$pid"
  fi
}

dex() {
  local container
  container=$(docker ps --format '{{.Names}}\t{{.Image}}\t{{.Status}}' \
    | fzf \
      --prompt="docker exec ❯ " \
      --header="select container" \
      --preview="docker inspect --format '{{`{{json .Config.Env}}`}}' {1} | jq -r '.[]'" \
    | awk '{print $1}')
  if [[ -n "$container" ]]; then
    docker exec -it "$container" "${1:-sh}"
  fi
}

dlf() {
  local container
  container=$(docker ps -a --format '{{.Names}}\t{{.Image}}\t{{.Status}}' \
    | fzf \
      --prompt="docker logs ❯ " \
      --header="select container" \
      --preview="docker logs --tail 5 {1}" \
    | awk '{print $1}')
  if [[ -n "$container" ]]; then
    docker logs -f --tail 100 "$container"
  fi
}

# Compound extensions (.tar.gz) must precede their suffixes (.gz).
extract() {
  if [[ ! -f "$1" ]]; then
    echo "'$1' is not a valid file" >&2
    return 1
  fi
  case "$1" in
    *.tar.bz2|*.tbz2) tar xjf "$1" ;;
    *.tar.gz|*.tgz)   tar xzf "$1" ;;
    *.tar.xz)         tar xJf "$1" ;;
    *.tar)            tar xf "$1" ;;
    *.7z)             7z x "$1" ;;
    *.bz2)            bunzip2 "$1" ;;
    *.gz)             gunzip "$1" ;;
    *.Z)              uncompress "$1" ;;
    *.zip)            unzip "$1" ;;
    *)                echo "'$1' cannot be extracted" >&2; return 1 ;;
  esac
}

ti() {
  local sel
  sel=$(command task -l \
    | fzf --preview 'command task --summary {2}' --preview-window=right:60%:wrap \
    | awk '{print $2}' | tr -d ':')
  [[ -z "$sel" ]] && return
  print -z "task $sel "
}

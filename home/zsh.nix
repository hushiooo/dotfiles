{ config, pkgs, ... }:
{
  enable = true;
  autosuggestion.enable = true;
  enableCompletion = true;

  envExtra = ''
    if [[ -x /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  '';

  shellAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    c = "clear";
    cat = "bat";
    cp = "cp -iv";
    d = "docker";
    dc = "docker compose";
    dcd = "docker compose down";
    dcl = "docker compose logs -f";
    dcu = "docker compose up -d";
    dev = "cd ~/dev";
    dps = "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'";
    e = "$EDITOR";
    g = "git";
    ga = "git add";
    gaa = "git add -A";
    gc = "git commit";
    gca = "git commit --amend";
    gcm = "git commit -m";
    gcob = "git checkout -b";
    gd = "git diff";
    gds = "git diff --staged";
    gf = "git fetch --all --prune";
    gp = "git push";
    gpf = "git push --force-with-lease";
    gpl = "git pull --rebase";
    gs = "git status -sb";
    hms = "home-manager switch --flake ~/dotfiles";
    hmu = "nix flake update ~/dotfiles && home-manager switch --flake ~/dotfiles";
    la = "eza -a";
    lg = "lazygit";
    ll = "eza -alh --git";
    ls = "eza";
    lt = "eza --tree --level=2";
    lta = "eza --tree --level=2 -a";
    lzd = "lazydocker";
    mkdir = "mkdir -pv";
    mv = "mv -iv";
    myip = "curl -s https://ipinfo.io/ip";
    nxgc = "nix-collect-garbage -d";
    nd = "nix develop -c zsh";
    path = "echo $PATH | tr ':' '\\n'";
    ports = "lsof -i -P -n | rg LISTEN";
    rm = "rm -iv";
    t = "tmux";
    td = "tmux detach";
    tka = "tmux kill-server";
    tl = "tmux list-sessions";
    weather = "curl -s 'wttr.in?format=3'";
    week = "date +%V";
  };

  plugins = [
    {
      name = "zsh-history-substring-search";
      src = pkgs.zsh-history-substring-search;
    }
    {
      name = "zsh-syntax-highlighting";
      src = pkgs.zsh-syntax-highlighting;
    }
  ];

  history = {
    expireDuplicatesFirst = true;
    extended = true;
    ignoreAllDups = true;
    ignoreDups = true;
    ignoreSpace = true;
    path = "${config.xdg.stateHome}/zsh/history";
    save = 100000;
    share = true;
    size = 100000;
  };

  initContent = ''
    source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
    source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

    setopt AUTO_CD
    setopt AUTO_PUSHD
    setopt AUTO_RESUME
    setopt CORRECT
    setopt EXTENDED_GLOB
    setopt HIST_VERIFY
    setopt NO_BEEP
    setopt NOTIFY
    setopt PROMPT_SUBST
    setopt PUSHD_IGNORE_DUPS
    setopt PUSHD_MINUS
    setopt PUSHD_SILENT
    setopt PUSHD_TO_HOME
    setopt vi
    DIRSTACKSIZE=20


    bindkey '^[[1;5C' forward-word
    bindkey '^[[1;5D' backward-word
    bindkey '^[[3~' delete-char
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    bindkey '^[[F' end-of-line
    bindkey '^[[H' beginning-of-line
    bindkey '^I' autosuggest-accept
    bindkey '^K' kill-line

    bindkey '^U' backward-kill-line

    export GPG_TTY=$(tty)

    mkcd() { mkdir -p "$1" && cd "$1"; }
    tn() { tmux new-session -s "''${1:-$(basename "$PWD")}"; }

    asp() {
      local config="''${AWS_CONFIG_FILE:-$HOME/.aws/config}"
      if [[ ! -f "$config" ]]; then
        echo "AWS config not found: $config" >&2
        return 1
      fi

      if [[ "$1" == "-" ]]; then
        unset AWS_PROFILE AWS_DEFAULT_PROFILE
        echo "AWS profile cleared"
        return 0
      fi

      local profiles
      profiles=$(sed -n 's/^\[profile \(.*\)\]$/\1/p' "$config" | sort)
      if [[ -z "$profiles" ]]; then
        echo "No profiles found in $config" >&2
        return 1
      fi

      local selected="''${1:-$(echo "$profiles" | fzf \
        --prompt="AWS profile ❯ " \
        --header="Current: ''${AWS_PROFILE:-none}" \
        --preview="aws configure list --profile {}" \
        --preview-window=down:4:wrap)}"

      if [[ -n "$selected" ]]; then
        export AWS_PROFILE="$selected"
        export AWS_DEFAULT_PROFILE="$selected"
        echo "Switched to AWS profile: $selected"
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
        docker exec -it "$container" "''${1:-sh}"
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

    extract() {
      if [[ -f "$1" ]]; then
        case "$1" in
          *.7z)      7z x "$1" ;;
          *.bz2)     bunzip2 "$1" ;;
          *.gz)      gunzip "$1" ;;
          *.tar)     tar xf "$1" ;;
          *.tar.bz2) tar xjf "$1" ;;
          *.tar.gz)  tar xzf "$1" ;;
          *.tar.xz)  tar xJf "$1" ;;
          *.tbz2)    tar xjf "$1" ;;
          *.tgz)     tar xzf "$1" ;;
          *.Z)       uncompress "$1" ;;
          *.zip)     unzip "$1" ;;
          *)         echo "'$1' cannot be extracted" ;;
        esac
      else
        echo "'$1' is not a valid file"
      fi
    }
  '';
}

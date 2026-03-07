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
    tf_clean = "rm -rfv **/.terragrunt-cache/";
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
      local credentials="''${AWS_SHARED_CREDENTIALS_FILE:-$HOME/.aws/credentials}"
      local current="''${AWS_PROFILE:-''${AWS_DEFAULT_PROFILE:-none}}"

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
      profile_list=("''${(@f)profiles_raw}")

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
          local env="''${1:-staging}"
          local role="''${2:-admin}"
          selected="stoik-risk-management-$env-$role"
        else
          rm_profiles=("''${(@M)profile_list:#stoik-risk-management-*}")
          if (( ''${#rm_profiles[@]} == 0 )); then
            echo "No stoik risk-management profiles found" >&2
            return 1
          fi
          selected="$(printf '%s\n' "''${rm_profiles[@]}" | fzf \
            --prompt="RM AWS profile ❯ " \
            --header="Current: $current | shortcut: asp rm staging admin" \
            --preview="aws configure list --profile {}" \
            --preview-window=down:4:wrap)"
        fi
      else
        selected="''${1:-$(printf '%s\n' "''${profile_list[@]}" | fzf \
          --prompt="AWS profile ❯ " \
          --header="Current: $current" \
          --preview="aws configure list --profile {}" \
          --preview-window=down:4:wrap)}"
      fi

      if [[ -z "$selected" ]]; then
        return 0
      fi

      if (( ''${profile_list[(Ie)$selected]} == 0 )); then
        echo "Unknown AWS profile: $selected" >&2
        echo "Use 'asp --list' to inspect available profiles." >&2
        return 1
      fi

      if [[ -n "$selected" ]]; then
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

{ config, pkgs }:
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
    hms = "home-manager switch --flake ~/dotfiles";
    hmu = "nix flake update ~/dotfiles && home-manager switch --flake ~/dotfiles";
    nxgc = "nix-collect-garbage -d";

    cat = "bat";
    grep = "rg";
    find = "fd";
    ls = "eza";
    la = "eza -a";
    ll = "eza -alh --git";
    lt = "eza --tree --level=2";
    lta = "eza --tree --level=2 -a";

    g = "git";
    ga = "git add";
    gaa = "git add -A";
    gc = "git commit";
    gcm = "git commit -m";
    gca = "git commit --amend";
    gp = "git push";
    gpf = "git push --force-with-lease";
    gpl = "git pull --rebase";
    gf = "git fetch --all --prune";
    gco = "git checkout";
    gcob = "git checkout -b";
    gd = "git diff";
    gds = "git diff --staged";
    gs = "git status -sb";
    gl = "git lg";
    gst = "git stash";
    gstp = "git stash pop";
    lg = "lazygit";

    t = "tmux";
    ta = "tmux attach -t";
    tl = "tmux list-sessions";
    tk = "tmux kill-session -t";
    tka = "tmux kill-server";

    d = "docker";
    dc = "docker compose";
    dcu = "docker compose up -d";
    dcd = "docker compose down";
    dcl = "docker compose logs -f";
    dps = "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'";
    lzd = "lazydocker";

    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    "~" = "cd ~";
    dev = "cd ~/dev";

    cp = "cp -iv";
    mv = "mv -iv";
    rm = "rm -iv";
    mkdir = "mkdir -pv";

    c = "clear";
    e = "$EDITOR";
    path = "echo $PATH | tr ':' '\\n'";
    ports = "lsof -i -P -n | grep LISTEN";
    myip = "curl -s https://ipinfo.io/ip";
    weather = "curl -s 'wttr.in?format=3'";
    week = "date +%V";
  };

  plugins = [
    {
      name = "zsh-syntax-highlighting";
      src = pkgs.zsh-syntax-highlighting;
    }
    {
      name = "zsh-history-substring-search";
      src = pkgs.zsh-history-substring-search;
    }
  ];

  history = {
    expireDuplicatesFirst = true;
    ignoreDups = true;
    ignoreSpace = true;
    ignoreAllDups = true;
    save = 100000;
    size = 100000;
    share = true;
    extended = true;
    path = "${config.xdg.stateHome}/zsh/history";
  };

  initContent = ''
    source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
    source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

    setopt AUTO_RESUME
    setopt NOTIFY
    setopt PROMPT_SUBST
    setopt vi
    setopt HIST_VERIFY
    setopt HIST_IGNORE_ALL_DUPS
    setopt EXTENDED_GLOB
    setopt NO_BEEP
    setopt AUTO_CD
    setopt CORRECT

    setopt AUTO_PUSHD
    setopt PUSHD_MINUS
    setopt PUSHD_SILENT
    setopt PUSHD_TO_HOME
    setopt PUSHD_IGNORE_DUPS
    DIRSTACKSIZE=20

    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    bindkey '^[[H' beginning-of-line
    bindkey '^[[F' end-of-line
    bindkey '^[[3~' delete-char
    bindkey '^R' history-incremental-search-backward
    bindkey '^I' autosuggest-accept
    bindkey '^[[1;5C' forward-word
    bindkey '^[[1;5D' backward-word
    bindkey '^U' backward-kill-line
    bindkey '^K' kill-line

    export GPG_TTY=$(tty)

    mkcd() { mkdir -p "$1" && cd "$1"; }
    tn() { tmux new-session -s "''${1:-$(basename "$PWD")}"; }

    extract() {
      if [[ -f "$1" ]]; then
        case "$1" in
          *.tar.bz2) tar xjf "$1" ;;
          *.tar.gz)  tar xzf "$1" ;;
          *.tar.xz)  tar xJf "$1" ;;
          *.bz2)     bunzip2 "$1" ;;
          *.gz)      gunzip "$1" ;;
          *.tar)     tar xf "$1" ;;
          *.tbz2)    tar xjf "$1" ;;
          *.tgz)     tar xzf "$1" ;;
          *.zip)     unzip "$1" ;;
          *.Z)       uncompress "$1" ;;
          *.7z)      7z x "$1" ;;
          *)         echo "'$1' cannot be extracted" ;;
        esac
      else
        echo "'$1' is not a valid file"
      fi
    }
  '';
}

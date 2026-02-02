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
    "~" = "cd ~";
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
    find = "fd";
    g = "git";
    ga = "git add";
    gaa = "git add -A";
    gc = "git commit";
    gca = "git commit --amend";
    gcm = "git commit -m";
    gco = "git checkout";
    gcob = "git checkout -b";
    gd = "git diff";
    gds = "git diff --staged";
    gf = "git fetch --all --prune";
    gl = "git lg";
    gp = "git push";
    gpf = "git push --force-with-lease";
    gpl = "git pull --rebase";
    grep = "rg";
    gs = "git status -sb";
    gst = "git stash";
    gstp = "git stash pop";
    hms = "home-manager switch --flake ~/dotfiles";
    hmu = "nix flake update ~/dotfiles && home-manager switch --flake ~/dotfiles";
    aws = "aws";
    awsp = "aws --profile";
    awsr = "aws --region";
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
    ports = "lsof -i -P -n | grep LISTEN";
    rm = "rm -iv";
    t = "tmux";
    ta = "tmux attach -t";
    td = "tmux detach";
    tk = "tmux kill-session -t";
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
    setopt HIST_IGNORE_ALL_DUPS
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
    bindkey '^R' history-incremental-search-backward
    bindkey '^U' backward-kill-line

    export GPG_TTY=$(tty)

    mkcd() { mkdir -p "$1" && cd "$1"; }
    tn() { tmux new-session -s "''${1:-$(basename "$PWD")}"; }

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

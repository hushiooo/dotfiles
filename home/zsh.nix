{ config, lib, ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;

    envExtra = ''
      if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi
    '';

    profileExtra = ''
      source ~/.orbstack/shell/init.zsh 2>/dev/null || :
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
      h = "herdr";
      hl = "herdr session list";
      hms = "nh home switch";
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
      nxgc = "nh clean user";
      nd = "nix develop";
      path = "echo $PATH | tr ':' '\\n'";
      pic = "pi -c";
      pir = "pi -r";
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

    defaultKeymap = "viins";
    historySubstringSearch.enable = true;
    syntaxHighlighting.enable = true;

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

    setOptions = [
      "AUTO_CD"
      "AUTO_PUSHD"
      "AUTO_RESUME"
      "CORRECT"
      "EXTENDED_GLOB"
      "HIST_VERIFY"
      "NO_BEEP"
      "NOTIFY"
      "PROMPT_SUBST"
      "PUSHD_IGNORE_DUPS"
      "PUSHD_MINUS"
      "PUSHD_SILENT"
      "PUSHD_TO_HOME"
    ];

    localVariables.DIRSTACKSIZE = 20;

    initContent = lib.mkMerge [
      # macOS /etc/zprofile runs path_helper, which moves system dirs ahead of
      # everything exported in .zshenv. Restore home.sessionPath precedence.
      (lib.mkBefore ''
        path=(${lib.concatMapStringsSep " " (p: ''"${p}"'') config.home.sessionPath} $path)
        typeset -U path
      '')
      ''
        bindkey '^[[1;5C' forward-word
        bindkey '^[[1;5D' backward-word
        bindkey '^[[3~' delete-char
        bindkey '^[[F' end-of-line
        bindkey '^[[H' beginning-of-line
        # Tab accepts the autosuggestion; Shift-Tab is left for real completion.
        bindkey '^I' autosuggest-accept
        bindkey '^[[Z' expand-or-complete
        bindkey '^K' kill-line
        bindkey '^U' backward-kill-line
      ''
      (builtins.readFile ../config/zsh/functions.zsh)
    ];
  };
}

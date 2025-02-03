{ config, pkgs, ... }:
{
  enable = true;
  autosuggestion.enable = true;
  enableCompletion = true;
  envExtra = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';

  shellAliases = {
    mtop = "sudo mactop --interval 500 --color cyan";
    rebuild = "darwin-rebuild switch --flake . --show-trace";
    update = "nix flake update";

    # Tools
    cat = "bat";
    grep = "rg";
    find = "fd";
    ls = "eza";
    la = "eza -a";
    ll = "eza -alh";
    lt = "eza --tree";

    # Git
    g = "git";
    gs = "git status -sb";
    ga = "git add";
    gc = "git commit";
    gp = "git push";
    gf = "git fetch --all";
    gpl = "git pull";
    gd = "git diff";
    gl = "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";

    # Tmux
    t = "tmux";
    ta = "tmux attach -t";
    tad = "tmux attach -d -t";
    td = "tmux detach";
    ts = "tmux new-session -s";
    tl = "tmux list-sessions";
    tk = "tmux kill-session -t";
    tks = "tmux kill-server";
    tn = "tmux new -s $(basename $(pwd))";

    # Safety
    cp = "cp -i";
    mv = "mv -i";
    rm = "rm -i";

    # Misc
    httpc = "cd ~/dev/httpc && python main.py";
    tester = "uv run pytest -vv -n 4 --dist loadscope";
    tf_clean = "rm -rfv **/.terragrunt-cache/";
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
    save = 100000;
    size = 100000;
    share = true;
    extended = true;
    path = "${config.xdg.stateHome}/zsh/history";
  };

  initContent = ''
    # Additional autoloads
    autoload -Uz url-quote-magic
    zle -N self-insert url-quote-magic
    autoload -Uz bracketed-paste-magic
    zle -N bracketed-paste bracketed-paste-magic

    source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
    source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

    # Additional useful options
    setopt AUTO_RESUME          # Treat single word simple commands without redirection as candidates for resumption of an existing job
    setopt NOTIFY               # Report status of background jobs immediately
    setopt PROMPT_SUBST         # Parameter expansion, command substitution and arithmetic expansion in prompts
    setopt AUTO_CONTINUE        # Automatically resume disowned jobs
    setopt NO_HUP               # Don't kill background jobs when shell exits
    setopt LONG_LIST_JOBS       # List jobs in the long format by default
    setopt vi                   # Use vi key bindings in ZLE
    setopt HIST_VERIFY          # Don't execute immediately upon history expansion
    setopt HIST_IGNORE_ALL_DUPS # Delete old recorded entry if new entry is a duplicate
    setopt EXTENDED_GLOB        # Use extended globbing syntax

    # Additional key bindings
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    bindkey '^[[H' beginning-of-line
    bindkey '^[[F' end-of-line
    bindkey '^[[3~' delete-char
    bindkey '^H' backward-delete-char
    bindkey '^[[1;5C' forward-word
    bindkey '^[[1;5D' backward-word
    bindkey '^U' backward-kill-line
    bindkey '^Y' yank
    bindkey '^[b' backward-word
    bindkey '^[f' forward-word
    bindkey '^[.' insert-last-word
    bindkey '^R' history-incremental-search-backward
    bindkey '^I' autosuggest-accept

    # Directory stack
    DIRSTACKSIZE=20
    setopt autopushd pushdminus pushdsilent pushdtohome pushdignoredups

    # GPG configuration
    export GPG_TTY=$(tty)
  '';
}

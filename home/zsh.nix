{ config, pkgs, ... }:
{
  enable = true;
  autosuggestion.enable = true;
  enableCompletion = true;

  shellAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    mtop = "sudo mactop --interval 500 --color cyan";
    ports = "lsof -i -P -n | grep LISTEN";
    rebuild = "darwin-rebuild switch --flake ~/dotfiles#prime";
    update = "nix flake update";

    # Tools
    cat = "bat";
    grep = "rg";
    find = "fd";
    la = "eza -a --icons";
    ll = "eza -alh --group-directories-first --icons";
    ls = "eza --icons";
    lt = "eza --tree --icons";
    v = "nvim";
    z = "zed";

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
    td = "tmux detach -t";
    ts = "tmux new-session -s";
    tl = "tmux list-sessions";
    tk = "tmux kill-session -t";
    tks = "tmux kill-server";
    tn = "tmux new -s $(basename $(pwd))";

    # Safety
    cp = "cp -i";
    mv = "mv -i";
    rm = "rm -i";
  };

  plugins = [
    {
      name = "zsh-syntax-highlighting";
      src = pkgs.fetchFromGitHub {
        owner = "zsh-users";
        repo = "zsh-syntax-highlighting";
        rev = "0.7.1";
        sha256 = "0zmq66dzasmr5pwribyh4kbkk23jxbpdw4rjxx0i7dx8jjp2lzl4";
      };
    }
    {
      name = "zsh-history-substring-search";
      src = pkgs.fetchFromGitHub {
        owner = "zsh-users";
        repo = "zsh-history-substring-search";
        rev = "v1.0.2";
        sha256 = "0y8va5kc2ram38hbk2cibkk64ffrabfv1sh4xm7pjspsba9n5p1y";
      };
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

  initExtraFirst = ''
    # Better compinit configuration
    autoload -Uz compinit
    if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
      compinit
    else
      compinit -C
    fi

    # Additional autoloads
    autoload -Uz url-quote-magic
    zle -N self-insert url-quote-magic
    autoload -Uz bracketed-paste-magic
    zle -N bracketed-paste bracketed-paste-magic
  '';

  initExtra = ''
    # Additional useful options
    setopt AUTO_RESUME          # Treat single word simple commands without redirection as candidates for resumption of an existing job
    setopt NOTIFY              # Report status of background jobs immediately
    setopt PROMPT_SUBST        # Parameter expansion, command substitution and arithmetic expansion in prompts
    setopt AUTO_CONTINUE       # Automatically resume disowned jobs
    setopt NO_HUP             # Don't kill background jobs when shell exits
    setopt LONG_LIST_JOBS     # List jobs in the long format by default
    setopt vi                 # Use vi key bindings in ZLE

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

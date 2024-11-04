{ config, pkgs, lib, ... }: {
  enable = true;
  enableAutosuggestions = true;
  enableCompletion = true;
  autocd = true;

  shellAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    cat = "bat";
    g = "git";
    la = "eza -a --icons";
    ll = "eza -alh --group-directories-first --icons";
    ls = "eza --icons";
    lt = "eza --tree --icons";
    mtop = "sudo mactop --interval 500 --color cyan";
    myip = "curl http://ipecho.net/plain; echo";
    ports = "lsof -i -P -n | grep LISTEN";
    rebuild = "darwin-rebuild switch --flake ~/dotfiles/nix#prime";
    reload = "home-manager switch";
    update = "nix flake update";
    v = "nvim";
    vim = "nvim";
    z = "zed";

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
    {
      name = "zsh-completions";
      src = pkgs.fetchFromGitHub {
        owner = "zsh-users";
        repo = "zsh-completions";
        rev = "0.34.0";
        sha256 = "0jqz2zk4m9p5k4179j1h3qsmvgrggwl8qx7vxnx1k60bqil5vz08";
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

    # Enhanced completion styling
    zstyle ':completion:*' menu select
    zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
    zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
    zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
    zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
    zstyle ':completion:*' accept-exact '*(N)'
    zstyle ':completion:*' use-cache on
    zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"
    zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
    zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'

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

    # Directory stack
    DIRSTACKSIZE=20
    setopt autopushd pushdminus pushdsilent pushdtohome pushdignoredups

    # Better history searching
    autoload -U up-line-or-beginning-search
    autoload -U down-line-or-beginning-search
    zle -N up-line-or-beginning-search
    zle -N down-line-or-beginning-search
    bindkey "^[[A" up-line-or-beginning-search
    bindkey "^[[B" down-line-or-beginning-search

    # Load additional completions
    if [ -d "$XDG_DATA_HOME/zsh/site-functions" ]; then
      fpath=("$XDG_DATA_HOME/zsh/site-functions" $fpath)
    fi

    # Better command not found handler
    command_not_found_handler() {
      local purple='\e[1;35m' bright='\e[0;1m' green='\e[1;32m' reset='\e[0m'
      printf 'zsh: command not found: %s\n' "$1"
      local entries=(
          ${pkgs.nix}/bin/nix-locate --minimal --no-group --type x --type s --top-level --whole-name --at-root "/bin/$1"
      )
      if [[ -n "$entries" ]]; then
          printf "${purple}$1${reset} may be found in the following packages:\n"
          local pkg
          for pkg in $entries; do
              printf '  %s\n' "${bright}${pkg}${reset}"
          done
      fi
      return 127
    }

    # Useful functions
    mkcd() { mkdir -p "$@" && cd "$@" }
    cdtemp() { cd "$(mktemp -d)" }

    # Load direnv if available
    if command -v direnv >/dev/null; then
      eval "$(direnv hook zsh)"
    fi
  '';
}

{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.home-manager.enable = true;

  # User Configuration
  home = {
    username = "hushio";
    homeDirectory = "/Users/hushio";
    stateVersion = "23.11";

    # Session Variables
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less";
      LESS = "-R --mouse --wheel-lines=3";
      LESSHISTFILE = "-";
      CLICOLOR = 1;
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      SSH_AUTH_SOCK = "$HOME/.ssh/ssh-auth-sock";
      DOCKER_BUILDKIT = "1";
      GOPATH = "$HOME/go";
      GOBIN = "$HOME/go/bin";
      PATH = "$GOBIN:$PATH";
      PYTHONDONTWRITEBYTECODE = 1;
      NODE_OPTIONS = "--max-old-space-size=4096";
    };

    # Shell Aliases
    shellAliases = {
      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      ll = "eza -alh --group-directories-first --icons";
      ls = "eza --icons";
      la = "eza -a --icons";
      lt = "eza --tree --icons";
      cat = "bat";

      # Git
      g = "git";
      gs = "git status -sb";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gpl = "git pull";
      gl = "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";
      gd = "git diff";

      # Docker
      d = "docker";
      dc = "docker-compose";
      dps = "docker ps";

      # Development
      py = "python";
      v = "nvim";
      vim = "nvim";
      z = "zed";

      # tmux
      tm = "tmux new-session -A -s main";
      tl = "tmux list-sessions";
      ta = "tmux attach";

      # System
      mtop = "sudo mactop --interval 500 --color cyan";
      reload = "home-manager switch";
      update = "nix flake update";
      rebuild = "darwin-rebuild switch --flake ~/dotfiles/nix#prime";
      ports = "lsof -i -P -n | grep LISTEN";
      myip = "curl http://ipecho.net/plain; echo";

      # Safety
      cp = "cp -i";
      mv = "mv -i";
      rm = "rm -i";
    };
  };

  # XDG Base Directory Specification
  xdg = {
    enable = true;
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    cacheHome = "${config.home.homeDirectory}/.cache";
    stateHome = "${config.home.homeDirectory}/.local/state";

    # XDG file configurations
    configFile = {
      # Zed Editor Configuration
      "zed/settings.json".source = (pkgs.formats.json {}).generate "zed-settings" config.programs.zed.settings;

      # Git Configuration
      "git/ignore".text = ''
        .DS_Store
        .envrc
        .direnv
        *.swp
        *~
        \#*\#
        .env
        .env.*
        node_modules/
        __pycache__/
        *.pyc
        .pytest_cache/
        .coverage
        coverage.xml
        *.egg-info/
        dist/
        build/
        .idea/
        .vscode/
        *.iml
        .metals/
        .bloop/
      '';

      # Ripgrep Configuration
      "ripgrep/config".text = ''
        --smart-case
        --follow
        --hidden
        --glob=!.git/*
        --glob=!node_modules/*
        --glob=!.direnv/*
        --glob=!.venv/*
        --glob=!__pycache__/*
        --colors=line:style:bold
        --colors=path:style:bold
        --colors=match:fg:yellow
      '';

      # lazygit configuration
      "lazygit/config.yml".text = ''
        git:
          paging:
            colorArg: always
            pager: delta --dark --paging=never
      '';

      # Bat Configuration
      "bat/config".text = ''
        --theme="Catppuccin-mocha"
        --style="numbers,changes,header"
        --map-syntax ".ignore:Git Ignore"
        --map-syntax ".gitignore:Git Ignore"
      '';

      # FZF Configuration
      "fzf/fzf.zsh".text = ''
        export FZF_DEFAULT_OPTS="
          --height 40%
          --layout=reverse
          --border
          --inline-info
          --preview 'bat --style=numbers --color=always --line-range :500 {}'
        "
        export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      '';
    };


    systemDirs = {
      data = [
        "/usr/share"
        "/usr/local/share"
        "${config.home.homeDirectory}/.nix-profile/share"
      ];
      config = [
        "/etc/xdg"
        "${config.home.homeDirectory}/.nix-profile/etc/xdg"
      ];
    };
  };

  # Environment setup
  home.file.".zshenv".text = ''
    # XDG Base Directory
    export XDG_CONFIG_HOME="$HOME/.config"
    export XDG_CACHE_HOME="$HOME/.cache"
    export XDG_DATA_HOME="$HOME/.local/share"
    export XDG_STATE_HOME="$HOME/.local/state"

    # Application specific
    export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
    export HISTFILE="$XDG_STATE_HOME/zsh/history"
    export NODE_REPL_HISTORY="$XDG_STATE_HOME/node_history"
    export LESSHISTFILE="$XDG_STATE_HOME/less/history"
    export CARGO_HOME="$XDG_DATA_HOME/cargo"
    export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
  '';

  # Program Configurations
  programs = {
    # Terminal Environment
    alacritty = import ../home/alacritty.nix { inherit pkgs; };
    fzf = import ../home/fzf.nix { inherit pkgs; };
    neofetch = import ../home/neofetch.nix { inherit config pkgs; };
    oh-my-posh = import ../home/oh-my-posh.nix { inherit pkgs; };
    tmux = import ../home/tmux.nix { inherit pkgs; };
    zoxide = import ../home/zoxide.nix { inherit config pkgs; };
    zsh = import ../home/zsh.nix { inherit config pkgs lib; };

    # Development Tools
    git = import ../home/git.nix { inherit pkgs; };
    ssh = import ../home/ssh.nix { inherit config pkgs; };
    neovim = import ../home/neovim.nix { inherit pkgs; };
    zed = import ../home/zed.nix { inherit pkgs; };
  };

  home.enableNixpkgsReleaseCheck = true;
}

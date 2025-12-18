{
  config,
  pkgs,
  ...
}:
{
  programs.home-manager.enable = true;

  xdg = {
    enable = true;
    configFile = {
      "ghostty/config".source = ./config/ghostty/config;
      "nvim".source = ./config/nvim;
    };
  };

  home = {
    username = "joad";
    homeDirectory = "/Users/joad";
    stateVersion = "26.05";

    packages = with pkgs; [
      coreutils
      curl
      wget
      fd
      jq
      yq-go
      tree
      watch
      entr
      delta
      hexyl
      duf
      dust
      gum
      tldr
      man-pages
      uv
      bun
      nodejs_24
      go
      rustup
      lua
      gcc
      cmake
      gnumake
      gh
      lazydocker
      tree-sitter
      httpie
      jless
      nixfmt-rfc-style
      nil
      nerd-fonts._0xproto
    ];

    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.cargo/bin"
      "$HOME/go/bin"
      "/opt/homebrew/bin"
      "/opt/homebrew/sbin"
    ];

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      HOMEBREW_NO_ANALYTICS = 1;
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      NIX_PATH = "nixpkgs=${pkgs.path}";
    };

    file.".local/bin/.keep".text = "";
    file.".ssh/control/.keep".text = "";
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 31536000;
    maxCacheTtl = 31536000;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry_mac;
  };

  programs = {
    zsh = import ./home/zsh.nix { inherit config pkgs; };
    oh-my-posh = import ./home/oh-my-posh.nix { };
    direnv = import ./home/direnv.nix { };
    zoxide = import ./home/zoxide.nix { };
    fzf = import ./home/fzf.nix { };
    eza = import ./home/eza.nix { };
    yazi = import ./home/yazi.nix { };
    neovim = import ./home/neovim.nix { inherit pkgs; };
    tmux = import ./home/tmux.nix { inherit pkgs; };
    git = import ./home/git.nix { };
    lazygit = import ./home/lazygit.nix { };
    gpg = import ./home/gpg.nix { };
    ssh = import ./home/ssh.nix { };
    bat = import ./home/bat.nix { };
    ripgrep = import ./home/ripgrep.nix { };
    bottom = import ./home/bottom.nix { };
    fastfetch = import ./home/fastfetch.nix { };
  };
}

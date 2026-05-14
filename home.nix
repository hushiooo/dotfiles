{
  config,
  pkgs,
  ...
}:
{
  programs.home-manager.enable = true;

  news.display = "silent";

  manual.manpages.enable = false;

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

    # All CLI tools and language toolchains managed here.
    packages = with pkgs; [
      # Core utilities
      cmake
      coreutils
      curl
      delta
      fd
      gcc
      gh
      gnumake
      jq
      nerd-fonts._0xproto
      tflint
      tldr
      wget
      yq-go

      # Language toolchains
      cargo
      clippy
      go
      lua
      nodejs
      python314
      rust-analyzer
      rustc
      rustfmt
      zig

      # Language tools
      pnpm
      prek
      ruff
      sqlc
      sqlfluff
      ty
      uv

      # Infra / Cloud
      awscli2
      dbmate
      sops
      terragrunt

      # Build / Task runners
      go-task
      just

      # General CLI
      duf
      gum
      hexyl
      lazydocker
      mergiraf
      postgresql_16
    ];

    sessionPath = [
      "$HOME/.nix-profile/bin"
      "/nix/var/nix/profiles/default/bin"
      "$HOME/.local/bin"
      "$HOME/go/bin"
      "/opt/homebrew/bin"
      "/opt/homebrew/sbin"
    ];

    sessionVariables = {
      # Keep Cargo/rustc linking on macOS with Apple toolchain,
      # even when Nix gcc-wrapper exists earlier in PATH.
      CC = "/usr/bin/cc";
      CXX = "/usr/bin/c++";
      CARGO_TARGET_AARCH64_APPLE_DARWIN_LINKER = "/usr/bin/cc";

      EDITOR = "nvim";
      HOMEBREW_NO_ANALYTICS = 1;
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      VISUAL = "nvim";
    };

    file.".local/bin/.keep".text = "";
    file.".ssh/control/.keep".text = "";
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 31536000;
    enableSshSupport = true;
    maxCacheTtl = 31536000;
    pinentry.package = pkgs.pinentry_mac;
  };

  programs = {
    bat = import ./home/bat.nix { inherit pkgs; };
    bottom = import ./home/bottom.nix { inherit pkgs; };
    direnv = import ./home/direnv.nix { inherit pkgs; };
    eza = import ./home/eza.nix { inherit pkgs; };
    fastfetch = import ./home/fastfetch.nix { inherit pkgs; };
    fzf = import ./home/fzf.nix { inherit pkgs; };
    git = import ./home/git.nix { inherit config pkgs; };
    gpg = import ./home/gpg.nix { inherit config pkgs; };
    lazygit = import ./home/lazygit.nix { inherit pkgs; };
    neovim = import ./home/neovim.nix { inherit pkgs; };
    oh-my-posh = import ./home/oh-my-posh.nix { inherit pkgs; };
    ripgrep = import ./home/ripgrep.nix { inherit pkgs; };
    ssh = import ./home/ssh.nix { inherit config pkgs; };
    tmux = import ./home/tmux.nix { inherit pkgs; };
    yazi = import ./home/yazi.nix { inherit config pkgs; };
    zoxide = import ./home/zoxide.nix { inherit config pkgs; };
    zsh = import ./home/zsh.nix { inherit config pkgs; };
  };
}

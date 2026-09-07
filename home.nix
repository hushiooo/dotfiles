{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./home/bat.nix
    ./home/bottom.nix
    ./home/direnv.nix
    ./home/eza.nix
    ./home/fastfetch.nix
    ./home/fzf.nix
    ./home/gh.nix
    ./home/git.nix
    ./home/gpg.nix
    ./home/lazygit.nix
    ./home/neovim.nix
    ./home/oh-my-posh.nix
    ./home/ripgrep.nix
    ./home/ssh.nix
    ./home/tmux.nix
    ./home/yazi.nix
    ./home/zoxide.nix
    ./home/zsh.nix
  ];

  programs.home-manager.enable = true;

  home.enableNixpkgsReleaseCheck = false;

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
      crane
      dbmate
      sops
      terraform
      terragrunt
      trivy

      # Build / Task runners
      go-task
      just
      process-compose

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
    file.".pi/agent/AGENTS.md".source = ./config/pi/agent/AGENTS.md;
    file.".ssh/control/.keep".text = "";

    # Pi rewrites settings.json itself (model switches, /settings), so it is
    # seeded once rather than symlinked read-only into the Nix store. Delete
    # the file and re-run `hms` to reset it to the version tracked here.
    activation.seedPiSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -e "$HOME/.pi/agent/settings.json" ]; then
        run mkdir -p "$HOME/.pi/agent"
        run install -m 644 ${./config/pi/agent/settings.json} "$HOME/.pi/agent/settings.json"
      fi
    '';
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 31536000;
    enableSshSupport = true;
    maxCacheTtl = 31536000;
    pinentry.package = pkgs.pinentry_mac;
  };

}

{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.home-manager.enable = true;
  xdg.enable = true;

  home = {
    username = "hushio";
    homeDirectory = "/Users/hushio";
    stateVersion = "23.11";

    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/go/bin"
    ];

    sessionVariables = {
      # Editor & Terminal
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less";
      LESS = "-R --mouse --wheel-lines=3";
      LESSHISTFILE = "-";
      CLICOLOR = 1;

      # Localization
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";

      # Development
      DOCKER_BUILDKIT = "1";
      PYTHONDONTWRITEBYTECODE = 1;
      SSH_AUTH_SOCK = "$HOME/.ssh/ssh-auth-sock";
    };
  };

  # Programs config files
  programs = {
    alacritty = import ./home/alacritty.nix { inherit pkgs; };
    bat = import ./home/bat.nix { inherit pkgs; };
    fastfetch = import ./home/fastfetch.nix { inherit pkgs; };
    fzf = import ./home/fzf.nix { inherit pkgs; };
    gpg = import ./home/gpg.nix { inherit config pkgs; };
    git = import ./home/git.nix { inherit config pkgs; };
    lazygit = import ./home/lazygit.nix { inherit pkgs; };
    neovim = import ./home/neovim.nix { inherit pkgs; };
    oh-my-posh = import ./home/oh-my-posh.nix { inherit pkgs; };
    ripgrep = import ./home/ripgrep.nix { inherit pkgs; };
    ssh = import ./home/ssh.nix { inherit config pkgs; };
    tmux = import ./home/tmux.nix { inherit pkgs; };
    zed-editor = import ./home/zed-editor.nix { inherit pkgs; };
    zoxide = import ./home/zoxide.nix { inherit config pkgs; };
    zsh = import ./home/zsh.nix { inherit config pkgs lib; };
  };

  services = {
    gpg-agent = {
      enable = true;
      defaultCacheTtl = 43200;
      maxCacheTtl = 43200;
      enableSshSupport = true;
      pinentryPackage = pkgs.pinentry_mac;
    };
  };
}

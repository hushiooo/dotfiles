{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.home-manager.enable = true;

  xdg = {
    enable = true;

    configFile = {
      "ghostty/config".source = ./config/ghostty/config;
    };
  };

  home = {
    username = "joad.goutal";
    homeDirectory = "/Users/joad.goutal";
    stateVersion = "23.11";

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
      TERM = "xterm-256color";
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      CLICOLOR = 1;
      KEYTIMEOUT = 1;
      HOMEBREW_NO_ANALYTICS = 1;
    };
  };

  services = {
    gpg-agent = {
      enable = true;
      defaultCacheTtl = 31536000; # 1 year
      maxCacheTtl = 31536000;
      enableSshSupport = true;
      pinentry.package = pkgs.pinentry_mac;
    };
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
    zsh = import ./home/zsh.nix { inherit config pkgs lib; };
  };
}

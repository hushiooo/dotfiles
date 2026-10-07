_: {
  imports = [
    ./home/bat.nix
    ./home/bottom.nix
    ./home/direnv.nix
    ./home/eza.nix
    ./home/fastfetch.nix
    ./home/fzf.nix
    ./home/gh.nix
    ./home/ghostty.nix
    ./home/git.nix
    ./home/gpg.nix
    ./home/herdr.nix
    ./home/lazygit.nix
    ./home/macos.nix
    ./home/neovim.nix
    ./home/nix.nix
    ./home/oh-my-posh.nix
    ./home/packages.nix
    ./home/pi.nix
    ./home/ripgrep.nix
    ./home/skills.nix
    ./home/sops.nix
    ./home/ssh.nix
    ./home/tmux.nix
    ./home/yazi.nix
    ./home/zoxide.nix
    ./home/zsh.nix
  ];

  programs.home-manager.enable = true;

  news.display = "silent";

  manual.manpages.enable = false;

  xdg = {
    enable = true;
    configFile."mcp/mcp.json" = {
      source = ./config/mcp/mcp.json;
      force = true;
    };
  };

  home = {
    username = "joad";
    homeDirectory = "/Users/joad";
    stateVersion = "26.05";

    # Highest precedence first. zsh re-applies this order after macOS
    # path_helper (see zsh.nix), so this list is the single source of truth.
    sessionPath = [
      "$HOME/.nix-profile/bin"
      "/nix/var/nix/profiles/default/bin"
      "$HOME/.local/bin"
      "$HOME/go/bin"
      "/opt/homebrew/bin"
      "/opt/homebrew/sbin"
    ];

    sessionVariables = {
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
}

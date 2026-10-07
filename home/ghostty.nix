{
  config,
  pkgs,
  dotfiles,
  ...
}:
{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin;
    # The config sets `shell-integration = zsh`, so Ghostty injects it itself.
    enableZshIntegration = false;
  };

  # Live symlink so `super+,` edits and reload_config work without a rebuild.
  xdg.configFile."ghostty/config".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/ghostty/config";
}

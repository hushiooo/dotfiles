{ pkgs, ... }:
{
  programs.bat = {
    enable = true;
    # delta reads bat's theme cache, so git.nix uses this theme too.
    themes.tokyonight = {
      src = pkgs.vimPlugins.tokyonight-nvim;
      file = "extras/sublime/tokyonight_night.tmTheme";
    };
    config = {
      italic-text = "always";
      pager = "less -FR";
      style = "numbers,changes,header-filename,grid";
      theme = "tokyonight";
      map-syntax = [
        "*.jenkinsfile:Groovy"
        "*.props:Java Properties"
        ".ignore:Git Ignore"
      ];
    };
  };
}

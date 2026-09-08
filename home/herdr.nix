{
  lib,
  pkgs,
  ...
}:
let
  # AZERTY number-row keys focus tabs 1-10 by their displayed number.
  tabFocus = pkgs.writeShellApplication {
    name = "herdr-tab-focus";
    runtimeInputs = [
      pkgs.herdr
      pkgs.jq
    ];
    text = builtins.readFile ../config/herdr/herdr-tab-focus;
  };
in
{
  programs.herdr = {
    enable = true;
    package = pkgs.herdr;
    settings = lib.importTOML ../config/herdr/config.toml;
  };

  home.packages = [ tabFocus ];
}

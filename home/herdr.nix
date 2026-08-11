{
  config,
  lib,
  pkgs,
  ...
}:
let
  tabFocus = pkgs.writeShellApplication {
    name = "herdr-tab-focus";
    runtimeInputs = [
      pkgs.herdr
      pkgs.jq
    ];
    text = builtins.readFile ../config/herdr/herdr-tab-focus;
  };

  palette = pkgs.writeShellApplication {
    name = "herdr-palette";
    runtimeInputs = [
      pkgs.fzf
      pkgs.herdr
      pkgs.jq
    ];
    text = builtins.readFile ../config/herdr/palette.sh;
  };

  # Kept out of herdr/plugins, which herdr owns for its own installs.
  pluginDir = "herdr-palette";
in
{
  programs.herdr = {
    enable = true;
    package = pkgs.herdr;
    settings = lib.importTOML ../config/herdr/config.toml;
  };

  home.packages = [
    tabFocus
    palette
  ];

  # Absolute command path: herdr 0.7.5 does not resolve plugin-relative
  # commands from the plugin root (fixed upstream in 0.8).
  xdg.configFile."${pluginDir}/herdr-plugin.toml".text = ''
    id = "joad.palette"
    name = "Command Palette"
    version = "0.1.0"
    min_herdr_version = "0.7.0"
    description = "Fuzzy jump and command palette in a popup"
    platforms = [ "macos", "linux" ]

    [[panes]]
    id = "palette"
    title = "Palette"
    placement = "popup"
    command = [ "${lib.getExe palette}" ]
    width = "60%"
    height = "70%"

    [[actions]]
    id = "open"
    title = "Open command palette"
    contexts = [ "workspace" ]
    command = [ "sh", "-c", "exec \"$HERDR_BIN_PATH\" plugin pane open --plugin joad.palette --entrypoint palette" ]
  '';

  # Plugin registration lives in herdr's own state, so re-link whenever the
  # manifest store path changes. Works with or without a running server.
  home.activation.linkHerdrPalette = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${lib.getExe pkgs.herdr} plugin link "${config.xdg.configHome}/${pluginDir}" || true
  '';
}

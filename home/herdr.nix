{
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

  # A real directory, not a symlinked file: herdr resolves plugin_root from the
  # manifest's parent, so a symlink into the store would root the plugin at
  # /nix/store itself. The command path is absolute because 0.7.5 does not
  # resolve plugin-relative commands from the root (fixed upstream in 0.8).
  paletteManifest = pkgs.writeText "herdr-plugin.toml" ''
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

  palettePlugin = pkgs.runCommand "herdr-palette-plugin" { } ''
    mkdir -p "$out"
    cp ${paletteManifest} "$out/herdr-plugin.toml"
  '';
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

  # The upstream module reloads on change, which is noisy when no server is
  # running. Same effect, without the raw socket error during activation.
  xdg.configFile."herdr/config.toml".onChange = lib.mkForce ''
    ${lib.getExe pkgs.herdr} server reload-config >/dev/null 2>&1 || true
  '';

  # Plugin registration lives in herdr's own state, so re-link whenever the
  # manifest store path changes. Works with or without a running server.
  home.activation.linkHerdrPalette = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${lib.getExe pkgs.herdr} plugin link ${palettePlugin} >/dev/null 2>&1 || true
  '';
}

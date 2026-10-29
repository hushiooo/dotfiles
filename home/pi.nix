{
  config,
  lib,
  pkgs,
  dotfiles,
  ...
}:
let
  # Live symlinks into the checkout: edits apply without a rebuild.
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/pi/agent/${path}";

  # Herdr's official pi integration reports agent state from lifecycle hooks.
  # Without it Herdr scrapes the screen for "Working", which quiet-tools replaces
  # with the running tool, so every tool call looked like a finished agent.
  # Generated from pkgs.herdr so it tracks the installed Herdr version.
  herdrPiIntegration = pkgs.runCommand "herdr-pi-integration" { } ''
    mkdir -p $out/.pi/agent/extensions
    HOME=$out ${pkgs.herdr}/bin/herdr integration install pi
  '';
in
{
  home.file = {
    ".pi/agent/AGENTS.md".source = link "AGENTS.md";
    ".pi/agent/prompts/schedule.md".source = link "prompts/schedule.md";
    ".pi/agent/mcp.json" = {
      source = link "mcp.json";
      force = true;
    };
    ".pi/agent/extensions/terminal-status-title.js" = {
      source = link "extensions/terminal-status-title.js";
      force = true;
    };
    ".pi/agent/extensions/quiet-tools" = {
      source = link "extensions/quiet-tools";
      force = true;
    };
    ".pi/agent/extensions/auto-router" = {
      source = link "extensions/auto-router";
      force = true;
    };
    ".pi/agent/extensions/usage-footer.js" = {
      source = link "extensions/usage-footer.js";
      force = true;
    };
    ".pi/agent/extensions/herdr-agent-state.ts".source =
      "${herdrPiIntegration}/.pi/agent/extensions/herdr-agent-state.ts";
  };

  # Pi rewrites settings.json itself (model switches, /settings), so it is
  # seeded once rather than symlinked read-only into the Nix store. Delete
  # the file and re-run `hms` to reset it to the version tracked here.
  home.activation.seedPiSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "$HOME/.pi/agent/settings.json" ]; then
      run mkdir -p "$HOME/.pi/agent"
      run install -m 644 ${../config/pi/agent/settings.json} "$HOME/.pi/agent/settings.json"
    fi
  '';
}

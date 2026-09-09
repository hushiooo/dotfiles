{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Single source of truth for where projects live. The command palette
  # (prefix+space) scans this for git repos, and herdr drops worktree checkouts
  # under it. Change it here; that is the only place this path is configured.
  reposRoot = "${config.home.homeDirectory}/dev";

  # AZERTY number-row keys focus tabs 1-10 by their displayed number.
  tabFocus = pkgs.writeShellApplication {
    name = "herdr-tab-focus";
    runtimeInputs = [
      pkgs.herdr
      pkgs.jq
    ];
    text = builtins.readFile ../config/herdr/herdr-tab-focus;
  };

  # Slim command palette: prefix+space popup to open a ~/dev repo as a workspace.
  openWorkspace = pkgs.writeShellApplication {
    name = "herdr-open";
    runtimeInputs = [
      pkgs.herdr
      pkgs.jq
      pkgs.fzf
      pkgs.findutils
      pkgs.coreutils
      pkgs.git
    ];
    text = builtins.readFile ../config/herdr/herdr-open;
  };

  # Worktree hub: prefix+ctrl+w popup to browse/open/delete the repo's worktrees.
  worktreeHub = pkgs.writeShellApplication {
    name = "herdr-worktree";
    runtimeInputs = [
      pkgs.herdr
      pkgs.jq
      pkgs.fzf
      pkgs.git
      pkgs.coreutils
    ];
    text = builtins.readFile ../config/herdr/herdr-worktree;
  };
in
{
  programs.herdr = {
    enable = true;
    package = pkgs.herdr;
    # worktrees.directory is derived from reposRoot so the palette scan and the
    # worktree checkout pool always share the same root (see config.toml note).
    settings = lib.recursiveUpdate (lib.importTOML ../config/herdr/config.toml) {
      worktrees.directory = "${reposRoot}/worktrees";
    };
  };

  # Exposes reposRoot to the palette popup (herdr-open reads $HERDR_REPOS).
  home.sessionVariables.HERDR_REPOS = reposRoot;

  home.packages = [
    tabFocus
    openWorkspace
    worktreeHub
  ];
}

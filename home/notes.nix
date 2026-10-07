{
  config,
  lib,
  pkgs,
  ...
}:
let
  # The CLI lives in the notes repo itself; link it like config/nvim so edits
  # there apply without a rebuild.
  root = "${config.home.homeDirectory}/dev/notes";
in
{
  home = {
    sessionVariables.NOTES_ROOT = root;
    file.".local/bin/notes".source = config.lib.file.mkOutOfStoreSymlink "${root}/bin/notes";
    # Formatter for `notes fmt` / `notes sync`. The other runtime tools (fzf,
    # ripgrep, bat, gum, yazi) come from their own modules.
    packages = [ pkgs.prettier ];
  };

  programs.zsh = {
    shellAliases.n = "notes";
    # Ahead of compinit (order 570) so `_notes` is found.
    initContent = lib.mkOrder 550 "fpath=(${root}/completions $fpath)";
  };
}

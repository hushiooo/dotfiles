{ dotfiles, ... }:
{
  programs = {
    nh = {
      enable = true;
      flake = dotfiles;
      clean = {
        enable = true;
        extraArgs = "--keep 5 --keep-since 7d";
      };
    };

    # `, <cmd>` runs any nixpkgs binary without installing it, and unknown
    # commands suggest the package that provides them.
    nix-index.enable = true;
    nix-index-database.comma.enable = true;

    # Keep zsh (and the prompt) inside `nix shell` / `nix develop`.
    nix-your-shell.enable = true;
  };
}

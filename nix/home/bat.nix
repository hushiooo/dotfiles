{ pkgs }: {
  enable = true;
  config = {
    theme = "Catppuccin-mocha";
    style = "numbers,changes,header";
    syntax-mappings = {
      ".ignore" = "Git Ignore";
      ".gitignore" = "Git Ignore";
    };
  };
}

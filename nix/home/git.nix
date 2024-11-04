{ ... }:
{
  enable = true;
  lfs.enable = true;
  userName = "hushiooo";
  userEmail = "hushio@proton.me";
  signing = {
    key = "hushio@proton.me";
    signByDefault = true;
  };

  aliases = {
    s = "status -sb";
    a = "add";
    c = "commit";
    p = "push";
    pl = "pull";
    d = "diff";
    l = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";
  };

  ignores = [
    ".DS_Store"
    ".envrc"
    ".direnv"
    "*.swp"
    "*~"
    "#*#"
    ".env"
    ".env.*"
    "node_modules/"
    "__pycache__/"
    "*.pyc"
    ".pytest_cache/"
    ".coverage"
    "coverage.xml"
    "*.egg-info/"
    "dist/"
    "build/"
    ".idea/"
    ".vscode/"
    "*.iml"
    ".metals/"
    ".bloop/"
  ];

  extraConfig = {
    pull = {
      rebase = true;
    };
    init = {
      defaultBranch = "main";
    };
    core = {
      pager = "delta";
    };
    interactive = {
      diffFilter = "delta --color-only";
    };
    delta = {
      navigate = true;
      line-numbers = true;
    };
    merge = {
      conflictStyle = "zdiff3";
    };
    credential = {
      helper = "osxkeychain";
    };
  };
}

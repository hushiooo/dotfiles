{ ... }:
{
  enable = true;
  lfs.enable = true;
  userName = "hushiooo";
  userEmail = "joad.goutal@stoik.io";
  signing = {
    key = "joad.goutal@stoik.io";
    signByDefault = true;
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
    url = {
      "git@github.com:" = {
        insteadOf = "https://github.com/";
      };
    };
  };
}

{ ... }:
{
  enable = true;
  lfs.enable = true;

  signing = {
    key = "joad.goutal@stoik.io";
    signByDefault = true;
  };

  ignores = [
    "!.env.example"
    "*.egg-info/"
    "*.iml"
    "*.pyc"
    "*.swp"
    "*~"
    ".AppleDouble"
    ".DS_Store"
    ".LSOverride"
    "._*"
    ".coverage"
    ".direnv/"
    ".env"
    ".env.*"
    ".envrc"
    ".idea/"
    ".mypy_cache/"
    ".pytest_cache/"
    ".ruff_cache/"
    ".venv/"
    ".vscode/"
    "__pycache__/"
    "build/"
    "coverage.xml"
    "dist/"
    "htmlcov/"
    "node_modules/"
    "result"
    "result-*"
    "venv/"
  ];

  settings = {
    user = {
      name = "hushiooo";
      email = "joad.goutal@stoik.io";
    };

    alias = {
      aliases = "config --get-regexp alias";
      br = "branch";
      brd = "branch -d";
      c = "commit";
      ca = "commit --amend";
      can = "commit --amend --no-edit";
      cm = "commit -m";
      co = "checkout";
      cob = "checkout -b";
      contributors = "shortlog -sn";
      d = "diff";
      dc = "diff --cached";
      ds = "diff --staged";
      f = "fetch --all --prune";
      l = "log --oneline -20";
      last = "log -1 HEAD --stat";
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      ll = "log --stat --abbrev-commit";
      nuke = "reset --hard HEAD";
      pl = "pull --rebase";
      ps = "push";
      psf = "push --force-with-lease";
      s = "status -sb";
      sl = "stash list";
      sp = "stash pop";
      ss = "stash push";
      st = "status";
      undo = "reset --soft HEAD~1";
      unstage = "reset HEAD --";
    };
    core = {
      autocrlf = "input";
      editor = "nvim";
      pager = "delta";
    };
    credential.helper = "osxkeychain";
    delta = {
      line-numbers = true;
      navigate = true;
      side-by-side = false;
      syntax-theme = "base16";
    };
    diff = {
      algorithm = "histogram";
      colorMoved = "default";
    };
    fetch = {
      prune = true;
      pruneTags = true;
    };
    init.defaultBranch = "main";
    interactive.diffFilter = "delta --color-only";
    merge = {
      conflictStyle = "zdiff3";
      ff = "only";
    };
    pull.rebase = true;
    push = {
      autoSetupRemote = true;
      default = "current";
    };
    rebase = {
      autoSquash = true;
      autoStash = true;
    };
    rerere.enabled = true;
    url."git@github.com:".insteadOf = "https://github.com/";
  };
}

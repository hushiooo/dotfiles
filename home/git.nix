{
  enable = true;
  lfs.enable = true;

  userName = "hushiooo";
  userEmail = "joad.goutal@stoik.io";

  signing = {
    key = "joad.goutal@stoik.io";
    signByDefault = true;
  };

  aliases = {
    s = "status -sb";
    st = "status";
    c = "commit";
    cm = "commit -m";
    ca = "commit --amend";
    can = "commit --amend --no-edit";
    co = "checkout";
    cob = "checkout -b";
    br = "branch";
    brd = "branch -d";
    l = "log --oneline -20";
    lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
    ll = "log --stat --abbrev-commit";
    d = "diff";
    ds = "diff --staged";
    dc = "diff --cached";
    unstage = "reset HEAD --";
    undo = "reset --soft HEAD~1";
    nuke = "reset --hard HEAD";
    ss = "stash save";
    sp = "stash pop";
    sl = "stash list";
    f = "fetch --all --prune";
    pl = "pull --rebase";
    ps = "push";
    psf = "push --force-with-lease";
    aliases = "config --get-regexp alias";
    last = "log -1 HEAD --stat";
    contributors = "shortlog -sn";
  };

  ignores = [
    ".DS_Store"
    ".AppleDouble"
    ".LSOverride"
    "._*"
    "*.swp"
    "*~"
    ".idea/"
    ".vscode/"
    "*.iml"
    ".envrc"
    ".direnv/"
    "result"
    "result-*"
    ".env"
    ".env.*"
    "!.env.example"
    "node_modules/"
    "__pycache__/"
    "*.pyc"
    ".pytest_cache/"
    ".mypy_cache/"
    ".ruff_cache/"
    ".venv/"
    "venv/"
    "*.egg-info/"
    "dist/"
    "build/"
    ".coverage"
    "coverage.xml"
    "htmlcov/"
  ];

  extraConfig = {
    core.pager = "delta";
    core.editor = "nvim";
    core.autocrlf = "input";
    init.defaultBranch = "main";
    pull.rebase = true;
    push.autoSetupRemote = true;
    push.default = "current";
    fetch.prune = true;
    fetch.pruneTags = true;
    rebase.autoStash = true;
    rebase.autoSquash = true;
    merge.conflictStyle = "zdiff3";
    merge.ff = "only";
    diff.algorithm = "histogram";
    diff.colorMoved = "default";
    interactive.diffFilter = "delta --color-only";
    delta = {
      navigate = true;
      line-numbers = true;
      side-by-side = false;
      syntax-theme = "base16";
    };
    credential.helper = "osxkeychain";
    url."git@github.com:".insteadOf = "https://github.com/";
    rerere.enabled = true;
  };
}

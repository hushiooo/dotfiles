{ ... }:
{
  enable = true;
  config = {
    italic-text = "always";
    pager = "less -FR";
    style = "numbers,changes,header-filename,grid";
    theme = "base16";
    map-syntax = [
      "*.jenkinsfile:Groovy"
      "*.props:Java Properties"
      ".ignore:Git Ignore"
    ];
  };
}

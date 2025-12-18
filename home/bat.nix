{
  enable = true;
  config = {
    theme = "base16";
    style = "numbers,changes,header-filename,grid";
    pager = "less -FR";
    italic-text = "always";
    map-syntax = [
      "*.jenkinsfile:Groovy"
      "*.props:Java Properties"
      ".ignore:Git Ignore"
    ];
  };
}

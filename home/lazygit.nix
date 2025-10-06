{ ... }:
{
  enable = true;
  settings = {
    git = {
      paging = {
        colorArg = "always";
        pager = "delta --dark --paging=never";
      };
      overrideGpg = true;
    };
  };
}

{ ... }:
{
  enable = true;
  settings = {
    git = {
      autoFetch = true;
      autoRefresh = true;
      overrideGpg = true;
      pagers = [
        {
          colorArg = "always";
          pager = "delta --dark --paging=never";
        }
      ];
    };
    gui = {
      nerdFontsVersion = "3";
      showBottomLine = false;
      showCommandLog = false;
      showIcons = true;
      showRandomTip = false;
      theme = {
        activeBorderColor = [
          "#7aa2f7"
          "bold"
        ];
        cherryPickedCommitBgColor = [ "#bb9af7" ];
        cherryPickedCommitFgColor = [ "#1a1b26" ];
        inactiveBorderColor = [ "#565f89" ];
        lightTheme = false;
        optionsTextColor = [ "#7aa2f7" ];
        selectedLineBgColor = [ "#283457" ];
        selectedRangeBgColor = [ "#283457" ];
      };
    };
    keybinding = {
      universal = {
        quit = "q";
        quit-alt1 = "<c-c>";
      };
    };
    os = {
      editPreset = "nvim";
    };
  };
}

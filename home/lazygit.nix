{
  enable = true;
  settings = {
    gui = {
      showIcons = true;
      showRandomTip = false;
      showCommandLog = false;
      showBottomLine = false;
      nerdFontsVersion = "3";
      theme = {
        lightTheme = false;
        activeBorderColor = [ "#7aa2f7" "bold" ];
        inactiveBorderColor = [ "#565f89" ];
        optionsTextColor = [ "#7aa2f7" ];
        selectedLineBgColor = [ "#283457" ];
        selectedRangeBgColor = [ "#283457" ];
        cherryPickedCommitBgColor = [ "#bb9af7" ];
        cherryPickedCommitFgColor = [ "#1a1b26" ];
      };
    };
    git = {
      paging = {
        colorArg = "always";
        pager = "delta --dark --paging=never";
      };
      overrideGpg = true;
      autoFetch = true;
      autoRefresh = true;
    };
    os = {
      editPreset = "nvim";
    };
    keybinding = {
      universal = {
        quit = "q";
        quit-alt1 = "<c-c>";
      };
    };
  };
}

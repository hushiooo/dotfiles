{
  enable = true;
  enableZshIntegration = true;

  settings = {
    manager = {
      show_hidden = false;
      show_symlink = true;
      sort_dir_first = true;
      sort_by = "natural";
      sort_sensitive = false;
      sort_reverse = false;
      linemode = "size";
      scrolloff = 5;
    };

    preview = {
      tab_size = 2;
      max_width = 800;
      max_height = 1200;
      cache_dir = "";
    };

    opener = {
      edit = [
        { run = ''nvim "$@"''; block = true; }
      ];
      open = [
        { run = ''open "$@"''; orphan = true; }
      ];
    };

    open = {
      rules = [
        { name = "*/"; use = [ "edit" "open" ]; }
        { mime = "text/*"; use = [ "edit" ]; }
        { mime = "application/json"; use = [ "edit" ]; }
        { mime = "*/javascript"; use = [ "edit" ]; }
      ];
    };
  };

  keymap = {
    manager.keymap = [
      { on = [ "q" ]; run = "quit"; desc = "Quit"; }
      { on = [ "<Esc>" ]; run = "escape"; desc = "Cancel"; }
      { on = [ "e" ]; run = "open"; desc = "Open file"; }
      { on = [ "<Enter>" ]; run = "open"; desc = "Open file"; }
      { on = [ "l" ]; run = "open"; desc = "Open file"; }
      { on = [ "h" ]; run = "leave"; desc = "Go to parent"; }
      { on = [ "j" ]; run = "arrow 1"; desc = "Move down"; }
      { on = [ "k" ]; run = "arrow -1"; desc = "Move up"; }
      { on = [ "g" "g" ]; run = "arrow -99999999"; desc = "Go to top"; }
      { on = [ "G" ]; run = "arrow 99999999"; desc = "Go to bottom"; }
      { on = [ "." ]; run = "hidden toggle"; desc = "Toggle hidden"; }
      { on = [ "/" ]; run = "search fd"; desc = "Search"; }
      { on = [ "y" ]; run = "yank"; desc = "Yank"; }
      { on = [ "p" ]; run = "paste"; desc = "Paste"; }
      { on = [ "d" ]; run = "remove"; desc = "Delete"; }
      { on = [ "a" ]; run = "create"; desc = "Create"; }
      { on = [ "r" ]; run = "rename"; desc = "Rename"; }
      { on = [ "~" ]; run = "cd ~"; desc = "Go home"; }
    ];
  };
}

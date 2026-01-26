{ ... }:
{
  enable = true;
  enableZshIntegration = true;

  settings = {
    manager = {
      linemode = "size";
      scrolloff = 5;
      show_hidden = false;
      show_symlink = true;
      sort_by = "natural";
      sort_dir_first = true;
      sort_reverse = false;
      sort_sensitive = false;
    };
    open = {
      rules = [
        {
          mime = "*/javascript";
          use = [ "edit" ];
        }
        {
          mime = "application/json";
          use = [ "edit" ];
        }
        {
          mime = "text/*";
          use = [ "edit" ];
        }
        {
          name = "*/";
          use = [
            "edit"
            "open"
          ];
        }
      ];
    };
    opener = {
      edit = [
        {
          run = ''nvim "$@"'';
          block = true;
        }
      ];
      open = [
        {
          run = ''open "$@"'';
          orphan = true;
        }
      ];
    };
    preview = {
      cache_dir = "";
      max_height = 1200;
      max_width = 800;
      tab_size = 2;
    };
  };

  keymap = {
    manager.keymap = [
      {
        on = [ "." ];
        run = "hidden toggle";
        desc = "Toggle hidden";
      }
      {
        on = [ "/" ];
        run = "search fd";
        desc = "Search";
      }
      {
        on = [ "<Enter>" ];
        run = "open";
        desc = "Open file";
      }
      {
        on = [ "<Esc>" ];
        run = "escape";
        desc = "Cancel";
      }
      {
        on = [ "G" ];
        run = "arrow 99999999";
        desc = "Go to bottom";
      }
      {
        on = [ "a" ];
        run = "create";
        desc = "Create";
      }
      {
        on = [ "d" ];
        run = "remove";
        desc = "Delete";
      }
      {
        on = [ "e" ];
        run = "open";
        desc = "Open file";
      }
      {
        on = [
          "g"
          "g"
        ];
        run = "arrow -99999999";
        desc = "Go to top";
      }
      {
        on = [ "h" ];
        run = "leave";
        desc = "Go to parent";
      }
      {
        on = [ "j" ];
        run = "arrow 1";
        desc = "Move down";
      }
      {
        on = [ "k" ];
        run = "arrow -1";
        desc = "Move up";
      }
      {
        on = [ "l" ];
        run = "open";
        desc = "Open file";
      }
      {
        on = [ "p" ];
        run = "paste";
        desc = "Paste";
      }
      {
        on = [ "q" ];
        run = "quit";
        desc = "Quit";
      }
      {
        on = [ "r" ];
        run = "rename";
        desc = "Rename";
      }
      {
        on = [ "y" ];
        run = "yank";
        desc = "Yank";
      }
      {
        on = [ "~" ];
        run = "cd ~";
        desc = "Go home";
      }
    ];
  };
}

_: {
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;

    # Openers and open rules are left at Yazi's defaults: they already send
    # text, JSON, JS and folders to $EDITOR and everything else to `open`.
    settings = {
      mgr = {
        linemode = "size";
        scrolloff = 5;
        show_hidden = false;
        show_symlink = true;
        sort_by = "natural";
        sort_dir_first = true;
        sort_reverse = false;
        sort_sensitive = false;
      };
      preview = {
        max_height = 1200;
        max_width = 800;
        tab_size = 2;
      };
    };

    # Only deviations from the default keymap; the rest stays intact.
    keymap.mgr.prepend_keymap = [
      {
        on = [ "/" ];
        run = "search --via=fd";
        desc = "Search files by name via fd";
      }
      {
        on = [
          "g"
          "n"
        ];
        run = "cd ~/dev/notes/notes";
        desc = "Go to notes";
      }
      {
        on = [ "e" ];
        run = "open";
        desc = "Open file";
      }
      {
        on = [ "l" ];
        run = "open";
        desc = "Open file";
      }
    ];
  };
}

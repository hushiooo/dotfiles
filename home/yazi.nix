{ ... }:
{
  enable = true;
  enableBashIntegration = true;
  enableZshIntegration = true;
  settings = {
    manager = {
      show_hidden = false;
      show_symlink = true;
      sort_sensitive = false;
      sort_reverse = false;
      sort_dir_first = true;
      linemode = "size";
    };
    preview = {
      tab_size = 2;
      max_width = 600;
      max_height = 900;
      cache_dir = "~/.cache/yazi";
    };
    theme = {
      status = {
        primary = {
          fg = "#a9b1d6";
          bg = "#1a1b26";
        };
        info = {
          fg = "#7aa2f7";
          bg = "#1a1b26";
        };
        warning = {
          fg = "#e0af68";
          bg = "#1a1b26";
        };
        error = {
          fg = "#f7768e";
          bg = "#1a1b26";
        };
      };
      filetype = {
        rules = [
          {
            fg = "#7aa2f7";
            mime = "image/*";
          }
          {
            fg = "#bb9af7";
            mime = "video/*";
          }
          {
            fg = "#ff9e64";
            mime = "audio/*";
          }
          {
            fg = "#9ece6a";
            mime = "text/*";
          }
          {
            fg = "#e0af68";
            mime = "application/pdf";
          }
          {
            fg = "#f7768e";
            mime = "application/zip";
          }
          {
            fg = "#2ac3de";
            mime = "inode/directory";
          }
        ];
      };
      input = {
        border = {
          fg = "#7aa2f7";
          bg = "#1a1b26";
        };
        value = {
          fg = "#c0caf5";
          bg = "#1a1b26";
        };
        selected = {
          fg = "#1a1b26";
          bg = "#7aa2f7";
        };
      };
      select = {
        border = {
          fg = "#7aa2f7";
          bg = "#1a1b26";
        };
        active = {
          fg = "#1a1b26";
          bg = "#7aa2f7";
        };
        inactive = {
          fg = "#c0caf5";
          bg = "#1a1b26";
        };
      };
      tasks = {
        border = {
          fg = "#7aa2f7";
          bg = "#1a1b26";
        };
        selected = {
          fg = "#1a1b26";
          bg = "#7aa2f7";
        };
        unselected = {
          fg = "#c0caf5";
          bg = "#1a1b26";
        };
      };
    };
  };
}

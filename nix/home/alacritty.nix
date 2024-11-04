{ pkgs }:
{
  enable = true;
  package = pkgs.alacritty;
  settings = {
    window = {
      padding = {
        x = 8;
        y = 8;
      };
      decorations = "full";
      opacity = 0.98;
      startup_mode = "Windowed";
      title = "Alacritty";
      dynamic_title = false;
      decorations_theme_variant = "Dark";
      dynamic_padding = true;
    };

    scrolling = {
      history = 10000;
      multiplier = 3;
    };

    debug = {
      render_timer = false;
      persistent_logging = false;
      log_level = "Warn";
      print_events = false;
    };

    general = {
      live_config_reload = true;
    };

    font =
      let
        protoFont = style: {
          family = "0xProto Nerd Font";
          inherit style;
        };
      in
      {
        size = 14;
        normal = protoFont "Regular";
        bold = protoFont "Bold";
        italic = protoFont "Italic";
        bold_italic = protoFont "Bold Italic";
        offset = {
          x = 0;
          y = 1;
        };
        glyph_offset = {
          x = 0;
          y = 1;
        };
      };

    mouse = {
      hide_when_typing = true;
      bindings = [
        {
          mouse = "Middle";
          action = "PasteSelection";
        }
      ];
    };

    cursor = {
      style = {
        shape = "Block";
        blinking = "On";
      };
      blink_interval = 750;
      blink_timeout = 5;
      unfocused_hollow = true;
    };

    env = {
      TERM = "xterm-256color";
    };

    # Tokyo Night theme
    colors = {
      primary = {
        background = "#1a1b26";
        foreground = "#c0caf5";
      };

      normal = {
        black = "#15161e";
        red = "#f7768e";
        green = "#9ece6a";
        yellow = "#e0af68";
        blue = "#7aa2f7";
        magenta = "#bb9af7";
        cyan = "#7dcfff";
        white = "#a9b1d6";
      };

      bright = {
        black = "#414868";
        red = "#f7768e";
        green = "#9ece6a";
        yellow = "#e0af68";
        blue = "#7aa2f7";
        magenta = "#bb9af7";
        cyan = "#7dcfff";
        white = "#c0caf5";
      };

      selection = {
        background = "#283457";
        text = "CellForeground";
      };
    };

    # Bell configuration
    bell = {
      animation = "EaseOutExpo";
      duration = 0;
      color = "#ffffff";
    };

    # Keyboard shortcuts
    keyboard = {
      bindings = [
        {
          key = "V";
          mods = "Command";
          action = "Paste";
        }
        {
          key = "C";
          mods = "Command";
          action = "Copy";
        }
        {
          key = "Q";
          mods = "Command";
          action = "Quit";
        }
        {
          key = "N";
          mods = "Command";
          action = "SpawnNewInstance";
        }
        {
          key = "Return";
          mods = "Command";
          action = "ToggleFullscreen";
        }
        {
          key = "Plus";
          mods = "Command";
          action = "IncreaseFontSize";
        }
        {
          key = "Minus";
          mods = "Command";
          action = "DecreaseFontSize";
        }
        {
          key = "Key0";
          mods = "Command";
          action = "ResetFontSize";
        }
      ];
    };
  };
}

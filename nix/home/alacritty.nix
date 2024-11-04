{
  pkgs,
  meta,
  ...
}: {
  enable = true;
  package = pkgs.unstable.alacritty;
  extraPackages = [
      pkgs.alacritty-theme
    ];
  settings = {
    window = {
      padding = {
        x = 4;
        y = 8;
      };
      decorations = "full";
      opacity = 1;
      startup_mode = "Windowed";
      title = "Alacritty";
      dynamic_title = true;
      decorations_theme_variant = "None";
    };

    general = {
      import = [
        pkgs.alacritty-theme.catppuccin_mocha
      ];

      live_config_reload = true;
    };

    font = let
      protoFont = style: {
        family = "0xProto Nerd Font";
        inherit style;
      };
    in {
      size = 14;
      normal = protoFont "Regular";
      bold = protoFont "Bold";
      italic = protoFont "Italic";
      bold_italic = protoFont "Bold Italic";
    };

    mouse.hide_when_typing = true;

    cursor = {
      style = "Block";
    };

    env = {
      TERM = "xterm-256color";
    };
  };
}

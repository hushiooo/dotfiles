{ ... }:
{
  enable = true;
  enableZshIntegration = true;
  settings = {
    version = 2;
    final_space = true;
    console_title_template = "{{ .Folder }} — {{ .Shell }}";
    blocks = [
      {
        type = "prompt";
        alignment = "left";
        newline = true;
        segments = [
          {
            type = "path";
            style = "plain";
            background = "transparent";
            foreground = "#7aa2f7";
            template = " {{ .Path }}";
            properties = {
              style = "agnoster_short";
              max_depth = 3;
              folder_icon = "";
              home_icon = "~";
            };
          }
          {
            type = "nix-shell";
            style = "plain";
            foreground = "#7ebae4";
            background = "transparent";
            template = " *";
          }
          {
            type = "python";
            style = "plain";
            foreground = "#ffdc7d";
            background = "transparent";
            template = "  {{ if .Venv }}{{ .Venv }}{{ end }}";
            properties = {
              display_virtual_env = true;
              display_default = false;
            };
          }
          {
            type = "go";
            style = "plain";
            foreground = "#7dcfff";
            background = "transparent";
            template = "  {{ .Full }}";
          }
          {
            type = "rust";
            style = "plain";
            foreground = "#f7768e";
            background = "transparent";
            template = "  {{ .Full }}";
          }
          {
            type = "aws";
            style = "plain";
            foreground = "#e0af68";
            background = "transparent";
            template = "  {{ .Profile }}{{ if .Region }} ({{ .Region }}){{ end }}";
          }
        ];
      }
      {
        type = "rprompt";
        overflow = "hidden";
        segments = [
          {
            type = "executiontime";
            style = "plain";
            foreground = "#e0af68";
            background = "transparent";
            template = " {{ .FormattedMs }}";
            properties = {
              threshold = 500;
              style = "austin";
            };
          }
          {
            type = "time";
            style = "plain";
            foreground = "#565f89";
            background = "transparent";
            template = " {{ .CurrentDate | date \"15:04\" }}";
          }
        ];
      }
      {
        type = "prompt";
        alignment = "left";
        newline = true;
        segments = [
          {
            type = "text";
            style = "plain";
            foreground_templates = [
              "{{if gt .Code 0}}#f7768e{{end}}"
              "{{if eq .Code 0}}#bb9af7{{end}}"
            ];
            background = "transparent";
            template = "❯";
          }
        ];
      }
    ];
    transient_prompt = {
      foreground_templates = [
        "{{if gt .Code 0}}#f7768e{{end}}"
        "{{if eq .Code 0}}#bb9af7{{end}}"
      ];
      background = "transparent";
      template = "❯ ";
    };
    secondary_prompt = {
      foreground = "#565f89";
      background = "transparent";
      template = "∙ ";
    };
  };
}

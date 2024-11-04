{ ... }:
{
  enable = true;
  enableZshIntegration = true;
  settings = {
    version = 2;
    final_space = true;
    console_title_template = "{{ .Shell }} in {{ .Folder }}";
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
            template = "{{ .Path }}";
            properties = {
              style = "full";
            };
          }
          {
            type = "git";
            style = "plain";
            foreground = "#a9b1d6";
            background = "transparent";
            template = " {{ .HEAD }}{{ if or (.Working.Changed) (.Staging.Changed) }}*{{ end }} <#89ddff>{{ if gt .Behind 0 }}⇣{{ end }}{{ if gt .Ahead 0 }}⇡{{ end }}</>";
            properties = {
              branch_icon = "";
              commit_icon = "@";
              fetch_status = true;
            };
          }
          {
            type = "python";
            style = "plain";
            foreground = "#9ece6a";
            background = "transparent";
            template = " ({{ .Venv }})";
            properties = {
              display_virtual_env = true;
            };
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
            template = "{{ .FormattedMs }}";
            properties = {
              threshold = 1000;
            };
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
      foreground = "#bb9af7";
      background = "transparent";
      template = "❯❯ ";
    };
  };
}

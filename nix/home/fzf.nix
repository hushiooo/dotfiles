{ ... }:
{
  enable = true;
  enableZshIntegration = true;
  tmux.enableShellIntegration = true;
  defaultOptions = [
    "--height 40%"
    "--layout=reverse"
    "--border"
    "--inline-info"
    "--preview 'bat --style=numbers --color=always --line-range :500 {}'"
  ];
  defaultCommand = "rg --files --hidden --follow --glob '!.git/*'";
  fileWidgetCommand = "rg --files --hidden --follow --glob '!.git/*'";
}

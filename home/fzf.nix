{ ... }:
{
  enable = true;
  enableZshIntegration = true;
  tmux.enableShellIntegration = true;

  changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
  changeDirWidgetOptions = [ "--preview 'eza --tree --color=always --level=2 {} | head -100'" ];
  defaultCommand = "fd --type f --hidden --follow --exclude .git";
  defaultOptions = [
    "--border=rounded"
    "--height 50%"
    "--info=inline"
    "--layout=reverse"
    "--margin=1,2"
    "--marker='✓'"
    "--padding=1"
    "--pointer='▶'"
    "--prompt='❯ '"
  ];
  fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
  fileWidgetOptions = [
    "--preview 'bat --style=numbers --color=always --line-range :300 {} 2>/dev/null || tree -C {} 2>/dev/null'"
  ];
  historyWidgetOptions = [
    "--preview 'echo {}'"
    "--preview-window=up:3:wrap"
    "--sort"
    "--exact"
  ];

  colors = {
    bg = "#1a1b26";
    "bg+" = "#283457";
    fg = "#c0caf5";
    "fg+" = "#c0caf5";
    header = "#9ece6a";
    hl = "#bb9af7";
    "hl+" = "#7dcfff";
    info = "#7aa2f7";
    marker = "#9ece6a";
    pointer = "#7dcfff";
    prompt = "#7dcfff";
    spinner = "#9ece6a";
  };
}

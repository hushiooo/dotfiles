{
  enable = true;
  enableZshIntegration = true;
  tmux.enableShellIntegration = true;

  colors = {
    fg = "#c0caf5";
    bg = "#1a1b26";
    hl = "#bb9af7";
    "fg+" = "#c0caf5";
    "bg+" = "#283457";
    "hl+" = "#7dcfff";
    info = "#7aa2f7";
    prompt = "#7dcfff";
    pointer = "#7dcfff";
    marker = "#9ece6a";
    spinner = "#9ece6a";
    header = "#9ece6a";
  };

  defaultOptions = [
    "--height 50%"
    "--layout=reverse"
    "--border=rounded"
    "--inline-info"
    "--margin=1,2"
    "--padding=1"
    "--prompt='❯ '"
    "--pointer='▶'"
    "--marker='✓'"
  ];

  defaultCommand = "fd --type f --hidden --follow --exclude .git";
  fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
  changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";

  fileWidgetOptions = [
    "--preview 'bat --style=numbers --color=always --line-range :300 {} 2>/dev/null || tree -C {} 2>/dev/null'"
  ];

  changeDirWidgetOptions = [
    "--preview 'tree -C {} | head -100'"
  ];
}

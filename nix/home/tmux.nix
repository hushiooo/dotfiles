{ pkgs }:
{
  enable = true;
  shell = "${pkgs.zsh}/bin/zsh";
  mouse = true;
  clock24 = true;
  historyLimit = 102400;
  baseIndex = 1;
  escapeTime = 0;
  terminal = "xterm-256color";

  # Custom key bindings
  prefix = "C-a";
  keyMode = "vi";
  customPaneNavigationAndResize = true;

  shellAliases = {
    tm = "tmux new-session -A -s main";
    tl = "tmux list-sessions";
    ta = "tmux attach";
  };

  extraConfig = ''
    # Window Management
    set-option -g renumber-windows on
    setw -g pane-base-index 1

    # Status bar position
    set-option -g status-position top

    # Better splits that retain current path
    bind c new-window -c '#{pane_current_path}'
    bind ) split-window -h -c '#{pane_current_path}'
    bind - split-window -v -c '#{pane_current_path}'
    bind b break-pane -d

    # Vim-like pane navigation
    bind h select-pane -L
    bind j select-pane -D
    bind k select-pane -U
    bind l select-pane -R

    # Quick reload of tmux config
    bind r source-file ~/.tmux.conf \; display "Config reloaded!"

    # Enable true color support
    set -ag terminal-overrides ",xterm-256color:RGB"
    set -g default-terminal "xterm-256color"

    # Better window switch
    bind -n M-Left select-window -t -1
    bind -n M-Right select-window -t +1

    # Fast toggle between current and last-used window
    bind-key C-a last-window

    # Easy clear history
    bind-key L clear-history

    # Synchronize panes toggle
    bind-key y set-window-option synchronize-panes\; display-message "synchronize mode toggled."
  '';

  plugins = with pkgs; [
    {
      plugin = tmuxPlugins.catppuccin;
      extraConfig = ''
        set -g @catppuccin_flavour 'mocha'

        # Window styling
        set -g @catppuccin_window_left_separator ""
        set -g @catppuccin_window_right_separator " "
        set -g @catppuccin_window_middle_separator " █"
        set -g @catppuccin_window_number_position "right"
        set -g @catppuccin_window_default_fill "number"
        set -g @catppuccin_window_current_fill "number"

        # Status bar styling
        set -g @catppuccin_status_modules_right "application session date_time"
        set -g @catppuccin_status_left_separator  " "
        set -g @catppuccin_status_right_separator ""
        set -g @catppuccin_status_right_separator_inverse "no"
        set -g @catppuccin_status_fill "icon"
        set -g @catppuccin_status_connect_separator "no"
        set -g @catppuccin_date_time_text "%d-%m-%Y %H:%M:%S"
      '';
    }
    {
      plugin = tmuxPlugins.vim-tmux-navigator;
      extraConfig = ''
        # Smart pane switching with awareness of Vim splits
        bind -n C-h if -F "#{@pane_is_vim}" "send-keys C-h" "select-pane -L"
        bind -n C-j if -F "#{@pane_is_vim}" "send-keys C-j" "select-pane -D"
        bind -n C-k if -F "#{@pane_is_vim}" "send-keys C-k" "select-pane -U"
        bind -n C-l if -F "#{@pane_is_vim}" "send-keys C-l" "select-pane -R"
      '';
    }
    {
      plugin = tmuxPlugins.resurrect;
      extraConfig = ''
        set -g @resurrect-capture-pane-contents 'on'
        set -g @resurrect-strategy-nvim 'session'
      '';
    }
    {
      plugin = tmuxPlugins.continuum;
      extraConfig = ''
        set -g @continuum-restore 'on'
        set -g @continuum-save-interval '15'
      '';
    }
    {
      plugin = tmuxPlugins.yank;
      extraConfig = ''
        set -g @yank_selection_mouse 'clipboard'
      '';
    }
    tmuxPlugins.sensible
    tmuxPlugins.pain-control
  ];
}

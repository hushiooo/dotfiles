{ pkgs }:
{
  enable = true;
  mouse = true;
  clock24 = true;
  shell = "${pkgs.zsh}/bin/zsh";
  historyLimit = 102400;
  baseIndex = 1;
  escapeTime = 0;
  terminal = "xterm-256color";

  # Custom key bindings
  prefix = "C-a";
  keyMode = "vi";
  customPaneNavigationAndResize = true;

  extraConfig = ''
    # Window Management
    set-option -g renumber-windows on
    setw -g pane-base-index 1

    # Status bar position
    set-option -g status-position top

    # Pane splits
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

    # Window switch
    bind -n M-Left select-window -t -1
    bind -n M-Right select-window -t +1

    # Fast toggle between current and last-used window
    bind-key C-a last-window

    # Easy clear history
    bind-key L clear-history

    # Synchronize panes toggle
    bind-key y set-window-option synchronize-panes\; display-message "synchronize mode toggled."

    # Custom status bar with lighter colors
    set -g status-style "bg=#24283b,fg=#a9b1d6"

    # Left status - just windows
    set -g status-left ""

    # Window status
    set -g window-status-format "#[fg=#a9b1d6,bg=#24283b] #I │ #W "
    set -g window-status-current-format "#[fg=#24283b,bg=#7aa2f7,bold] #I │ #W "
    set -g window-status-separator ""

    # Right status
    set -g status-right-length 100
    set -g status-right "#[fg=#a9b1d6,bg=#24283b] #[fg=#24283b,bg=#7aa2f7,bold] #S #[fg=#24283b,bg=#9ece6a,bold] %H:%M #[fg=#24283b,bg=#bb9af7,bold] %d-%m-%Y "

    # Pane borders - making them extend fully
    set -g pane-border-style "fg=#7aa2f7"
    set -g pane-active-border-style "fg=#7aa2f7"
    set -g pane-border-lines heavy

    # Message style
    set -g message-style "fg=#7aa2f7,bg=#24283b,bold"
  '';

  plugins = with pkgs; [
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
      plugin = tmuxPlugins.continuum;
      extraConfig = ''
        set -g @continuum-restore 'on'
        set -g @continuum-save-interval '15'
      '';
    }
    {
      plugin = tmuxPlugins.resurrect;
      extraConfig = ''
        set -g @resurrect-strategy-nvim 'session'
        set -g @resurrect-capture-pane-contents 'on'
        set -g @resurrect-save-shell-history 'on'
      '';
    }
    {
      plugin = tmuxPlugins.yank;
      extraConfig = ''
        set -g @yank_selection_mouse 'clipboard'
      '';
    }
    {
      plugin = tmuxPlugins.sensible;
      extraConfig = ''
        set -g default-command "$SHELL"
      '';
    }
    tmuxPlugins.pain-control
  ];
}

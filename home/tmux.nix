{ pkgs }:
{
  enable = true;
  mouse = true;
  clock24 = true;
  shell = "${pkgs.zsh}/bin/zsh";
  historyLimit = 102400;
  baseIndex = 1;
  escapeTime = 0;

  prefix = "C-a";
  keyMode = "vi";
  customPaneNavigationAndResize = true;

  extraConfig = ''
    # Window Management
    set-option -g renumber-windows on
    setw -g pane-base-index 1

    # Fix terminal colors
    set-option -g default-terminal "screen-256color"
    set-option -a terminal-features 'xterm-256color:RGB'

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

    # Fast toggle between current and last-used window
    bind-key C-a last-window

    # Window selection (AZERTY layout)
    unbind &
    unbind é
    unbind "\""
    unbind "'"
    unbind (
    unbind §
    unbind è
    unbind !
    unbind ç
    unbind à

    bind & select-window -t 1
    bind é select-window -t 2
    bind "\"" select-window -t 3
    bind "'" select-window -t 4
    bind ( select-window -t 5
    bind § select-window -t 6
    bind è select-window -t 7
    bind ! select-window -t 8
    bind ç select-window -t 9
    bind à select-window -t 10

    # Easy clear history
    bind-key L clear-history

    # Synchronize panes toggle
    bind-key y set-window-option synchronize-panes\; display-message "synchronize mode toggled."

    # Status bar
    set -g status-style "bg=#24283b,fg=#a9b1d6"

    # Left status
    set -g status-left ""

    # Window status
    set -g window-status-format "#[fg=#a9b1d6,bg=#24283b] #I │ #W "
    set -g window-status-current-format "#[fg=#24283b,bg=#7aa2f7,bold] #I │ #W "
    set -g window-status-separator ""

    # Right status
    set -g status-right-length 100
    set -g status-right "#[fg=#a9b1d6,bg=#24283b] #[fg=#24283b,bg=#7aa2f7,bold] #S #[fg=#24283b,bg=#9ece6a,bold] %H:%M #[fg=#24283b,bg=#bb9af7,bold] %d-%m-%Y "

    # Pane borders
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

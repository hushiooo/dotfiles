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
    ##### Core behavior #####
    set -g renumber-windows on
    setw -g pane-base-index 1

    # Terminal / colors
    set -g default-terminal "tmux-256color"
    set -as terminal-features "xterm-256color:RGB"

    # Status bar position
    set -g status-position top


    ##### Create / split (preserve CWD) #####
    bind c new-window -c "#{pane_current_path}"
    bind ) split-window -h -c "#{pane_current_path}"
    bind - split-window -v -c "#{pane_current_path}"
    bind b break-pane -d


    ##### Pane navigation (prefix + hjkl) #####
    bind h select-pane -L
    bind j select-pane -D
    bind k select-pane -U
    bind l select-pane -R

    # Pane reordering inside window
    bind p swap-pane -U
    bind P swap-pane -D


    ##### Move panes between windows (non-destructive) #####
    # Send pane to next/previous window and follow
    bind > move-pane -t :.+ \; select-window -t :.+
    bind < move-pane -t :.- \; select-window -t :.-

    # Prompted move: enter target window number (e.g. 1)
    bind M command-prompt -p "move-pane to window:" "move-pane -t '%%'"

    # Prompted join: enter source as w.p (e.g. 2.1)
    bind J command-prompt -p "join-pane from (w.p):" "join-pane -s '%%'"


    ##### Window navigation #####
    # Fast toggle between current and last-used window
    bind C-a last-window


    ##### Window selection (AZERTY layout) #####
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


    ##### Utilities #####
    bind L clear-history
    bind y set-window-option synchronize-panes \; display-message "synchronize mode toggled."


    ##### Theme #####
    set -g status-style "bg=#24283b,fg=#a9b1d6"
    set -g status-left ""

    set -g window-status-format "#[fg=#a9b1d6,bg=#24283b] #I │ #W "
    set -g window-status-current-format "#[fg=#24283b,bg=#7aa2f7,bold] #I │ #W "
    set -g window-status-separator ""

    set -g status-right-length 100
    set -g status-right "#[fg=#a9b1d6,bg=#24283b] #[fg=#24283b,bg=#7aa2f7,bold] #S #[fg=#24283b,bg=#9ece6a,bold] %H:%M #[fg=#24283b,bg=#bb9af7,bold] %d-%m-%Y "

    set -g pane-border-style "fg=#7aa2f7"
    set -g pane-active-border-style "fg=#7aa2f7"
    set -g pane-border-lines heavy

    set -g message-style "fg=#7aa2f7,bg=#24283b,bold"
  '';

  plugins = with pkgs; [
    {
      plugin = tmuxPlugins.vim-tmux-navigator;
      extraConfig = ''
        # Smart pane switching with awareness of Vim splits (no prefix)
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

    # sensible removed (optional), pain-control removed (requested)
  ];
}

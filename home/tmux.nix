{ pkgs }:
{
  enable = true;
  mouse = true;
  clock24 = true;
  shell = "${pkgs.zsh}/bin/zsh";
  historyLimit = 50000;
  baseIndex = 1;
  escapeTime = 0;
  prefix = "C-a";
  keyMode = "vi";
  customPaneNavigationAndResize = true;
  terminal = "tmux-256color";

  extraConfig = ''
    set-option -g renumber-windows on
    setw -g pane-base-index 1
    set-option -g focus-events on
    set-option -g status-position top
    set-option -g set-clipboard on

    set-option -a terminal-features 'xterm-256color:RGB'
    set-option -g default-terminal "tmux-256color"

    bind c new-window -c '#{pane_current_path}'
    bind ) split-window -h -c '#{pane_current_path}'
    bind - split-window -v -c '#{pane_current_path}'
    bind | split-window -h -c '#{pane_current_path}'
    bind _ split-window -v -c '#{pane_current_path}'

    bind h select-pane -L
    bind j select-pane -D
    bind k select-pane -U
    bind l select-pane -R

    bind -r H resize-pane -L 5
    bind -r J resize-pane -D 5
    bind -r K resize-pane -U 5
    bind -r L resize-pane -R 5

    bind-key C-a last-window
    bind-key b break-pane -d
    bind-key @ join-pane -s !
    bind-key x kill-pane
    bind-key X kill-window
    bind-key r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"

    unbind &
    unbind é
    unbind \"
    unbind \'
    unbind \(
    unbind §
    unbind è
    unbind \!
    unbind ç
    unbind à

    bind & select-window -t 1
    bind é select-window -t 2
    bind \" select-window -t 3
    bind \' select-window -t 4
    bind \( select-window -t 5
    bind § select-window -t 6
    bind è select-window -t 7
    bind \! select-window -t 8
    bind ç select-window -t 9
    bind à select-window -t 10

    bind-key -T copy-mode-vi v send-keys -X begin-selection
    bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
    bind-key -T copy-mode-vi r send-keys -X rectangle-toggle

    set -g status-style "bg=#1a1b26,fg=#a9b1d6"
    set -g status-left-length 50
    set -g status-right-length 100
    set -g status-left ""
    set -g window-status-format "#[fg=#565f89,bg=#1a1b26] #I #W "
    set -g window-status-current-format "#[fg=#1a1b26,bg=#7aa2f7,bold] #I #W "
    set -g window-status-separator ""
    set -g status-right "#[fg=#565f89]#(whoami)@#H #[fg=#1a1b26,bg=#7aa2f7,bold] #S #[bg=#9ece6a] %H:%M "

    set -g pane-border-style "fg=#3b4261"
    set -g pane-active-border-style "fg=#7aa2f7"
    set -g pane-border-lines heavy

    set -g message-style "fg=#7aa2f7,bg=#1a1b26,bold"
    set -g message-command-style "fg=#7aa2f7,bg=#1a1b26"
  '';

  plugins = with pkgs; [
    {
      plugin = tmuxPlugins.vim-tmux-navigator;
      extraConfig = ''
        bind -n C-h if -F "#{@pane_is_vim}" "send-keys C-h" "select-pane -L"
        bind -n C-j if -F "#{@pane_is_vim}" "send-keys C-j" "select-pane -D"
        bind -n C-k if -F "#{@pane_is_vim}" "send-keys C-k" "select-pane -U"
        bind -n C-l if -F "#{@pane_is_vim}" "send-keys C-l" "select-pane -R"
        bind -n C-\\ if -F "#{@pane_is_vim}" "send-keys C-\\\\" "select-pane -l"
      '';
    }
    {
      plugin = tmuxPlugins.resurrect;
      extraConfig = ''
        set -g @resurrect-strategy-nvim 'session'
        set -g @resurrect-capture-pane-contents 'on'
        set -g @resurrect-dir '~/.local/share/tmux/resurrect'
      '';
    }
    {
      plugin = tmuxPlugins.continuum;
      extraConfig = ''
        set -g @continuum-restore 'on'
        set -g @continuum-save-interval '15'
      '';
    }
    tmuxPlugins.yank
    tmuxPlugins.sensible
  ];
}

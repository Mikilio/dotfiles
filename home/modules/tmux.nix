{
  pkgs,
  inputs,
  ...
}: {
  programs.tmux = {
    enable = true;
    plugins =
      (with pkgs.tmuxPlugins; [
        yank
        catppuccin
        open
        copycat
        resurrect
        continuum
      ])
      ++ [inputs.sessionx.packages.${pkgs.stdenv.system}.default];
    prefix = "C-Space";
    baseIndex = 1;
    escapeTime = 0;
    keyMode = "vi";
    mouse = true;
    terminal = "screen-256color";
    disableConfirmationPrompt = true;
    extraConfig = ''
      set-option -sa terminal-overrides ",xterm*:Tc"

      unbind r
      bind r source-file ~/.config/tmux/tmux.conf

      bind v copy-mode
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R
      bind-key -T copy-mode-vi 'C-\' select-pane -l

      bind-key b set-option status

      resurrect_dir="~/.local/share/tmux/resurrect"
      set -g @resurrect-dir $resurrect_dir
      set -g @resurrect-processes 'ssh psql mysql sqlite3'
      set -g @resurrect-strategy-nvim 'session'
      set -g @resurrect-hook-post-save-all 'target=$(readlink -f $resurrect_dir/last); sed "s| --cmd .*-vim-pack-dir||g; s|/etc/profiles/per-user/$USER/bin/||g" $target | sponge $target'

      set -g @continuum-restore 'on'
      set -g @continuum-boot 'on'
      set -g @continuum-save-interval '10'

      set -g @catppuccin_window_left_separator ""
      set -g @catppuccin_window_right_separator " "
      set -g @catppuccin_window_middle_separator " █"
      set -g @catppuccin_window_number_position "right"

      set -g @catppuccin_window_default_fill "number"
      set -g @catppuccin_window_default_text "#W"

      set -g @catppuccin_window_current_fill "number"
      set -g @catppuccin_window_current_text "#W#{?window_zoomed_flag, -  ,}"

      set -g @catppuccin_status_modules_right "application user host session"
      set -g @catppuccin_application_text "#{pane_current_command}"
      set -g @catppuccin_status_left_separator  " "
      set -g @catppuccin_status_right_separator ""
      set -g @catppuccin_status_fill "icon"
      set -g @catppuccin_status_connect_separator "no"

      bind-key -n C-h if -F "#{@pane-is-vim}" 'send-keys C-h'  'select-pane -L'
      bind-key -n C-j if -F "#{@pane-is-vim}" 'send-keys C-j'  'select-pane -D'
      bind-key -n C-k if -F "#{@pane-is-vim}" 'send-keys C-k'  'select-pane -U'
      bind-key -n C-l if -F "#{@pane-is-vim}" 'send-keys C-l'  'select-pane -R'
      bind -n C-Left if -F "#{@pane-is-vim}" 'send-keys C-Left'  'select-pane -L'
      bind -n C-Down if -F "#{@pane-is-vim}" 'send-keys C-Down'  'select-pane -D'
      bind -n C-Up if -F "#{@pane-is-vim}" 'send-keys C-Up'  'select-pane -U'
      bind -n C-Right if -F "#{@pane-is-vim}" 'send-keys C-Right'  'select-pane -R'


      bind-key -n M-h if -F "#{@pane-is-vim}" 'send-keys M-h' 'resize-pane -L 3'
      bind-key -n M-j if -F "#{@pane-is-vim}" 'send-keys M-j' 'resize-pane -D 3'
      bind-key -n M-k if -F "#{@pane-is-vim}" 'send-keys M-k' 'resize-pane -U 3'
      bind-key -n M-l if -F "#{@pane-is-vim}" 'send-keys M-l' 'resize-pane -R 3'
      bind-key -n M-Left if -F "#{@pane-is-vim}" 'send-keys M-Left' 'resize-pane -L 3'
      bind-key -n M-Down if -F "#{@pane-is-vim}" 'send-keys M-Down' 'resize-pane -D 3'
      bind-key -n M-Up if -F "#{@pane-is-vim}" 'send-keys M-Up' 'resize-pane -U 3'
      bind-key -n M-Right if -F "#{@pane-is-vim}" 'send-keys M-Right' 'resize-pane -R 3'

      tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
      if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if -F \"#{@pane-is-vim}\" 'send-keys C-\\'  'select-pane -l'"
      if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if -F \"#{@pane-is-vim}\" 'send-keys C-\\\\'  'select-pane -l'"

      set -g @sessionx-bind 'o'
      set -g @sessionx-window-mode 'on'
      set -g @sessionx-zoxide-mode 'on'
    '';
  };
}

{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
{
  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      yank
      open
      copycat
      {
        plugin = catppuccin;
        extraConfig = # tmux
          ''
            set -g @catppuccin_window_left_separator ""
            set -g @catppuccin_window_right_separator " "
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
          '';
      }
      {
        plugin = resurrect;
        extraConfig = # tmux
          ''
            set -g @resurrect-processes 'ssh psql mysql sqlite3'
            resurrect_dir=~/.local/share/tmux/resurrect
            set -g @resurrect-dir $resurrect_dir
            set -g @resurrect-hook-post-save-all "sed -i 's| --cmd .*-vim-pack-dir||g; s|/etc/profiles/per-user/$USER/bin/||g' $(readlink -f $resurrect_dir/last)"
          '';
      }
      {
        plugin = continuum;
        extraConfig = # tmux
          ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '10'
          '';
      }
      {
        plugin = inputs.sessionx.packages.${pkgs.stdenv.system}.default;
        extraConfig = # tmux
          ''
            set -g @sessionx-bind 'o'
            set -g @sessionx-window-mode 'on'
            set -g @sessionx-zoxide-mode 'on'
          '';
      }
    ];
    prefix = "C-Space";
    baseIndex = 1;
    escapeTime = 0;
    keyMode = "vi";
    mouse = true;
    focusEvents = true;
    terminal = "tmux-256color";
    disableConfirmationPrompt = true;
    secureSocket = true;
    extraConfig = # tmux
      ''
        set -sg terminal-overrides ",*:RGB"

        unbind r
        bind r source-file ~/.config/tmux/tmux.conf
        bind-key b set-option status

        bind v copy-mode
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

        bind-key -n C-Left if -F "#{@pane-is-vim}" 'send-keys C-Left' 'select-pane -L'
        bind-key -n C-Down if -F "#{@pane-is-vim}" 'send-keys C-Down' 'select-pane -D'
        bind-key -n C-Up if -F "#{@pane-is-vim}" 'send-keys C-Up' 'select-pane -U'
        bind-key -n C-Right if -F "#{@pane-is-vim}" 'send-keys C-Right' 'select-pane -R'

        bind-key -n M-Left if -F "#{@pane-is-vim}" 'send-keys M-Left' 'resize-pane -L 3'
        bind-key -n M-Down if -F "#{@pane-is-vim}" 'send-keys M-Down' 'resize-pane -D 3'
        bind-key -n M-Up if -F "#{@pane-is-vim}" 'send-keys M-Up' 'resize-pane -U 3'
        bind-key -n M-Right if -F "#{@pane-is-vim}" 'send-keys M-Right' 'resize-pane -R 3'
      '';
  };

  systemd.user.services.tmux-server =
    let
      systemdTarget = "graphical-session.target";

    in
    {
      Unit = {
        Description = "tmux user server";
        Documentation = "man:tmux(1)";
        PartOf = systemdTarget;
        After = systemdTarget;
      };

      Service =
        let
          # Wrap `tmux` in a login shell and set the socket path
          tmuxCmd = "${config.programs.tmux.package}/bin/tmux -L ${config.home.username}";
          mkTmuxCommand = c: "${pkgs.runtimeShell} -l -c '${tmuxCmd} ${c}'";
        in
        {
          Type = "forking";
          PassEnvironment = "*";
          ExecStart = mkTmuxCommand "start-server";
          ExecStop = mkTmuxCommand "kill-server";
        };
      Install = {
        WantedBy = [ systemdTarget ];
      };
    };
}

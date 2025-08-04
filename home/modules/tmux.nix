{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: {
  home.sessionVariables.TINTED_TMUX_OPTION_ACTIVE = 1;
  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      yank
      open
      copycat
      tmux-floax
      {
        plugin = catppuccin;
        extraConfig =
          # tmux
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
        extraConfig =
          # tmux
          ''
            set -g @resurrect-processes 'ssh psql mysql sqlite3 btop bat socat "nix repl" ~python3 "~yarn watch" yazi "gh dash"'
            resurrect_dir=~/.local/share/tmux/resurrect
            set -g @resurrect-dir $resurrect_dir
            set -g @resurrect-hook-post-save-all "sed -i 's| --cmd .*-vim-pack-dir||g; s|/etc/profiles/per-user/$USER/bin/||g; s|/nix/store/.*/bin/||g' $(readlink -f $resurrect_dir/last)"
          '';
      }
      {
        plugin = tmux-sessionx;
        extraConfig =
          # tmux
          ''
            set -g @sessionx-bind 'o'
            set -g @sessionx-zoxide-mode 'on'
            set -g @sessionx-ls-command 'ls --tree'
            set -g @sessionx-window-mode 'off'
          '';
      }
      {
        plugin = tmux-thumbs;
        extraConfig =
          # tmux
          ''
            set -g @thumbs-alphabet colemak-homerow
            set -g @thumbs-command 'tmux set-buffer -- {} && tmux display-message \"Copied {}\" && xdg-open {}'
          '';
      }
      {
        plugin = continuum;
        extraConfig =
          # tmux
          ''
            set -g @continuum-restore 'on'
          '';
      }
    ];
    # sensibleOnTop = true;
    prefix = "C-Space";
    baseIndex = 1;
    escapeTime = 0;
    keyMode = "vi";
    mouse = true;
    focusEvents = true;
    terminal = "screen-256color";
    disableConfirmationPrompt = true;
    secureSocket = true;
    extraConfig =
      # tmux
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
  systemd.user = let
    tmux = lib.getExe config.programs.tmux.package;
    shutdown = pkgs.writeShellScript "shutdown.sh" ''
      start_time=$(systemctl show --user --property=ActiveEnterTimestampMonotonic --value tmux.service)

      # Check that we got a value; if not, warn and set start_time to 0.
      if [ -z "$start_time" ]; then
          echo "Warning: Could not retrieve ActiveEnterTimestampMonotonic; assuming 0."
          start_time=0
      fi

      # Get the current uptime from /proc/uptime (first field in seconds), converting to microseconds.
      now=$(awk '{printf "%d", $1 * 1000000}' /proc/uptime)

      # Calculate how long the service has been active (in microseconds).
      elapsed=$(( now - start_time ))
      threshold=60000000  # 60 seconds expressed in microseconds.

      # If the service has been active for at least 60 seconds, run the save script.
      if [ "$elapsed" -ge "$threshold" ]; then
          echo "tmux has been running for at least 60 seconds ($elapsed us); running save script..."
          ${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh
      else
          echo "tmux has been running for less than 60 seconds ($elapsed us); skipping save script..."
      fi

      #kill neovim gracefully to save the session
      #sometimes plugins may have issues and hangs so we do it here manually
      pkill -SIGTERM nvim

      #end all scopes
      systemctl --user kill tmux.slice

      # Always kill the tmux server.
      echo "Killing tmux server..."
      ${tmux} kill-server || true
    '';
    start = "${tmux} start-server";
    runShell = c: "${pkgs.runtimeShell} -l -c '${c}'";
  in {
    services.tmux-server = {
      Unit = {
        Description = "tmux user server";
        Documentation = "man:tmux(1)";
        PartOf = ["tmux.slice"];
        After = ["tmux.slice"];
      };

      Service = {
        Type = "forking";
        ExecStart = runShell start;
        ExecStop = runShell shutdown;
        Slice = "background.slice";
      };
      Install.WantedBy = ["graphical-session.target"];
    };
    slices.tmux = {
      Unit = {
        Description = "tmux user sessions";
        Documentation = "man:tmux(1)";
        After = ["graphical-session.target"];
      };
      Slice.Slice = "background.slice";
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}

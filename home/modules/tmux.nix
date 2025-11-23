{
  pkgs,
  lib,
  config,
  ...
}: {
  home.sessionVariables = {
    TINTED_TMUX_OPTION_ACTIVE = 1;
  };
  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      yank
      open
      copycat
      dotbar
      {
        plugin = resurrect;
        extraConfig = let
          clean_save = pkgs.writeShellScript "clean_save.sh" ''
            file=~/.local/share/tmux/resurrect/last

            sed -i \
              -e '/_popup_/d' \
              -e 's| --cmd .*-vim-pack-dir||g' \
              -e "s|/etc/profiles/per-user/$USER/bin/||g" \
              -e 's|/nix/store.*/bin/||g' \
              "$file"
          '';
        in
          # tmux
          ''
            set -g @resurrect-processes 'ssh psql mysql sqlite3 btop bat socat "nix repl" ~python3 "~yarn watch" yazi "gh dash"'
            set -g @resurrect-dir ~/.local/share/tmux/resurrect
            set -g @resurrect-hook-post-save-all ${clean_save}
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
            set -g @sessionx-filtered-sessions '_popup_'
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
    extraConfig = let
      show-tmux-popup = pkgs.writeShellScript "show-tmux-popup.sh" ''
        session="_popup_$(tmux display -p '#S')"

        if ! tmux has -t "$session" 2> /dev/null; then
          session_id="$(tmux new-session -dP -s "$session" -F '#{session_id}')"
          tmux set-option -s -t "$session_id" key-table popup
          tmux set-option -s -t "$session_id" status off
          tmux set-option -s -t "$session_id" prefix None
          session="$session_id"
        fi

        exec tmux attach -t "$session" > /dev/null
      '';
    in
      # tmux
      ''
        set -sg terminal-overrides ",*:RGB"

        unbind r
        bind r source-file ~/.config/tmux/tmux.conf
        bind-key b set-option status

        set-option -g renumber-windows on
        set -g base-index 1
        setw -g pane-base-index 1

        bind v copy-mode
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

        bind -n M-n next-window
        bind -n M-p previous-window

        bind -n M-L break-pane

        bind -n M-A display-popup -E ${show-tmux-popup}
        bind -T popup M-A detach
        bind -T popup C-o copy-mode

        bind-key -n C-Left if -F "#{@pane-is-vim}" 'send-keys C-Left' 'select-pane -L'
        bind-key -n C-Down if -F "#{@pane-is-vim}" 'send-keys C-Down' 'select-pane -D'
        bind-key -n C-Up if -F "#{@pane-is-vim}" 'send-keys C-Up' 'select-pane -U'
        bind-key -n C-Right if -F "#{@pane-is-vim}" 'send-keys C-Right' 'select-pane -R'

        bind-key -n M-Left if -F "#{@pane-is-vim}" 'send-keys M-Left' 'resize-pane -L 3'
        bind-key -n M-Down if -F "#{@pane-is-vim}" 'send-keys M-Down' 'resize-pane -D 3'
        bind-key -n M-Up if -F "#{@pane-is-vim}" 'send-keys M-Up' 'resize-pane -U 3'
        bind-key -n M-Right if -F "#{@pane-is-vim}" 'send-keys M-Right' 'resize-pane -R 3'

        set -g status-right-length 100
        set -g status-left-length 100
        set -g status-left ""
      '';
  };
  systemd.user = let
    tmux = lib.getExe config.programs.tmux.package;
    shutdown = pkgs.writeShellScript "shutdown.sh" ''
      start_time=$(systemctl show --user --property=ActiveEnterTimestampMonotonic --value tmux-server.service)

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
    '';
    start = "${tmux} start-server";
  in {
    services.tmux-server = {
      Unit = {
        Description = "tmux user server";
        Documentation = "man:tmux(1)";
        After = ["tmux.slice"];
      };

      Service = {
        Type = "forking";
        Slice = "tmux.slice";
        RemainAfterExit = true;
        ExecStart = start;
        ExecStop = shutdown;
      };
      Install.WantedBy = ["default.target"];
    };
    slices.tmux = {
      Unit = {
        Description = "tmux user sessions";
        Documentation = "man:tmux(1)";
      };
      Slice.Slice = ["app.slice"];
    };
  };
}

{
  theme,
  pkgs,
  config,
  lib,
  ...
}:
with lib;
# terminals
  let
    inherit (theme.terminal) font size opacity;
    inherit (theme) xcolors;
    cfg = config.preferences.apps.terminal;
  in {
    config = mkIf (cfg == "wezterm") {
      programs.wezterm = {
        enable = true;
        extraConfig = ''
          local wezterm = require "wezterm"

          return {
            font = wezterm.font_with_fallback {
              "${theme.terminal.font}",
              "Material Symbols Outlined"
            },
            font_size = ${toString theme.terminal.size},
            color_scheme = "Catppuccin Mocha",
            window_background_opacity = ${toString theme.terminal.opacity},
            enable_scroll_bar = false,
            enable_tab_bar = false,
            scrollback_lines = 10000,
            window_padding = {
              left = 10,
              right = 10,
              top = 10,
              bottom = 10,
            },
            check_for_updates = false,
            default_cursor_style = "SteadyBar",
          }
        '';
      };

      home.sessionVariables.TERM = "wezterm";
    };
  }

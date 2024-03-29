{
  inputs,
  moduleWithSystem,
}:
moduleWithSystem (
  perSystem @ {inputs'}: {
    config,
    lib,
    pkgs,
    ...
  }:
    with lib;
    # terminals
      let
        inherit (theme.terminal) font size opacity;
        inherit (theme) xcolors;
      in {
        config = {
          # home.sessionVariables.TERM = "alacritty";

          programs.alacritty = {
            enable = true;
            settings = {
              window = {
                decorations = "none";
                dynamic_padding = true;
                opacity = opacity;
                padding = {
                  x = 5;
                  y = 5;
                };
                startup_mode = "Maximized";
              };

              scrolling.history = 10000;

              font = {
                normal.family = font;
                bold.family = font;
                italic.family = font;
                inherit size;
              };

              draw_bold_text_with_bright_colors = true;
              colors = rec {
                primary = {
                  background = xcolors.crust;
                  foreground = xcolors.fg;
                };
                normal = {
                  inherit (xcolors) red green yellow blue;
                  black = xcolors.mantle;
                  magenta = xcolors.mauve;
                  cyan = xcolors.sky;
                  white = xcolors.text;
                };
                bright =
                  normal
                  // {
                    black = xcolors.base;
                    white = xcolors.rosewater;
                  };
                key_bindings = [
                  {
                    key = "C";
                    mods = "Control|Shift";
                    chars = "\\x1b[99;5u";
                  }
                  {
                    key = "X";
                    mods = "Control|Shift";
                    chars = "\\x1b[120;5u";
                  }
                ];
              };
            };
          };
        };
      }
)

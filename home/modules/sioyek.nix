{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
in
{
  config = {
    xdg.mimeApps.defaultApplicationPackages = [ config.programs.sioyek.package ];
    programs.sioyek = {
      enable = true;
      config = {
        "startup_commands" = "toggle_custom_color fit_page_to_width";
        "start_with_helper_window" = "1";

        # === CATPPUCCIN MOCHA === #
        "background_color" = "#1e1e2e";

        "text_highlight_color" = "#f9e2af";
        "visual_mark_color" = "#7f849cff";

        "search_highlight_color" = "#f9e2af";
        "link_highlight_color" = "#89b4fa";
        "synctex_highlight_color" = "#a6e3a1";

        "highlight_color_a" = "#f9e2af";
        "highlight_color_b" = "#a6e3a1";
        "highlight_color_c" = "#89dceb";
        "highlight_color_d" = "#eba0ac";
        "highlight_color_e" = "#cba6f7";
        "highlight_color_f" = "#f38ba8";
        "highlight_color_g" = "#f9e2af";

        "custom_background_color" = "#1e1e2e";
        "custom_text_color" = "#cdd6f4";

        "ui_text_color" = "#cdd6f4";
        "ui_background_color" = "#313244";
        "ui_selected_text_color" = "#cdd6f4";
        "ui_selected_background_color" = "#585b70";
      };
    };
  };
}

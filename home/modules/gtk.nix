{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
in {
  config = {
    home.pointerCursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };

    gtk = {
      enable = true;

      font = {
        name = "Roboto";
        package = pkgs.roboto;
      };

      gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };

      theme = {
        name = "Catppuccin-Mocha-Compact-Mauve-Dark";
        package = pkgs.catppuccin-gtk.override {
          accents = ["mauve"];
          size = "compact";
          variant = "mocha";
        };
      };
    };
    systemd.user.sessionVariables = {
      GTK_THEME = "Catppuccin-Mocha-Compact-Mauve-Dark";
      XCURSOR_THEME = "Bibata-Modern-Classic";
      XCURSOR_SIZE = 24;
      GTK2_RC_FILES = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    };
  };
}

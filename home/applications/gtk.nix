{
  pkgs,
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.home.applications;

in {
  config = mkIf (cfg!=null && cfg.gui) {
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

      gtk2.configLocation = "${config.home.homeDirectory}/gtk-2.0/gtkrc";

      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };

      theme = {
        name = "Catppuccin-Mocha-Compact-Mauve-dark";
        package = pkgs.catppuccin-gtk.override {
          accents = ["mauve"];
          size = "compact";
          variant = "mocha";
        };
      };
    };
  };
}

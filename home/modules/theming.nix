{
  config,
  pkgs,
  ...
}: let
in {
  config = {
    home.pointerCursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };

    qt.enable = true;
    qt.platformTheme .name = "qtct";
    qt.style.name = "kvantum";

    home.packages = with pkgs; [
      (catppuccin-kvantum.override {
        accent = "Mauve";
        variant = "Mocha";
      })
      rose-pine-icon-theme
    ];

    xdg.configFile."Kvantum/kvantum.kvconfig".source =
      (
        pkgs.formats.ini {}
      )
      .generate "kvantum.kvconfig" {
        General.theme = "Catppuccin-Mocha-Mauve";
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

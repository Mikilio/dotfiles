{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.preferences.apps;
in {
  # Qt theming with Kvantum
  config = mkIf (cfg != null && cfg.gui) {
    qt.enable = true;
    qt.platformTheme = "qtct";
    qt.style.name = "kvantum";

    systemd.user.sessionVariables = let
      cfg = config.qt;
    in
      filterAttrs (n: v: v != null) {
        QT_QPA_PLATFORMTHEME =
          if cfg.platformTheme == "gtk"
          then "gtk2"
          else if cfg.platformTheme == "qtct"
          then "qt5ct"
          else cfg.platformTheme;
        QT_STYLE_OVERRIDE = cfg.style.name;
      };

    home.packages = with pkgs; [
      (catppuccin-kvantum.override {
        accent = "Mauve";
        variant = "Mocha";
      })
    ];

    xdg.configFile."Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini {}).generate "kvantum.kvconfig" {
      General.theme = "Catppuccin-Mocha-Mauve";
    };
  };
}

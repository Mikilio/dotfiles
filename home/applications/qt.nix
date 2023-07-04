{
  pkgs,
  lib,
  config,
  ...
} :

with lib;

let
  cfg = config.home.applications;

in {
# Qt theming with Kvantum
  config = mkIf (cfg!= null && cfg.gui) {
    home.packages = with pkgs; [
      libsForQt5.qtstyleplugin-kvantum
      (catppuccin-kvantum.override {
        accent = "Mauve";
        variant = "Mocha";
      })
    ];
    home.sessionVariables = {
      QT_STYLE_OVERRIDE = "kvantum";
    };

    xdg.configFile."Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini {}).generate "kvantum.kvconfig" {
      General.Theme = "Catppuccin-Mocha-Mauve";
    };
  };
}

{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.home.applications;
in {
  # Qt theming with Kvantum
  config = mkIf (cfg != null && cfg.gui) {

    qt.enable = true;
    qt.platformTheme = "qtct";
    qt.style.name = "kvantum";

    home.packages = with pkgs; [
      (catppuccin-kvantum.override {
        accent = "Mauve";
        variant = "Mocha";
      })
    ];

    xdg.configFile."Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini {}).generate "kvantum.kvconfig" {
      General.Theme = "Catppuccin-Mocha-Mauve";
    };
  };
}

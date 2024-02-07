{inputs, moduleWithSystem} : moduleWithSystem (
perSystem@{ inputs' }:
{ config
, lib
, pkgs
, ...
}:
with lib; let

in {
  # Qt theming with Kvantum
  config = {
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
      General.theme = "Catppuccin-Mocha-Mauve";
    };
  };
})

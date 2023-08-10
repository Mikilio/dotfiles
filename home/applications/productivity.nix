{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.home.applications;
in {

  imports = [ ./pandoc ];

  config = mkIf (cfg != null && cfg.productivity) {
    home.packages = with pkgs; [
      #ms-office to text conversion tool
      catdoc

      #collection of utilities for indexing and searching Maildirs
      mu

      #svg and png editing
      inkscape

      # office
      libreoffice-still

      # productivity
      obsidian

      # 3d modelling
      blender

      xfce.thunar-full
      xarchiver
    ];
  };
}

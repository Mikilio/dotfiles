{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.home.applications;
in {
  config = mkIf (cfg != null && cfg.productivity) {
    home.packages = with pkgs; [
      #ms-office to text conversion tool
      catdoc

      #collection of utilities for indexing and searching Maildirs
      mu

      #conversion between markup formats
      pandoc

      #svg and png editing
      inkscape

      # office
      libreoffice-still

      # productivity
      obsidian

      # 3d modelling
      blender

      #hopefully I can someday use joshuto (wait for glib interfaces to work with any terminal)
      (
        xfce.thunar.override {
          thunarPlugins = [
            xfce.thunar-volman
            xfce.thunar-archive-plugin
            xfce.thunar-media-tags-plugin
          ];
        }
      )
      xfce.tumbler
      xarchiver
    ];
  };
}

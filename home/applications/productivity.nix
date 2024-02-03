{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.preferences.apps;
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

      # 3d modelling
      blender

      xfce.thunar-full
      xarchiver

      #vpn
      openvpn

      #durov <3
      telegram-desktop

      #tor <3
      tor-browser

      #matrix
      element-desktop-wayland

      #discord
      discord-canary
    ];
  };
}

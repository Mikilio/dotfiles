{
  lib,
  pkgs,
  ...
}:
with lib; let
  # media - control and enjoy audio/video
in {
  config = {
    home.packages = with pkgs; [
      #reading, writing and editing meta information
      exiftool
      # audio control
      pavucontrol
      # torrents
      transmission-remote-gtk
      #bluetooth
      bluez

      #mpris
      playerctl

      nur.repos.mikilio.xwaylandvideobridge-hypr
    ];

    programs = {
      mpv = {
        enable = true;
        defaultProfiles = ["gpu-hq"];
        scripts = [pkgs.mpvScripts.mpris];
      };

      imv.enable = true;

      obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [
          droidcam-obs
        ];
      };
    };

    services = {
      udiskie.enable = true;
    };
  };
}

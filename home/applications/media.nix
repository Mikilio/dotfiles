{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.preferences.apps.media;
  # media - control and enjoy audio/video
in {
  config = mkIf cfg {
    home.packages = with pkgs;
      [
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


        config.nur.repos.mikilio.xwaylandvideobridge-hypr
        spotify-tui
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
          wlrobs
          obs-pipewire-audio-capture
          droidcam-obs
        ];
      };
    };

    services = {
      playerctld.enable = true;

      easyeffects = {
        enable = true;
      };

      spotifyd = {
        enable = true;
        package = pkgs.spotifyd.override {withMpris = true;};
        settings.global = {
          autoplay = true;
          backend = "pulseaudio";
          bitrate = 320;
          cache_path = "${config.xdg.cacheHome}/spotifyd";
          device_type = "computer";
          initial_volume = "100";
          password_cmd = "cat ${config.sops.secrets.spotify_pwd.path}";
          use_mpris = true;
          username_cmd = "cat ${config.sops.secrets.spotify_usr.path}";
          volume_normalisation = false;
        };
      };
      udiskie.enable = true;
    };
  };
}

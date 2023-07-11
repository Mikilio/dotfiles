{
  pkgs,
  lib,
  config,
  self',
  ...
}:
with lib; let
  cfg = config.home.applications;
  # media - control and enjoy audio/video
in {
  imports = [
    ./spicetify.nix
  ];

  config = mkIf (cfg != null && cfg.media) {
    home.packages = with pkgs;
      [
        # audio control
        pavucontrol
        playerctl
        pulsemixer
        # images
        imv
        # torrents
        transmission-remote-gtk

        spotify-tui
      ]
      ++ (with self'.packages; [
        discord-canary
        waveform
      ]);

    programs = {
      mpv = {
        enable = true;
        defaultProfiles = ["gpu-hq"];
        scripts = [pkgs.mpvScripts.mpris];
      };

      obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [wlrobs];
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
          use_mpris = true;
          volume_normalisation = false;
        };
      };

      udiskie.enable = true;
    };
  };
}

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
          droidcam-obs
        ];
      };
    };

    services = {
      playerctld.enable = true;

      easyeffects = {
        enable = true;
      };

      udiskie.enable = true;
    };

    #OBS Pipewire nodes
    xdg.configFile = {
      "pipewire/pipewire.conf.d/10-obs.conf".text = ''
        context.objects = [
          {
            factory = adapter
            args = {
              factory.name     = support.null-audio-sink
              node.name        = "obs_out"
              node.description = "OBS Monitor"
              media.class      = Audio/Duplex
              object.linger    = true
              audio.position   = [ FL FR ]
            }
          }
          {
            factory = adapter
            args = {
              factory.name     = support.null-audio-sink
              node.name        = "stream"
              node.description = "To Stream"
              media.class      = Audio/Sink
              object.linger    = true
              audio.position   = [ FL FR ]
            }
          }
        ]
        context.modules = [
          {
            name = libpipewire-module-combine-stream
            args = {
              combine.mode = sink
              node.name = "stream_out_combo"
              node.description = "Copy to Stream"
              combine.latency-compensate = false   # if true, match latencies by adding delays
              combine.props = {
                audio.position = [ FL FR ]
              }
              stream.props = {
              }
              stream.rules = [
                {
                  matches = [
                    {
                      node.name = "stream"
                    }
                    {
                      node.name = "easyeffects_sink"
                    }
                  ]
                  actions = { create-stream = { } }
                }
              ]
            }
          }
        ]
      '';
    };
  };
}

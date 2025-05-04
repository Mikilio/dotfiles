{...}: {
  config = {
    services = {
      easyeffects = {
        enable = true;
      };
    };

    #OBS Pipewire nodes
    xdg.configFile = {
      "pipewire/pipewire.conf.d/10-obs.conf".text = ''
        context.objects = [
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
            name = libpipewire-module-loopback
            args = {
              audio.position = [ FL FR ]
                capture.props = {
                  media.class = Audio/Sink
                    node.name = capture.obs
                    node.description = "OBS Monitor"
                }
              playback.props = {
                media.class = Audio/Source
                node.name = playback.obs
                node.description = "OBS Monitor"
              }
            }
          }
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

    systemd.user.services.easyeffects = {
      Service.Slice = "background-graphical.slice";
    };
  };
}

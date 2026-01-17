{
  pkgs,
  config,
  ...
}: {
  boot = {
    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback.out
    ];
    kernelModules = ["v4l2loopback"];
    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1
    '';
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
    extraConfig = {
      client."high-quality-music" = {
        stream.rules = [
          {
            matches = [
              {
                "application.process.binary" = "mpv";
              }
            ];

            actions = {
              update-props = {
                "resample.quality" = 10;
              };
            };
          }
        ];
      };
    };
    wireplumber = {
      enable = true;

      configPackages = [
        (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/50-hdmi-stereo-quality.conf" ''
          monitor.alsa.rules = [
            {
              matches = [
                {
                  api.alsa.path = "hdmi-stereo"
                }
              ]
              actions = {
                update-props = {
                  api.alsa.period-size = 2048
                }
              }
            }
          ]
        '')

        (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/51-wh-1000xm3-ldac-hq.conf" ''
          monitor.bluez.rules = [
            {
              matches = [
                {
                  api.bluez5.address = "~AC:80:0A.*"
                }
              ]
              actions = {
                update-props = {
                  bluez5.a2dp.ldac.quality = "hq"
                  bluez5.auto-connect = [ a2dp_sink ]
                  bluez5.codecs = [ ldac ]
                }
              }
            }
          ]
        '')
      ];
    };
  };
  security.rtkit.enable = true;
}

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
    wireplumber = {
      enable = true;

      configPackages = [
        (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/50-hdmi-stereo-quality.conf" ''
          context.properties = {
            resample.quality = 10
          }

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
                  device.name = "~bluez_card.*"
                  device.product.id = "0x0cd3"
                  device.vendor.id = "usb:054c"
                }
              ]
              actions = {
                update-props = {
                  bluez5.a2dp.ldac.quality = "hq"
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

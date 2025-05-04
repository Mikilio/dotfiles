{
  lib,
  config,
  ...
}:
{
  boot = {
    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback.out
    ];
    kernelModules = [ "v4l2loopback" ];
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

      extraConfig.bluetoothEnhancements = {
        "monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = [ "a2dp_sink" ];
          "bluez5.auto-connect" = [ "a2dp_sink" ];
          "bluez5.codecs" = [
            "sbc" "sbc_xq"
            "aac" "ldac"
          ];
        };
      };
    };
  };
  security.rtkit.enable = true;
}

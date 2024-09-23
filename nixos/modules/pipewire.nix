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
  };

  hardware.pulseaudio.enable = lib.mkForce false;
}

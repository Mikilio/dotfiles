{
  lib,
  config,
  ...
}: {
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback.out
  ];
  boot.kernelModules = ["v4l2loopback"];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
  };

  hardware.pulseaudio.enable = lib.mkForce false;
}

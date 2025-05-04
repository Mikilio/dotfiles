{ pkgs, ... }:
{
  boot = {
    initrd.kernelModules = ["thunderbolt"];
    kernelModules = ["thunderbolt"];
  };

  services.hardware.bolt.enable = true;
}

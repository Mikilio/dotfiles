{
  config,
  pkgs,
  lib,
  inputs,
  ...
} @ args: {
  imports = [
    ./hardware-configuration.nix
    ./secrets.nix
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  networking.hostName = "homestation";

  # virtualisation
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  users.mutableUsers = false;
  users.users.mikilio = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.mikilio_pwd.path;
    extraGroups = ["adbusers" "input" "libvirtd" "networkmanager" "plugdev" "keys" "transmission" "video" "i2c" "wheel" "docker"];
  };
}

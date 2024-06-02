{
  inputs,
  ezModules,
  ...
} @ args: {
  imports = [
    inputs.disko.nixosModules.disko
    ./hardware-configuration.nix
    ./secrets.nix
    ./disk-config.nix
    inputs.nixos-hardware.nixosModules.hp-elitebook-845g9
    inputs.nixos-hardware.nixosModules.common-pc-laptop-acpi_call
  ] ++ ( with ezModules; [
    backlight
    location
    power
  ]);

  networking.hostName = "elitebook";
  
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
    hashedPassword = "$y$j9T$Uz2XlDPZYF5T2ikyr5k7M0$iMEYT24K5XMrrSFo0Qyq41nuW3bCtjzo5ZCx/5wDGp6";
    extraGroups = ["adbusers" "input" "libvirtd" "networkmanager" "plugdev" "keys" "transmission" "video" "i2c" "wheel" "docker"];
  };
}

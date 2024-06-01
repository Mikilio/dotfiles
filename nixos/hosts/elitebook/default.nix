{
  config,
  pkgs,
  lib,
  self,
  inputs,
  self',
  inputs',
  ...
} @ args: {
  imports = [ ./hardware-configuration.nix ./secrets.nix ]
    ++ (with inputs; [
    nixos-hardware.nixosModules.hp-elitebook-845g9 
    nur.nixosModules.nur
    sops-nix.nixosModules.default
  ]);

  environment.systemPackages = with pkgs; [
    pcscliteWithPolkit.out
  ];

  security.tpm2 = {
    enable = true;
    abrmd.enable = true;
  };

  services = {
    #Proper disk mounting
    udisks2.enable = true;

    printing.enable = true;
  };

  networking = {
    hostName = "homestation";
    firewall = {
      allowedTCPPorts = [42355];
      #mDNS
      allowedUDPPorts = [5353];
    };
    #NOTE: created by: https://github.com/janik-haag/nm2nix
    networkmanager.ensureProfiles.profiles = import ./nm.nix;
  };

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
    hashedPasswordFile = "${self.outPath}/secrets/hashes/mikilio.txt";
    extraGroups = ["adbusers" "input" "libvirtd" "networkmanager" "plugdev" "keys" "transmission" "video" "i2c" "wheel" "docker"];
  };
}

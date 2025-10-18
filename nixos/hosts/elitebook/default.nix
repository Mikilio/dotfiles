{
  inputs,
  pkgs,
  lib,
  ezModules,
  ...
} @ args: {
  imports =
    [
      inputs.disko.nixosModules.disko
      ./hardware-configuration.nix
      ./secrets.nix
      ./disko-impermanence.nix
      inputs.nixos-hardware.nixosModules.hp-elitebook-845g9
    ]
    ++ (with ezModules; [
      vm-dev
      thunderbolt
      lanzaboote
      pipewire
      plymouth
      style
      desktop-essentials
      graphics
      greetd
      power
      bluetooth
      hyprland
      # ollama
      gaming
    ]);

  dotfiles.security.target = "desktop";
  dotfiles.networking.target = "desktop";

  networking.hostName = "elitebook";

  # compresses half the ram for use as swap
  zramSwap.enable = true;

  # I have rocm support apparently
  nixpkgs.config.rocmSupport = true;

  specialisation.gaming.configuration = {
    config = {
      boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
      dotfiles.security.target = lib.mkForce null;
    };
  };

  # virtualisation

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
    pcsclite
  ];

  boot = {
    binfmt.emulatedSystems = ["aarch64-linux"];
    kernel.sysctl = {
      #better mmap entropy
      "vm.mmap_rnd_bits" = 32;
      "vm.mmap_rnd_compat_bits" = 16;
    };
    kernelParams = [
      "iommu=pt"
      "video=efifb:off"
      "fbcon=map:10"
      "pci=realloc"
      "acpi_enforce_resources=lax"
    ];
    # initrd.services.udev.rules =
    #   #udev
    #   ''
    #     SUBSYSTEM=="drm", KERNEL=="card0", ACTION=="add", RUN+="${pkgs.fbset}/bin/con2fbmap 1 1"
    #   '';
  };
  #to persist journal
  environment.etc."machine-id".text = "39bab0f0f3f34287810d06dc1877ba47";
  # for dock
  #stop generating annoying coredumps in home dir
  systemd.coredump.extraConfig = "Storage=journal";
  #for julle
  security.lockKernelModules = false;
  #for embedded systems
  hardware.libjaylink.enable = true;
  hardware.i2c.enable = true;

  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";

  users.mutableUsers = false;
  users.users.mikilio = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$Uz2XlDPZYF5T2ikyr5k7M0$iMEYT24K5XMrrSFo0Qyq41nuW3bCtjzo5ZCx/5wDGp6";
    extraGroups = [
      "adbusers"
      "input"
      "tss" #for swtpm
      "jlink"
      "networkmanager"
      "plugdev"
      "keys"
      "transmission"
      "video"
      "i2c"
      "wheel"
      "podman"
      "ydotool"
      "davfs2"
    ];
  };
}

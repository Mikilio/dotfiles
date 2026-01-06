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

  networking = {
    hostName = "elitebook";
    networkmanager.ensureProfiles.profiles = import ../../modules/networking/nm.nix;
  };

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
  users.users = {
    root.openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDYPjdpzOZCLJfSGaeMo7yYBmTTVSnjf04aB3K74qZN9zOBotyBmLqD+SzVBrvbmGH3byRZF1V5bWdckc9ttdeJnLGJBtBNpBoCEb7V9AufzUC6njka2pvw8yIrOJZmK7JHK/IY21Wjsagu10f4OdUWF+CRevLmECOK0CJQmzbpjksFqVB9vaCI6fTBm0ZD+/AezXideg4FDBnfzjvT/0WEJbYj9yV6UO7rNIx7mYIErCnTg3PUUMuNz1By3pUGBjXnhDogW9KgrDqGDYbkqalxiNOW35D0QyxiIBhqy96B1Irt+dIQPG2qj6uAsMqfAyycGyZ34QukxKbudE/j+F/JlmGAfB3wbS1zaIyASd3vV0nO8zp2fQcyyP2wkjYe/qB9QFnNDh6/OUANKtMdXwFL94ZYJd4ZVwxsVZPdFlCS34Jf10o4P0rXAEcsQplsHFo0bjxn5yySwjEl26HZKBKd7PYQ7hb/zMCVroqcmBLoqGLD5vDaeZ3EMvTIHw6Gumbg6TggLopCzdwNiUqYdqelXwVC/mdpdyOYP/aBzMuN7FzOkehC4p99Pn3tiS+saqmU6em5y4l+U722J9fuKppYIB1VvZY8sDLQlxXepUykNzj0wwJse9fcgZ8X2P48F4gg8OvjZJ/Efyygvi6xsFoSmsP5itC0PIUG95aLhE78vQ== cardno:23_674_753"];
    mikilio = {
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
  };
}

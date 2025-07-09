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
      ollama
      gaming
      distro-testing
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
  programs.virt-manager.enable = true;
  environment = {
    systemPackages = with pkgs; [
      virtio-win
      win-spice
      dive # look into docker image layers
      podman
      podman-tui # Terminal mgmt UI for Podman
      passt # For Pasta rootless networking
    ];
    extraInit = ''
      if [ -z "$DOCKER_HOST" -a -n "$XDG_RUNTIME_DIR" ]; then
        export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
      fi
    '';
  };
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        ovmf = {
          enable = true;
          packages = [pkgs.OVMFFull.fd];
        };
        swtpm.enable = true;
      };
    };
    spiceUSBRedirection.enable = true;
    containers = {
      enable = true;
      storage.settings = {
        storage = {
          driver = "btrfs";
          runroot = "/run/containers/storage";
          graphroot = "/var/lib/containers/storage";
          options.overlay.mountopt = "nodev,metacopy=on";
        };
      };
    };
    oci-containers.backend = "podman";
    podman = {
      enable = true;
      autoPrune.enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
    };
  };
  security.polkit.extraConfig =
    # JS
    ''
      polkit.addRule(function(action, subject) {
          if (action.id.startsWith("org.libvirt") && subject.hasAuthPriv("auth_admin")) {
              return polkit.Result.YES;
          }
      });
    '';
  security.unprivilegedUsernsClone = true;

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

  services.logind.lidSwitchExternalPower = "ignore";

  users.mutableUsers = false;
  users.users.mikilio = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$Uz2XlDPZYF5T2ikyr5k7M0$iMEYT24K5XMrrSFo0Qyq41nuW3bCtjzo5ZCx/5wDGp6";
    extraGroups = [
      "adbusers"
      "input"
      "libvirtd"
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

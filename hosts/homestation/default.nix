{
  config,
  pkgs,
  lib,
  self,
  self',
  inputs',
  ...
} @ args: {
  imports = [./hardware-configuration.nix];

  boot = {
    initrd = {
      systemd.enable = true;
      supportedFilesystems = ["ext4"];
    };

    # load modules on boot
    kernelModules = ["acpi_call"];

    # use latest kernel
    kernelPackages = pkgs.linuxPackages_xanmod_latest;

    kernelParams = ["amd_pstate=active"];

    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };

    loader = {
      # systemd-boot on UEFI
      efi.canTouchEfiVariables = true;
      # Lanzaboote currently replaces the systemd-boot module.
      # This setting is usually set to true in configuration.nix
      # generated at installation time. So we force it to false
      # for now.
      systemd-boot.enable = lib.mkForce false;
    };

    plymouth = {
      enable = true;
      themePackages = [self'.packages.catppuccin-plymouth];
      theme = "catppuccin-mocha";
    };
  };

  environment.systemPackages = [
    pkgs.sbctl
  ];

  hardware = {
    # smooth backlight control
    brillo.enable = true;

    cpu.amd.updateMicrocode = true;

    enableRedistributableFirmware = true;

    xpadneo.enable = true;
  };

  programs = {
    # enable hyprland and required options
    hyprland.enable = true;
    steam.enable = true;
    sway.enable = true;
  };

  security.tpm2 = {
    enable = true;
    abrmd.enable = true;
  };

  services = {
    # for SSD/NVME
    fstrim.enable = true;

    # keyboard remapping (commented out because of chroot issues)
    kmonad = {
      enable = true;
      package = inputs'.kmonad.packages.default;
      keyboards = {
        logitech = {
          device = "/dev/input/by-id/usb-Logitech_G512_RGB_MECHANICAL_GAMING_KEYBOARD_186130623937-event-kbd";
          defcfg = {
            enable = true;
            fallthrough = true;
            allowCommands = false;
          };
          config = builtins.readFile "${self}/modules/logitech.kbd";
        };
      };
    };

    #Proper disk mounting
    udisks2.enable = true;

    logind.extraConfig = ''
      HandlePowerKey=suspend
    '';

    # see https://github.com/fufexan/nix-gaming/#pipewire-low-latency
    pipewire.lowLatency.enable = true;

    printing.enable = true;
  };

  sops.defaultSopsFile = "${self.outPath}/secrets/groups/homestation.yaml";

  networking = {
    hostName = "homestation";
    firewall = {
      allowedTCPPorts = [42355];
      allowedUDPPorts = [5353];
    };
  };
  users.mutableUsers = false;
  users.users.mikilio = {
    isNormalUser = true;
    shell = pkgs.zsh;
    passwordFile = "${self.outPath}/secrets/hashes/mikilio.txt";
    extraGroups = ["adbusers" "input" "libvirtd" "networkmanager" "plugdev" "keys" "transmission" "video" "wheel"];
  };
}

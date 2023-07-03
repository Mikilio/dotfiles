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

  /* age.secrets.spotify = { */
  /*   file = "${self}/secrets/spotify.age"; */
  /*   owner = "mikilio"; */
  /*   group = "users"; */
  /* }; */

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

    /* lanzaboote = { */
    /*   enable = true; */
    /*   pkiBundle = "/etc/secureboot"; */
    /* }; */

    loader = {
      # systemd-boot on UEFI
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = lib.mkForce true;
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
    /* bluetooth = { */
    /*   enable = true; */
    /*   # battery info support */
    /*   package = pkgs.bluez5-experimental; */
    /*   settings = { */
    /*     # make Xbox Series X controller work */
    /*     General = { */
    /*       Class = "0x000100"; */
    /*       ControllerMode = "bredr"; */
    /*       FastConnectable = true; */
    /*       JustWorksRepairing = "always"; */
    /*       Privacy = "device"; */
    /*       Experimental = true; */
    /*     }; */
    /*   }; */
    /* }; */

    # smooth backlight control
    brillo.enable = true;

    cpu.amd.updateMicrocode = true;

    enableRedistributableFirmware = true;


  };

  networking = {
    hostName = "homestation";
    firewall = {
      allowedTCPPorts = [42355];
      allowedUDPPorts = [5353];
    };
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

    kmonad.keyboards = {
      io = {
        name = "homestation";
        device = "/dev/input/by-id/usb-Logitech_G512_RGB_MECHANICAL_GAMING_KEYBOARD_186130623937-if01-event-kbd";
        defcfg = {
          enable = true;
          fallthrough = true;
          allowCommands = false;
        };
        config = builtins.readFile "${self}/modules/main.kbd";
      };
    };

    logind.extraConfig = ''
      HandlePowerKey=suspend
    '';

    # see https://github.com/fufexan/nix-gaming/#pipewire-low-latency
    pipewire.lowLatency.enable = true;

    printing.enable = true;
  };
}

{
  config,
  pkgs,
  lib,
  self,
  self',
  inputs',
  ...
} @ args: {
  imports = [./hardware-configuration.nix ./secrets.nix];

  boot = {
    initrd = {
      systemd.enable = true;
      supportedFilesystems = ["ext4"];
      verbose = false;
    };

    # make it shut up
    consoleLogLevel = 0;

    # use latest kernel
    kernelPackages = pkgs.linuxPackages_xanmod_latest;

    extraModulePackages = with config.boot.kernelPackages; [
      ddcci-driver
      v4l2loopback
    ];

    kernelModules = [ "ddcci" "v4l2loopback" ];

    kernelParams = [
      "quiet"
    ];

    # NixOS configuration for Star Citizen requirements
    kernel.sysctl = {
      "vm.max_map_count" = 16777216;
      "fs.file-max" = 524288;
    };

    lanzaboote = {
      enable = true;
      #currently breaks system
      /*
      enrollKeys = true;
      */
      configurationLimit = 10;
      pkiBundle = "/etc/secureboot";
      settings = {
        #currently breaks system
        /*
        password = "$__file{${config.sops.secrets.boot_pwd.path}}";
        */
      };
    };

    loader = {
      # systemd-boot on UEFI
      efi.canTouchEfiVariables = true;
      timeout = 0;
      # Lanzaboote currently replaces the systemd-boot module.
      # This setting is usually set to true in configuration.nix
      # generated at installation time. So we force it to false
      # for now.
      systemd-boot.enable = lib.mkForce false;
      systemd-boot.consoleMode = "auto";
    };

    plymouth = {
      enable = true;
      themePackages = [(pkgs.catppuccin-plymouth.override {variant = "mocha";})];
      theme = "catppuccin-mocha";
    };
  };

  environment.systemPackages = with pkgs; [
    sbctl
    pcscliteWithPolkit.out
  ];

  hardware = {
    # smooth backlight control
    brillo.enable = true;
    #logitech wireless support (may not be needed)
    logitech.wireless.enable = true;
    #bluetooth
    bluetooth.enable = true;
  };

  security.tpm2 = {
    enable = true;
    abrmd.enable = true;
  };

  services = {
    # keyboard remapping (commented out because of chroot issues)
   #kmonad = {
   #  enable = true;
   #  package = inputs'.kmonad.packages.default;
   #  keyboards = {
   #    logitech = {
   #      device = "/dev/input/by-id/usb-Logitech_G512_RGB_MECHANICAL_GAMING_KEYBOARD_186130623937-event-kbd";
   #      defcfg = {
   #        enable = true;
   #        fallthrough = true;
   #        allowCommands = false;
   #      };
   #      config = builtins.readFile "${self}/modules/logitech.kbd";
   #    };
   #  };
   #};

    #Proper disk mounting
    udisks2.enable = true;

    logind.extraConfig = ''
      HandlePowerKey=suspend
    '';

    # see https://github.com/fufexan/nix-gaming/#pipewire-low-latency
    pipewire.lowLatency.enable = true;

    printing.enable = true;
  };

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
    hashedPasswordFile = "${self.outPath}/secrets/hashes/mikilio.txt";
    extraGroups = ["adbusers" "input" "libvirtd" "networkmanager" "plugdev" "keys" "transmission" "video" "wheel"];
  };
}

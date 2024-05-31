{
  config,
  pkgs,
  lib,
  self,
  inputs,
  self',
  inputs',
  ...
} @ args: let
  #list of users declared inside container
  container_users = {
    nextcloud = 999;
    inherit (config.ids.uids) murmur nginx;
  };
  container_groups = {
    nextcloud = 999;
    inherit (config.ids.gids) murmur nginx;
  };

  get_static_groups = groups:
    builtins.mapAttrs (name: value: {gid = value;}) (
      lib.attrsets.filterAttrs (n: v: builtins.elem n groups) container_groups
    );

  get_static_users = users:
    builtins.mapAttrs (name: value: {
      uid = value;
      group = name;
      isSystemUser = true;
    }) (
      lib.attrsets.filterAttrs (n: v: builtins.elem n users) container_users
    );
in {
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
    ./secrets.nix
    inputs.disko.nixosModules.disko
    inputs.nixos-hardware.nixosModules.common-pc
    # inputs.nixos-hardware.nixosModules.common-gpu-nvidia
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nur.nixosModules.nur
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  #  hardware.nvidia = {
  #
  #    # Modesetting is required.
  #    modesetting.enable = true;
  #
  #    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
  #    # Enable this if you have graphical corruption issues or application crashes after waking
  #    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
  #    # of just the bare essentials.
  #    powerManagement.enable = true;
  #
  #    # Fine-grained power management. Turns off GPU when not in use.
  #    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
  #    powerManagement.finegrained = false;
  #
  #    # Use the NVidia open source kernel module (not to be confused with the
  #    # independent third-party "nouveau" open source driver).
  #    # Support is limited to the Turing and later architectures. Full list of
  #    # supported GPUs is at:
  #    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
  #    # Only available from driver 515.43.04+
  #    # Currently alpha-quality/buggy, so false is currently the recommended setting.
  #    open = false;
  #
  #    # Enable the Nvidia settings menu,
  # # accessible via `nvidia-settings`.
  #    nvidiaSettings = true;
  #  };
  #
  systemd.network = {
    enable = true;
    # silly fix for the service failing on nixos rebuild
    wait-online.enable = lib.mkForce false;
    networks = {
      "40-enp3s0" = {
        matchConfig.Name = "enp3s0";
        networkConfig.DHCP = "yes";
      };
    };
  };
  networking = {
    hostName = "homeserver"; # Define your hostname.
    networkmanager.enable = false;
    useNetworkd = true;
    # nameservers = [
    #   "1.1.1.1"
    #   "1.0.0.1"
    # ];
  };
  # virtualisation
  virtualisation.libvirtd.enable = true;

  services = {
    openssh.enable = true;
    tailscale = {
      enable = true;
      openFirewall = true;
      permitCertUid = "admin";
      extraUpFlags = [
        "--ssh"
        "--operator=admin"
      ];
      authKeyFile = config.sops.secrets.tailscale.path;
    };
  };

  users.groups = get_static_groups (builtins.attrNames container_groups);
  users.mutableUsers = false;
  users.users =
    get_static_users (builtins.attrNames container_users)
    // {
      admin = {
        isNormalUser = true;
        extraGroups = ["libvirtd" "cloudflared" "wheel"];
        packages = [pkgs.cloudflared pkgs.sops pkgs.vim];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEeey5GyUUFlBdgghUeSdnUkxsMJad4rg8mOf2QBFmsa cardno:23_674_753"
        ];
      };
    };
}
